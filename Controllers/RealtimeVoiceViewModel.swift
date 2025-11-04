import Foundation
import SwiftUI
import Combine

@MainActor
final class RealtimeVoiceViewModel: ObservableObject {
    // UI state
    @Published var isConnected: Bool = false
    @Published var isMuted: Bool = false
    @Published var status: String = "Idle"
    @Published var messages: [ChatMessage] = []

    // Viseme-driven avatar
    @Published var currentViseme: String = "0" // "0", "A","E","O","U","M","F","L"
    @Published var isSpeaking: Bool = false

    // OpenAI Realtime Service
    private var realtimeService: OpenAIRealtimeService?
    private var cancellables = Set<AnyCancellable>()

    // Configuration
    private let useRealAPI: Bool
    private var visemeTimer: Timer?

    // MARK: - Initialization

    init(useRealAPI: Bool = true, apiKey: String? = nil) {
        self.useRealAPI = useRealAPI

        if useRealAPI, let apiKey = apiKey ?? loadAPIKey() {
            realtimeService = OpenAIRealtimeService(apiKey: apiKey)
            setupServiceBindings()
        }
    }

    // MARK: - Lifecycle

    func connect() {
        if useRealAPI, let service = realtimeService {
            Task {
                do {
                    try await service.connect()
                    isConnected = true
                    status = "Connected to OpenAI"
                    startRecording()
                } catch {
                    status = "Connection failed: \(error.localizedDescription)"
                }
            }
        } else {
            // Fallback to simulation
            isConnected = true
            status = "Connected (Simulated)"
            startAutoVoice()
        }
    }

    func disconnect() {
        if useRealAPI {
            realtimeService?.disconnect()
            stopRecording()
        } else {
            stopAutoVoice()
        }

        isConnected = false
        isMuted = false
        status = "Disconnected"
    }

    // MARK: - Real API Integration

    private func setupServiceBindings() {
        guard let service = realtimeService else { return }

        // Bind viseme updates
        service.$currentViseme
            .assign(to: &$currentViseme)

        // Bind speaking state
        service.$isSpeaking
            .assign(to: &$isSpeaking)

        // Bind messages
        service.$messages
            .assign(to: &$messages)

        // Bind connection state
        service.$isConnected
            .sink { [weak self] connected in
                self?.isConnected = connected
                self?.status = connected ? "Listening…" : "Disconnected"
            }
            .store(in: &cancellables)

        // Bind errors
        service.$connectionError
            .compactMap { $0 }
            .sink { [weak self] error in
                self?.status = "Error: \(error)"
            }
            .store(in: &cancellables)
    }

    private func startRecording() {
        guard !isMuted else { return }
        realtimeService?.startRecording()
        status = "Listening…"
    }

    private func stopRecording() {
        realtimeService?.stopRecording()
    }

    func toggleMute() {
        isMuted.toggle()

        if useRealAPI {
            if isMuted {
                stopRecording()
                status = "Muted"
            } else {
                startRecording()
                status = "Listening…"
            }
        } else {
            status = isMuted ? "Muted" : (isConnected ? "Listening…" : "Idle")
        }
    }

    // MARK: - Simulated Mode (Fallback)

    func startAutoVoice() {
        guard isConnected, !useRealAPI else { return }
        status = isMuted ? "Muted" : "Listening…"

        // Simulate speaking bursts by cycling visemes periodically.
        visemeTimer?.invalidate()
        visemeTimer = Timer.scheduledTimer(withTimeInterval: 0.28, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            guard self.isConnected, !self.isMuted else { return }

            // Randomly choose to "speak" or "pause"
            if Bool.random() {
                self.isSpeaking = true
                let visemes = ["A","E","O","U","M","F","L"]
                self.currentViseme = visemes.randomElement() ?? "A"
                self.status = "Speaking…"
            } else {
                self.currentViseme = "0"
                self.isSpeaking = false
                self.status = "Listening…"
            }
        }
    }

    func stopAutoVoice() {
        visemeTimer?.invalidate()
        visemeTimer = nil
        isSpeaking = false
        currentViseme = "0"
        status = "Ready"
    }

    // MARK: - API Key Management

    private func loadAPIKey() -> String? {
        // Try to load from environment variable
        if let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] {
            return apiKey
        }

        // Try to load from plist
        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path),
           let apiKey = dict["OPENAI_API_KEY"] as? String {
            return apiKey
        }

        // Try to load from UserDefaults (for development)
        return UserDefaults.standard.string(forKey: "OPENAI_API_KEY")
    }

    // MARK: - Legacy Hooks (for compatibility)

    func onAudioDeltaArrived() {
        // This is now handled by OpenAIRealtimeService
        let visemes = ["A","E","O","U","M","F","L"]
        currentViseme = visemes.randomElement() ?? "A"
        isSpeaking = true

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 300_000_000)
            if !isMuted {
                self.currentViseme = "0"
                self.isSpeaking = false
            }
        }
    }

    func onUserTranscript(_ text: String) {
        messages.append(ChatMessage(role: .user, text: text))
    }

    func onAssistantTranscript(_ text: String) {
        messages.append(ChatMessage(role: .assistant, text: text))
    }
}
