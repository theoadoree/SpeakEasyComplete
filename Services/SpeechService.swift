import Foundation
import AVFoundation
import Speech

class SpeechService: NSObject, ObservableObject {
    static let shared = SpeechService()

    @Published var isRecording = false
    @Published var isPlaying = false
    @Published var recognizedText = ""
    @Published var error: String?
    @Published var authorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined

    private var audioEngine: AVAudioEngine?
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioPlayer: AVAudioPlayer?
    private let synthesizer = AVSpeechSynthesizer()

    private override init() {
        super.init()
        setupAudioSession()
    }

    // MARK: - Audio Session Setup
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetoothA2DP])
            try audioSession.setActive(true)
        } catch {
            self.error = "Failed to setup audio session: \(error.localizedDescription)"
        }
    }

    // MARK: - Request Authorizations
    func requestAuthorizations() async -> Bool {
        // Request speech recognition authorization
        let speechStatus = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }

        await MainActor.run {
            authorizationStatus = speechStatus
        }

        // Request microphone authorization
        let microphoneGranted = await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }

        return speechStatus == .authorized && microphoneGranted
    }

    // MARK: - Speech Recognition
    func startRecording(language: String = "en-US") throws {
        // Cancel any ongoing recognition
        stopRecording()

        // Create speech recognizer for target language
        let locale = Locale(identifier: getLocaleIdentifier(for: language))
        speechRecognizer = SFSpeechRecognizer(locale: locale)

        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            throw SpeechError.recognizerUnavailable
        }

        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw SpeechError.unableToCreateRequest
        }

        recognitionRequest.shouldReportPartialResults = true

        // Setup audio engine
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else {
            throw SpeechError.audioEngineUnavailable
        }

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        // Start recognition task
        recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }

            if let result = result {
                DispatchQueue.main.async {
                    self.recognizedText = result.bestTranscription.formattedString
                }
            }

            if error != nil || result?.isFinal == true {
                self.stopRecording()
            }
        }

        isRecording = true
    }

    func stopRecording() {
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()

        audioEngine = nil
        recognitionRequest = nil
        recognitionTask = nil
        isRecording = false
    }

    // MARK: - Text-to-Speech
    func speak(text: String, language: String = "en-US") {
        // Stop any ongoing speech
        stopSpeaking()

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: getLocaleIdentifier(for: language))
        utterance.rate = 0.5 // Slightly slower for language learning
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0

        synthesizer.speak(utterance)
        isPlaying = true
    }

    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
        isPlaying = false
    }

    // MARK: - Language Code Mapping
    private func getLocaleIdentifier(for language: String) -> String {
        let languageMap: [String: String] = [
            "Spanish": "es-ES",
            "French": "fr-FR",
            "German": "de-DE",
            "Italian": "it-IT",
            "Portuguese": "pt-PT",
            "Japanese": "ja-JP",
            "Korean": "ko-KR",
            "Chinese": "zh-CN",
            "Russian": "ru-RU",
            "Arabic": "ar-SA",
            "Hindi": "hi-IN",
            "Dutch": "nl-NL",
            "Swedish": "sv-SE",
            "Polish": "pl-PL",
            "Turkish": "tr-TR",
            "English": "en-US"
        ]

        return languageMap[language] ?? "en-US"
    }

    // MARK: - Clear Recognized Text
    func clearRecognizedText() {
        recognizedText = ""
    }
}

// MARK: - Speech Errors
enum SpeechError: LocalizedError {
    case recognizerUnavailable
    case unableToCreateRequest
    case audioEngineUnavailable
    case authorizationDenied

    var errorDescription: String? {
        switch self {
        case .recognizerUnavailable:
            return "Speech recognizer is not available"
        case .unableToCreateRequest:
            return "Unable to create recognition request"
        case .audioEngineUnavailable:
            return "Audio engine is not available"
        case .authorizationDenied:
            return "Speech recognition authorization denied"
        }
    }
}
