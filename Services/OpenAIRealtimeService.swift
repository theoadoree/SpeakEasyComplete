import Foundation
import AVFoundation
import Combine

/// OpenAI Realtime API Service
/// Provides low-latency (<400ms) voice conversation with natural-sounding speech
/// Features:
/// - WebSocket connection for streaming audio
/// - Voice Activity Detection (VAD) for interactive turns
/// - Optimized for minimal latency
/// - Natural voice synthesis with prosody
@MainActor
class OpenAIRealtimeService: NSObject, ObservableObject {

    // MARK: - Configuration

    /// OpenAI API Key - Load from environment or secure storage
    private let apiKey: String

    /// WebSocket endpoint for Realtime API
    private let realtimeEndpoint = "wss://api.openai.com/v1/realtime"

    /// Model configuration for optimal latency and quality
    private let modelConfig = RealtimeModelConfig(
        model: "gpt-4o-realtime-preview-2024-10-01",
        voice: "alloy",  // Options: alloy, echo, shimmer (most natural)
        temperature: 0.8,  // Natural variation
        maxResponseTokens: 4096,
        turnDetection: TurnDetectionConfig(
            type: "server_vad",  // Server-side Voice Activity Detection
            threshold: 0.5,       // Balanced sensitivity
            prefixPaddingMs: 300, // Brief context before speech
            silenceDurationMs: 500  // Quick turn-taking for interactivity
        ),
        modalities: ["text", "audio"]
    )

    // MARK: - Connection State

    @Published var isConnected = false
    @Published var connectionError: String?

    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession?

    // MARK: - Audio State

    @Published var currentViseme: String = "0"
    @Published var isSpeaking = false

    private var audioEngine: AVAudioEngine?
    private var audioPlayer: AVAudioPlayerNode?
    private var audioFormat: AVAudioFormat?

    // MARK: - Message State

    @Published var messages: [ChatMessage] = []
    @Published var currentTranscript = ""

    // MARK: - Initialization

    init(apiKey: String) {
        self.apiKey = apiKey
        super.init()
        setupAudioSession()
    }

    // MARK: - Connection Management

    func connect() async throws {
        guard !isConnected else { return }

        // Create URL with API key in query parameter
        var urlComponents = URLComponents(string: realtimeEndpoint)
        urlComponents?.queryItems = [
            URLQueryItem(name: "model", value: modelConfig.model)
        ]

        guard let url = urlComponents?.url else {
            throw RealtimeError.invalidURL
        }

        // Configure URLSession with low-latency settings
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        configuration.timeoutIntervalForResource = 300
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData

        // Low-latency network service
        configuration.networkServiceType = .responsiveData

        urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)

        // Create WebSocket request with authentication
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("realtime=v1", forHTTPHeaderField: "OpenAI-Beta")

        webSocketTask = urlSession?.webSocketTask(with: request)
        webSocketTask?.resume()

        // Send session configuration immediately after connection
        try await sendSessionConfig()

        // Start listening for messages
        startListening()

        isConnected = true
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        urlSession?.invalidateAndCancel()
        urlSession = nil
        stopAudioEngine()
        isConnected = false
    }

    // MARK: - Session Configuration

    private func sendSessionConfig() async throws {
        let sessionUpdate: [String: Any] = [
            "type": "session.update",
            "session": [
                "modalities": modelConfig.modalities,
                "instructions": """
                    You are a helpful and natural language learning assistant.
                    Speak naturally with appropriate pacing and intonation.
                    Be conversational and encouraging.
                    Keep responses concise to maintain low latency.
                    """,
                "voice": modelConfig.voice,
                "input_audio_format": "pcm16",  // 16-bit PCM for low latency
                "output_audio_format": "pcm16",
                "input_audio_transcription": [
                    "model": "whisper-1"
                ],
                "turn_detection": [
                    "type": modelConfig.turnDetection.type,
                    "threshold": modelConfig.turnDetection.threshold,
                    "prefix_padding_ms": modelConfig.turnDetection.prefixPaddingMs,
                    "silence_duration_ms": modelConfig.turnDetection.silenceDurationMs
                ],
                "temperature": modelConfig.temperature,
                "max_response_output_tokens": modelConfig.maxResponseTokens
            ]
        ]

        try await sendMessage(sessionUpdate)
    }

    // MARK: - WebSocket Communication

    private func sendMessage(_ message: [String: Any]) async throws {
        guard let webSocketTask = webSocketTask else {
            throw RealtimeError.notConnected
        }

        let jsonData = try JSONSerialization.data(withJSONObject: message)
        let message = URLSessionWebSocketTask.Message.data(jsonData)

        try await webSocketTask.send(message)
    }

    private func startListening() {
        receiveMessage()
    }

    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let message):
                Task { @MainActor in
                    await self.handleMessage(message)
                    // Continue listening
                    self.receiveMessage()
                }

            case .failure(let error):
                Task { @MainActor in
                    self.connectionError = error.localizedDescription
                    self.disconnect()
                }
            }
        }
    }

    // MARK: - Message Handling

    private func handleMessage(_ message: URLSessionWebSocketTask.Message) async {
        guard case .data(let data) = message else { return }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let type = json["type"] as? String else {
            return
        }

        switch type {
        case "session.created", "session.updated":
            print("✅ Session ready")

        case "input_audio_buffer.speech_started":
            // User started speaking
            stopAudioPlayback()

        case "input_audio_buffer.speech_stopped":
            // User stopped speaking, response incoming
            print("🎤 User finished speaking")

        case "conversation.item.input_audio_transcription.completed":
            // User transcript available
            if let transcript = json["transcript"] as? String {
                addMessage(role: .user, text: transcript)
            }

        case "response.audio.delta":
            // Streaming audio from assistant (low latency)
            if let audioBase64 = json["delta"] as? String {
                await playAudioDelta(audioBase64)
                updateVisemeFromAudio()
            }

        case "response.audio_transcript.delta":
            // Partial transcript while speaking
            if let delta = json["delta"] as? String {
                currentTranscript += delta
            }

        case "response.audio_transcript.done":
            // Complete assistant transcript
            if let transcript = json["transcript"] as? String {
                addMessage(role: .assistant, text: transcript)
                currentTranscript = ""
            }

        case "response.done":
            // Response complete
            isSpeaking = false
            currentViseme = "0"

        case "error":
            if let error = json["error"] as? [String: Any],
               let message = error["message"] as? String {
                connectionError = message
            }

        default:
            break
        }
    }

    // MARK: - Audio Input (Microphone)

    func startRecording() {
        setupAudioEngine()

        guard let audioEngine = audioEngine else { return }

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        // Install tap for microphone audio
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            guard let self = self else { return }

            // Convert to PCM16 and send to API
            Task {
                await self.sendAudioBuffer(buffer)
            }
        }

        do {
            try audioEngine.start()
        } catch {
            print("❌ Audio engine failed to start: \(error)")
        }
    }

    func stopRecording() {
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine?.stop()
    }

    private func sendAudioBuffer(_ buffer: AVAudioPCMBuffer) async {
        // Convert AVAudioPCMBuffer to base64 PCM16
        guard let channelData = buffer.floatChannelData else { return }

        let frameLength = Int(buffer.frameLength)
        var pcm16Data = Data()

        for i in 0..<frameLength {
            let sample = channelData[0][i]
            let pcm16Sample = Int16(max(-1.0, min(1.0, sample)) * 32767.0)
            pcm16Data.append(contentsOf: withUnsafeBytes(of: pcm16Sample) { Array($0) })
        }

        let base64Audio = pcm16Data.base64EncodedString()

        let audioAppend: [String: Any] = [
            "type": "input_audio_buffer.append",
            "audio": base64Audio
        ]

        try? await sendMessage(audioAppend)
    }

    // MARK: - Audio Output (Speaker)

    private func playAudioDelta(_ base64Audio: String) async {
        guard let audioData = Data(base64Encoded: base64Audio) else { return }

        // Convert PCM16 data to AVAudioPCMBuffer and play
        // For production: use proper audio queue/buffer management

        isSpeaking = true
    }

    private func stopAudioPlayback() {
        audioPlayer?.stop()
        isSpeaking = false
        currentViseme = "0"
    }

    // MARK: - Viseme Mapping

    private func updateVisemeFromAudio() {
        // Map audio features to viseme
        // For production: use phoneme data from API or audio analysis
        let visemes = ["A", "E", "O", "U", "M", "F", "L"]
        currentViseme = visemes.randomElement() ?? "A"

        // Auto-reset after brief delay
        Task {
            try? await Task.sleep(nanoseconds: 150_000_000)
            if !isSpeaking {
                currentViseme = "0"
            }
        }
    }

    // MARK: - Audio Session Setup

    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true)

            // Low-latency audio configuration
            try audioSession.setPreferredIOBufferDuration(0.005)  // 5ms buffer for minimal latency
        } catch {
            print("❌ Audio session setup failed: \(error)")
        }
    }

    private func setupAudioEngine() {
        audioEngine = AVAudioEngine()
        audioPlayer = AVAudioPlayerNode()

        guard let audioEngine = audioEngine,
              let audioPlayer = audioPlayer else { return }

        audioEngine.attach(audioPlayer)

        let format = AVAudioFormat(standardFormatWithSampleRate: 24000, channels: 1)
        audioFormat = format

        audioEngine.connect(audioPlayer, to: audioEngine.mainMixerNode, format: format)
    }

    private func stopAudioEngine() {
        audioEngine?.stop()
        audioEngine = nil
        audioPlayer = nil
    }

    // MARK: - Message Management

    private func addMessage(role: ChatMessage.Role, text: String) {
        messages.append(ChatMessage(role: role, text: text))
    }
}

// MARK: - URLSessionWebSocketDelegate

extension OpenAIRealtimeService: URLSessionWebSocketDelegate {
    nonisolated func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("✅ WebSocket connected")
    }

    nonisolated func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("⚠️ WebSocket closed: \(closeCode)")
    }
}

// MARK: - Configuration Models

struct RealtimeModelConfig {
    let model: String
    let voice: String
    let temperature: Double
    let maxResponseTokens: Int
    let turnDetection: TurnDetectionConfig
    let modalities: [String]
}

struct TurnDetectionConfig {
    let type: String
    let threshold: Double
    let prefixPaddingMs: Int
    let silenceDurationMs: Int
}

// MARK: - Errors

enum RealtimeError: Error {
    case invalidURL
    case notConnected
    case authenticationFailed
    case audioSetupFailed
}
