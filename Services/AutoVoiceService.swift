import Foundation
import Speech
import AVFoundation
import Combine

// MARK: - Auto Voice Service
@MainActor
class AutoVoiceService: NSObject, ObservableObject {
    static let shared = AutoVoiceService()

    // MARK: - Published Properties
    @Published var isListening = false
    @Published var isProcessing = false
    @Published var isSpeaking = false
    @Published var transcribedText = ""
    @Published var currentAmplitude: Float = 0.0
    @Published var error: String?
    @Published var conversationState: ConversationState = .idle
    @Published var fluencyMetrics = FluencyMetrics(
        wordsPerMinute: 0,
        pauseFrequency: 0,
        averagePauseDuration: 0,
        fillerWordUsage: 0,
        sentenceComplexity: 0,
        vocabularyDiversity: 0,
        pronunciationAccuracy: 0,
        intonationScore: 0,
        rhythmScore: 0,
        confidenceScore: 0,
        naturalness: 0,
        responseTime: 0,
        continuousSpeechDuration: 0
    )

    // MARK: - Audio Components
    private var audioEngine: AVAudioEngine?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let synthesizer = AVSpeechSynthesizer()
    private var audioPlayer: AVAudioPlayer?
    private var speechMeterTimer: Timer?
    private var synthesizerMeterTimer: Timer?

    // MARK: - Voice Analysis
    private var speechStartTime: Date?
    private var lastSpeechEndTime: Date?
    private var pauseCount = 0
    private var totalPauseDuration: TimeInterval = 0
    private var wordCount = 0
    private var uniqueWords = Set<String>()
    private var continuousSpeechTimer: Timer?
    private var silenceTimer: Timer?
    private var currentSpeechDuration: TimeInterval = 0

    // MARK: - Settings
    var settings = AutoVoiceSettings()
    private let openAIService = OpenAIService.shared

    // MARK: - Conversation Management
    private var conversationHistory: [ChatMessage] = []
    private var currentLesson: Lesson?
    private var currentScenario: ConversationScenario?

    enum ConversationState {
        case idle
        case listening
        case processing
        case speaking
        case waitingForResponse
    }

    // MARK: - Initialization
    override init() {
        super.init()
        synthesizer.delegate = self
        setupAudioSession()
        requestPermissions()
    }

    // MARK: - Setup Methods
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetoothA2DP])
            try audioSession.setActive(true)
        } catch {
            self.error = "Failed to setup audio session: \(error.localizedDescription)"
        }
    }

    private func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    print("✅ Speech recognition authorized")
                case .denied, .restricted:
                    self.error = "Speech recognition not authorized"
                    print("❌ Speech recognition denied/restricted")
                case .notDetermined:
                    self.error = "Speech recognition authorization not determined"
                    print("⚠️ Speech recognition not determined")
                @unknown default:
                    break
                }
            }
        }

        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                if granted {
                    print("✅ Microphone access granted")
                } else {
                    self.error = "Microphone access denied"
                    print("❌ Microphone access denied")
                }
            }
        }
    }
    
    // Note: Use SpeechService.shared.requestAuthorizations() directly instead

    // MARK: - Auto Voice Control
    func startAutoVoiceConversation(lesson: Lesson, scenario: ConversationScenario) {
        self.currentLesson = lesson
        self.currentScenario = scenario
        self.conversationHistory = []

        // Start with AI greeting based on scenario
        Task {
            await startConversationWithGreeting()
        }
    }

    private func startConversationWithGreeting() async {
        guard let scenario = currentScenario else { return }

        conversationState = .processing

        // Generate initial greeting from AI
        let systemMessage = ChatMessage(
            role: .system,
            content: "Start the conversation as \(scenario.aiRole) in the context: \(scenario.context). Greet naturally and prompt the student to respond."
        )

        do {
            let response = try await openAIService.generateChatResponse(
                messages: [systemMessage],
                language: currentLesson?.language ?? .spanish,
                level: currentLesson?.level ?? .beginner
            )

            conversationHistory.append(ChatMessage(role: .assistant, content: response.message))
            await speak(response.message)

            // After speaking, start listening
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if self.settings.autoStartRecording {
                    self.startListening()
                }
            }
        } catch {
            self.error = "Failed to start conversation: \(error.localizedDescription)"
        }
    }

    // MARK: - Speech Recognition
    func startListening() {
        guard !isListening else { return }

        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else { return }

        do {
            let inputNode = audioEngine.inputNode
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

            guard let recognitionRequest = recognitionRequest else { return }

            recognitionRequest.shouldReportPartialResults = true
            recognitionRequest.requiresOnDeviceRecognition = false

            // Track speech timing
            speechStartTime = Date()
            lastSpeechEndTime = nil
            pauseCount = 0
            totalPauseDuration = 0
            wordCount = 0
            uniqueWords.removeAll()

            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                guard let self = self else { return }

                if let result = result {
                    DispatchQueue.main.async {
                        self.processRecognitionResult(result)
                    }
                }

                if error != nil || (result?.isFinal ?? false) {
                    self.stopListening()
                }
            }

            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
                self?.recognitionRequest?.append(buffer)
                self?.analyzeAudioBuffer(buffer)
            }

            audioEngine.prepare()
            try audioEngine.start()

            isListening = true
            conversationState = .listening
            transcribedText = ""

            // Start silence detection timer
            startSilenceDetection()

        } catch {
            self.error = "Failed to start listening: \(error.localizedDescription)"
        }
    }

    func stopListening() {
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()

        isListening = false
        silenceTimer?.invalidate()
        continuousSpeechTimer?.invalidate()
        stopAudioPlayerMetering()
        stopSynthesizerMetering()
        currentAmplitude = 0

        // Calculate final metrics
        if let startTime = speechStartTime {
            updateFluencyMetrics(finalDuration: Date().timeIntervalSince(startTime))
        }

        // Process the transcribed text if auto-voice is enabled
        if settings.autoStartRecording && !transcribedText.isEmpty {
            Task {
                await processUserResponse()
            }
        }
    }

    // MARK: - Speech Processing
    private func processRecognitionResult(_ result: SFSpeechRecognitionResult) {
        let newTranscription = result.bestTranscription.formattedString
        transcribedText = newTranscription

        // Analyze for fluency
        analyzeTranscriptionForFluency(newTranscription)

        // Reset silence timer on new speech
        resetSilenceTimer()

        // Track continuous speech duration
        if continuousSpeechTimer == nil {
            continuousSpeechTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                Task { @MainActor in
                    self.currentSpeechDuration += 0.1
                    if self.currentSpeechDuration > self.fluencyMetrics.continuousSpeechDuration {
                        self.fluencyMetrics.continuousSpeechDuration = self.currentSpeechDuration
                    }
                }
            }
        }
    }

    private func analyzeTranscriptionForFluency(_ text: String) {
        let words = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        wordCount = words.count
        uniqueWords = Set(words.map { $0.lowercased() })

        // Calculate WPM
        if let startTime = speechStartTime {
            let duration = Date().timeIntervalSince(startTime) / 60.0
            if duration > 0 {
                fluencyMetrics.wordsPerMinute = Double(wordCount) / duration
            }
        }

        // Calculate vocabulary diversity
        if wordCount > 0 {
            fluencyMetrics.vocabularyDiversity = Double(uniqueWords.count) / Double(wordCount)
        }

        // Detect filler words
        let fillerWords = ["um", "uh", "like", "you know", "well", "so", "actually", "basically"]
        let fillerCount = words.filter { fillerWords.contains($0.lowercased()) }.count
        fluencyMetrics.fillerWordUsage = Double(fillerCount) / Double(max(wordCount, 1))

        // Calculate sentence complexity (average words per sentence)
        let sentences = text.components(separatedBy: CharacterSet(charactersIn: ".!?")).filter { !$0.isEmpty }
        if sentences.count > 0 {
            fluencyMetrics.sentenceComplexity = Double(wordCount) / Double(sentences.count)
        }
    }

    // MARK: - Silence Detection
    private func startSilenceDetection() {
        silenceTimer = Timer.scheduledTimer(withTimeInterval: settings.pauseThreshold, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                await self.handleSilence()
            }
        }
    }

    private func resetSilenceTimer() {
        silenceTimer?.invalidate()
        startSilenceDetection()
    }

    @MainActor
    private func handleSilence() async {
        pauseCount += 1
        if let lastEnd = lastSpeechEndTime {
            totalPauseDuration += Date().timeIntervalSince(lastEnd)
        }
        lastSpeechEndTime = Date()

        continuousSpeechTimer?.invalidate()
        continuousSpeechTimer = nil
        currentSpeechDuration = 0

        // If silence is too long, stop listening and process
        if settings.autoStartRecording {
            stopListening()
        }
    }

    // MARK: - Response Processing
    private func processUserResponse() async {
        guard !transcribedText.isEmpty else { return }

        conversationState = .processing
        conversationHistory.append(ChatMessage(role: .user, content: transcribedText))

        do {
            // Get AI response
            guard let lesson = currentLesson,
                  let _ = currentScenario else { return }

            let response = try await openAIService.generateLanguageTeacherResponse(
                userMessage: transcribedText,
                language: lesson.language.rawValue,
                level: lesson.level.rawValue,
                conversationHistory: conversationHistory
            )

            conversationHistory.append(ChatMessage(role: .assistant, content: response.message))

            // Speak the response
            await speak(response.message)

            // Show feedback if enabled
            if settings.provideFeedbackDuringConversation, let feedback = response.feedback {
                showInlineFeedback(feedback)
            }

            // Display feedback if available
            // Note: fluencyTips would need to be extracted from feedback if needed

        } catch {
            self.error = "Failed to process response: \(error.localizedDescription)"
        }
    }

    // MARK: - Text to Speech
    func speakText(_ text: String) async {
        await speak(text)
    }

    private func speak(_ text: String) async {
        print("speak() called with text: \(text)")  // Debug print - REMOVE AFTER TESTING
        
        conversationState = .speaking
        isSpeaking = true
        stopAudioPlayerMetering()
        stopSynthesizerMetering()
        await MainActor.run {
            self.currentAmplitude = 0
        }

        // Temporarily disable OpenAI TTS to force system fallback for testing - REMOVE AFTER CONFIRMING SYSTEM TTS WORKS
        /*
        // Use OpenAI TTS for natural, fluent voice with minimal latency
        do {
            // Optimized settings for sub-500ms response
            let audioData = try await openAIService.synthesizeSpeech(
                text: text,
                voice: "nova",  // Most natural and fluent voice
                speed: 1.15  // Optimal speed for natural conversation flow
            )

            // Immediate playback for minimal latency
            try await MainActor.run {
                // Use AVAudioPlayer for better quality and lower CPU usage
                audioPlayer = try AVAudioPlayer(data: audioData)
                audioPlayer?.delegate = self
                audioPlayer?.enableRate = true
                audioPlayer?.rate = 1.0  // Normal playback rate
                audioPlayer?.volume = 1.0
                audioPlayer?.isMeteringEnabled = true
                
                // Prepare and play immediately
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
            }
            startAudioPlayerMetering()

        } catch {
            print("TTS error: \(error.localizedDescription)")
            // Optimized fallback to system TTS
            await MainActor.run {
                let utterance = AVSpeechUtterance(string: text)
                
                // Optimized for natural, fluent speech
                utterance.rate = 0.54  // Balanced speed for clarity and fluency
                utterance.pitchMultiplier = 1.08  // Natural pitch variation
                utterance.volume = 1.0
                utterance.preUtteranceDelay = 0.0  // No delay
                utterance.postUtteranceDelay = 0.0  // No delay
                
                // Use best available voice
                if let voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.Samantha-compact") {
                    utterance.voice = voice  // Natural US English female voice
                } else if let voice = AVSpeechSynthesisVoice(language: "en-US") {
                    utterance.voice = voice
                }

                synthesizer.speak(utterance)
            }
            startSynthesizerMetering()
        }
        */
        
        // Force system TTS for testing - REMOVE AFTER TESTING
        await MainActor.run {
            let utterance = AVSpeechUtterance(string: text)
            
            // Optimized for natural, fluent speech
            utterance.rate = 0.54  // Balanced speed for clarity and fluency
            utterance.pitchMultiplier = 1.08  // Natural pitch variation
            utterance.volume = 1.0
            utterance.preUtteranceDelay = 0.0  // No delay
            utterance.postUtteranceDelay = 0.0  // No delay
            
            // Use best available voice
            if let voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.Samantha-compact") {
                utterance.voice = voice  // Natural US English female voice
            } else if let voice = AVSpeechSynthesisVoice(language: "en-US") {
                utterance.voice = voice
            }

            synthesizer.speak(utterance)
            print("System TTS triggered for: \(text)")  // Debug print - REMOVE AFTER TESTING
        }
        startSynthesizerMetering()
    }

    private func startAudioPlayerMetering() {
        speechMeterTimer?.invalidate()
        guard audioPlayer != nil else { return }
        speechMeterTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: { [weak self] _ in
            Task { @MainActor in
                guard let self = self, let player = self.audioPlayer else { return }
                player.updateMeters()
                let power = max(player.averagePower(forChannel: 0), -80)
                let level = pow(10, power / 20)
                self.currentAmplitude = Float(level)
            }
        })
    }

    private func stopAudioPlayerMetering() {
        speechMeterTimer?.invalidate()
        speechMeterTimer = nil
    }

    private func startSynthesizerMetering() {
        synthesizerMeterTimer?.invalidate()
        synthesizerMeterTimer = Timer.scheduledTimer(withTimeInterval: 0.12, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.currentAmplitude = Float.random(in: 0.18...0.65)
            }
        }
    }

    private func stopSynthesizerMetering() {
        synthesizerMeterTimer?.invalidate()
        synthesizerMeterTimer = nil
    }

    // MARK: - Audio Analysis
    private func analyzeAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }

        let frames = buffer.frameLength
        var sum: Float = 0.0

        for i in 0..<Int(frames) {
            sum += abs(channelData[i])
        }

        let amplitude = sum / Float(frames)

        DispatchQueue.main.async {
            self.currentAmplitude = amplitude
        }
    }

    // MARK: - Metrics Update
    private func updateFluencyMetrics(finalDuration: TimeInterval) {
        // Update pause metrics
        if pauseCount > 0 && finalDuration > 0 {
            fluencyMetrics.pauseFrequency = Double(pauseCount) / (finalDuration / 60.0)
            fluencyMetrics.averagePauseDuration = totalPauseDuration / Double(pauseCount)
        }

        // Response time (time from AI finishing to user starting)
        if let startTime = speechStartTime, let _ = lastSpeechEndTime {
            fluencyMetrics.responseTime = startTime.timeIntervalSince(lastSpeechEndTime!)
        }

        // Calculate confidence score based on various factors
        var confidenceScore = 5.0
        if fluencyMetrics.wordsPerMinute > 120 { confidenceScore += 1 }
        if fluencyMetrics.pauseFrequency < 5 { confidenceScore += 1 }
        if fluencyMetrics.continuousSpeechDuration > 10 { confidenceScore += 1 }
        if fluencyMetrics.vocabularyDiversity > 0.5 { confidenceScore += 1 }
        if fluencyMetrics.fillerWordUsage < 0.1 { confidenceScore += 1 }

        fluencyMetrics.confidenceScore = min(10, confidenceScore)
    }

    // MARK: - UI Feedback
    private func showInlineFeedback(_ feedback: ConversationFeedback) {
        // This would be handled by the UI layer
        // Post notification or update published property
        NotificationCenter.default.post(
            name: .showConversationFeedback,
            object: feedback
        )
    }

    // Commented out - would need to be updated to work with new feedback structure
    /*
    private func showFluencyTips(_ tips: [String]) {
        NotificationCenter.default.post(
            name: .showFluencyTips,
            object: tips
        )
    }
    */

    // MARK: - Shadow Speaking Mode
    func startShadowSpeaking(text: String) async {
        // Speak the text
        await speak(text)

        // After a brief delay, start recording for echo
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.settings.echoModeEnabled = true
            self.startListening()

            // Stop after the expected duration
            let expectedDuration = Double(text.split(separator: " ").count) / 150.0 * 60.0 // Rough estimate
            DispatchQueue.main.asyncAfter(deadline: .now() + expectedDuration + 2) {
                self.stopListening()
                self.compareShadowSpeaking(original: text, spoken: self.transcribedText)
            }
        }
    }

    private func compareShadowSpeaking(original: String, spoken: String) {
        // Calculate similarity
        let originalWords = Set(original.lowercased().components(separatedBy: .whitespacesAndNewlines))
        let spokenWords = Set(spoken.lowercased().components(separatedBy: .whitespacesAndNewlines))

        let commonWords = originalWords.intersection(spokenWords)
        let accuracy = Double(commonWords.count) / Double(originalWords.count)

        fluencyMetrics.pronunciationAccuracy = accuracy

        // Post results
        NotificationCenter.default.post(
            name: .shadowSpeakingResults,
            object: ["accuracy": accuracy, "original": original, "spoken": spoken]
        )
    }
}

// MARK: - AVSpeechSynthesizerDelegate
extension AutoVoiceService: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
            self.conversationState = .waitingForResponse
            self.stopSynthesizerMetering()
            self.currentAmplitude = 0

            // Auto-start listening after AI speaks
            if self.settings.autoStartRecording {
                try? await Task.sleep(nanoseconds: 500_000_000)
                self.startListening()
            }
        }
    }
}

// MARK: - AVAudioPlayerDelegate
extension AutoVoiceService: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            self.isSpeaking = false
            self.conversationState = .waitingForResponse
            self.stopAudioPlayerMetering()
            self.currentAmplitude = 0

            if self.settings.autoStartRecording {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.startListening()
                }
            }
        }
    }
}

// MARK: - Supporting Types
struct FluencyMetrics {
    var wordsPerMinute: Double
    var pauseFrequency: Double
    var averagePauseDuration: Double
    var fillerWordUsage: Double
    var sentenceComplexity: Double
    var vocabularyDiversity: Double
    var pronunciationAccuracy: Double
    var intonationScore: Double
    var rhythmScore: Double
    var confidenceScore: Double
    var naturalness: Double
    var responseTime: Double
    var continuousSpeechDuration: Double
}

struct AutoVoiceSettings {
    var isEnabled: Bool = false
    var autoStartRecording: Bool = true
    var speakingRate: Float = 0.5
    var speechRate: Float = 0.5
    var pitchMultiplier: Float = 1.0
    var responseDelay: TimeInterval = 0.5
    var listeningTimeout: TimeInterval = 3.0
    var voiceLanguage: String = "en-US"
    var enableHapticFeedback: Bool = true
    var enableVisualFeedback: Bool = true
    var silenceThreshold: TimeInterval = 1.5
    var pauseThreshold: TimeInterval = 1.5
    var provideFeedbackDuringConversation: Bool = false
    var echoModeEnabled: Bool = false
    var interruptionAllowed: Bool = true
    var voiceDetectionSensitivity: Double = 0.5
    var useNaturalPauses: Bool = true
    var backgroundNoiseReduction: Bool = true
    var autoCorrectPronunciation: Bool = false
    var recordingQuality: RecordingQuality = .high

    enum RecordingQuality: String, CaseIterable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        case maximum = "Maximum"
    }
}

struct ChatMessage {
    enum Role {
        case user
        case assistant
        case system
    }

    let role: Role
    let content: String
    let timestamp: Date = Date()
}

struct ConversationScenario: Identifiable {
    let id: String
    let title: String
    let description: String
    let difficulty: String
    let context: String
    let suggestedPhrases: [String]
    let objectives: [String]
    let roleYouPlay: String
    let aiRole: String
    let autoVoiceEnabled: Bool

    init(id: String, title: String, description: String, difficulty: String,
         context: String, suggestedPhrases: [String], objectives: [String],
         roleYouPlay: String = "Student", aiRole: String = "Teacher",
         autoVoiceEnabled: Bool = false) {
        self.id = id
        self.title = title
        self.description = description
        self.difficulty = difficulty
        self.context = context
        self.suggestedPhrases = suggestedPhrases
        self.objectives = objectives
        self.roleYouPlay = roleYouPlay
        self.aiRole = aiRole
        self.autoVoiceEnabled = autoVoiceEnabled
    }
}

