import Foundation
import AVFoundation
import Speech

// MARK: - Pronunciation Drilling Service
// Evidence Level: Limited (Tier 4)
// Use: Minimal drilling, focus on meaningful communication
// Best for: Specific sounds that are difficult, not isolated from context

@MainActor
class PronunciationDrillingService: NSObject, ObservableObject {
    static let shared = PronunciationDrillingService()

    @Published var isRecording = false
    @Published var audioLevel: Float = 0.0
    @Published var pronunciationFeedback: PronunciationFeedback?
    @Published var drillProgress: DrillProgress?

    private var audioEngine = AVAudioEngine()
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioSession = AVAudioSession.sharedInstance()

    private var targetPhrase: String = ""
    private var targetLanguage: Language = .spanish
    private var attempts: [PronunciationAttempt] = []

    override private init() {
        super.init()
    }

    // MARK: - Start Pronunciation Drill

    func startDrill(phrase: String, language: Language, context: String) {
        targetPhrase = phrase
        targetLanguage = language
        attempts = []

        drillProgress = DrillProgress(
            phrase: phrase,
            language: language,
            context: context,
            totalAttempts: 0,
            successfulAttempts: 0,
            specificSoundsToFocus: extractDifficultSounds(phrase: phrase, language: language)
        )

        // Speak the target phrase first
        speakPhrase(phrase, language: language, rate: 0.3) // Very slow for learning
    }

    // MARK: - Record and Analyze Pronunciation

    func startRecording() async throws {
        guard !isRecording else { return }

        // Request permissions
        let authorized = await requestSpeechRecognition()
        guard authorized else {
            throw PronunciationError.permissionDenied
        }

        // Setup speech recognizer for target language
        let languageCode = getLanguageCode(for: targetLanguage)
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: languageCode))

        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            throw PronunciationError.recognizerUnavailable
        }

        // Configure audio session
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw PronunciationError.recognitionFailed
        }

        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.taskHint = .dictation

        // Setup audio engine
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)

            // Calculate audio level for visual feedback
            let level = self.calculateAudioLevel(buffer: buffer)
            Task { @MainActor in
                self.audioLevel = level
            }
        }

        audioEngine.prepare()
        try audioEngine.start()

        // Start recognition task
        recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }

            if let result = result {
                let transcription = result.bestTranscription.formattedString

                Task { @MainActor in
                    // Analyze pronunciation as user speaks
                    await self.analyzePronunciation(transcription: transcription, isFinal: result.isFinal)
                }
            }

            if error != nil || result?.isFinal == true {
                Task { @MainActor in
                    self.stopRecording()
                }
            }
        }

        isRecording = true
    }

    func stopRecording() {
        guard isRecording else { return }

        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()

        recognitionRequest = nil
        recognitionTask = nil

        isRecording = false
        audioLevel = 0.0
    }

    // MARK: - Pronunciation Analysis

    private func analyzePronunciation(transcription: String, isFinal: Bool) async {
        guard isFinal else { return }

        let similarity = calculateSimilarity(target: targetPhrase, spoken: transcription)
        let specificIssues = identifySpecificIssues(target: targetPhrase, spoken: transcription, language: targetLanguage)

        let attempt = PronunciationAttempt(
            transcription: transcription,
            similarity: similarity,
            timestamp: Date(),
            issues: specificIssues
        )

        attempts.append(attempt)

        // Update progress
        if var progress = drillProgress {
            progress.totalAttempts += 1
            if similarity >= 0.8 { // 80% similarity threshold
                progress.successfulAttempts += 1
            }
            drillProgress = progress
        }

        // Generate feedback
        pronunciationFeedback = PronunciationFeedback(
            score: similarity,
            transcription: transcription,
            targetPhrase: targetPhrase,
            specificIssues: specificIssues,
            encouragement: generateEncouragement(score: similarity, attempt: attempts.count),
            nextSteps: generateNextSteps(score: similarity, issues: specificIssues)
        )

        // If user is struggling, provide targeted help
        if attempts.count >= 3 && similarity < 0.6 {
            await provideTargetedHelp(issues: specificIssues)
        }
    }

    // MARK: - Similarity Calculation

    private func calculateSimilarity(target: String, spoken: String) -> Double {
        let targetNormalized = target.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let spokenNormalized = spoken.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        // Levenshtein distance for similarity
        let distance = levenshteinDistance(targetNormalized, spokenNormalized)
        let maxLength = Double(max(targetNormalized.count, spokenNormalized.count))

        guard maxLength > 0 else { return 1.0 }

        let similarity = 1.0 - (Double(distance) / maxLength)
        return max(0.0, min(1.0, similarity))
    }

    private func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        let s1Array = Array(s1)
        let s2Array = Array(s2)
        let s1Length = s1Array.count
        let s2Length = s2Array.count

        var matrix = Array(repeating: Array(repeating: 0, count: s2Length + 1), count: s1Length + 1)

        for i in 0...s1Length {
            matrix[i][0] = i
        }

        for j in 0...s2Length {
            matrix[0][j] = j
        }

        for i in 1...s1Length {
            for j in 1...s2Length {
                let cost = s1Array[i - 1] == s2Array[j - 1] ? 0 : 1
                matrix[i][j] = Swift.min(
                    matrix[i - 1][j] + 1,
                    matrix[i][j - 1] + 1,
                    matrix[i - 1][j - 1] + cost
                )
            }
        }

        return matrix[s1Length][s2Length]
    }

    // MARK: - Issue Identification

    private func identifySpecificIssues(target: String, spoken: String, language: Language) -> [PronunciationIssue] {
        var issues: [PronunciationIssue] = []

        // Language-specific pronunciation challenges
        switch language {
        case .spanish, .spanishSpain, .spanishLatinAmerica:
            issues += checkSpanishPronunciation(target: target, spoken: spoken)
        case .french:
            issues += checkFrenchPronunciation(target: target, spoken: spoken)
        case .german:
            issues += checkGermanPronunciation(target: target, spoken: spoken)
        default:
            break
        }

        return issues
    }

    private func checkSpanishPronunciation(target: String, spoken: String) -> [PronunciationIssue] {
        var issues: [PronunciationIssue] = []

        // Check for common Spanish pronunciation issues
        let targetLower = target.lowercased()
        let spokenLower = spoken.lowercased()

        // Rolled R
        if targetLower.contains("rr") || targetLower.contains("r ") || targetLower.hasPrefix("r") {
            if !spokenLower.contains("r") {
                issues.append(PronunciationIssue(
                    soundPattern: "R/RR",
                    description: "Spanish 'R' should be rolled or tapped",
                    tip: "Place tongue behind teeth and push air to make it vibrate",
                    exampleWords: ["perro", "carro", "rosa"]
                ))
            }
        }

        // ñ sound
        if targetLower.contains("ñ") && !spokenLower.contains("ñ") {
            issues.append(PronunciationIssue(
                soundPattern: "Ñ",
                description: "The 'ñ' sounds like 'ny' in 'canyon'",
                tip: "Say 'canyon' and focus on the 'ny' sound",
                exampleWords: ["niño", "año", "señor"]
            ))
        }

        // J/G (before e,i) - guttural H
        if (targetLower.contains("j") || targetLower.contains("ge") || targetLower.contains("gi")) {
            issues.append(PronunciationIssue(
                soundPattern: "J/GE/GI",
                description: "Spanish 'J' and 'G' (before e,i) sound like a strong 'H'",
                tip: "Make a strong breathy sound from the back of your throat",
                exampleWords: ["jugar", "gente", "gitarra"]
            ))
        }

        return issues
    }

    private func checkFrenchPronunciation(target: String, spoken: String) -> [PronunciationIssue] {
        var issues: [PronunciationIssue] = []
        let targetLower = target.lowercased()

        // French R (guttural)
        if targetLower.contains("r") {
            issues.append(PronunciationIssue(
                soundPattern: "R",
                description: "French 'R' is guttural, from the back of the throat",
                tip: "Gargle gently, then pronounce 'R' from that position",
                exampleWords: ["rouge", "mer", "partir"]
            ))
        }

        // Nasal vowels
        if targetLower.contains("on") || targetLower.contains("an") || targetLower.contains("en") || targetLower.contains("in") {
            issues.append(PronunciationIssue(
                soundPattern: "Nasal Vowels",
                description: "French has nasal vowels - sound comes through nose",
                tip: "Say the vowel while pinching your nose, then release",
                exampleWords: ["bon", "dans", "vin", "un"]
            ))
        }

        return issues
    }

    private func checkGermanPronunciation(target: String, spoken: String) -> [PronunciationIssue] {
        var issues: [PronunciationIssue] = []
        let targetLower = target.lowercased()

        // CH sounds
        if targetLower.contains("ch") {
            issues.append(PronunciationIssue(
                soundPattern: "CH",
                description: "German 'CH' can be soft (after e,i) or hard (after a,o,u)",
                tip: "Soft: like 'h' in 'huge'. Hard: like clearing your throat",
                exampleWords: ["ich", "nicht", "Buch", "auch"]
            ))
        }

        // Umlauts
        if targetLower.contains("ä") || targetLower.contains("ö") || targetLower.contains("ü") {
            issues.append(PronunciationIssue(
                soundPattern: "Umlauts (Ä, Ö, Ü)",
                description: "Umlauts change vowel pronunciation significantly",
                tip: "Ä = 'eh', Ö = purse lips and say 'eh', Ü = purse lips and say 'ee'",
                exampleWords: ["schön", "für", "Mädchen"]
            ))
        }

        return issues
    }

    // MARK: - Feedback Generation

    private func extractDifficultSounds(phrase: String, language: Language) -> [String] {
        var sounds: [String] = []

        switch language {
        case .spanish, .spanishSpain, .spanishLatinAmerica:
            if phrase.lowercased().contains("rr") { sounds.append("RR (rolled)") }
            if phrase.lowercased().contains("ñ") { sounds.append("Ñ") }
            if phrase.lowercased().contains("j") { sounds.append("J (like H)") }
        case .french:
            if phrase.lowercased().contains("r") { sounds.append("R (guttural)") }
            if phrase.lowercased().contains("on") || phrase.lowercased().contains("an") {
                sounds.append("Nasal vowels")
            }
        case .german:
            if phrase.lowercased().contains("ch") { sounds.append("CH") }
            if phrase.lowercased().contains("ü") || phrase.lowercased().contains("ö") {
                sounds.append("Umlauts")
            }
        default:
            break
        }

        return sounds
    }

    private func generateEncouragement(score: Double, attempt: Int) -> String {
        switch (score, attempt) {
        case (0.9...1.0, _):
            return "Excellent pronunciation! You sound like a native speaker! 🎉"
        case (0.8..<0.9, _):
            return "Great job! Your pronunciation is very clear! 👏"
        case (0.7..<0.8, _):
            return "Good effort! You're getting there! Keep practicing! 💪"
        case (0.6..<0.7, _):
            return "Nice try! Focus on the specific sounds and try again! 🎯"
        case (_, 1):
            return "First try! Don't worry, pronunciation takes practice. Listen and try again! 🎧"
        case (_, 2...3):
            return "You're improving! Keep going! 🚀"
        default:
            return "Keep practicing! Every attempt makes you better! 🌟"
        }
    }

    private func generateNextSteps(score: Double, issues: [PronunciationIssue]) -> [String] {
        var steps: [String] = []

        if score < 0.7 {
            steps.append("Listen to the phrase again and focus on each word")
            steps.append("Break the phrase into smaller parts and practice each separately")
        }

        if !issues.isEmpty {
            for issue in issues.prefix(2) { // Focus on top 2 issues
                steps.append("Practice the '\(issue.soundPattern)' sound: \(issue.tip)")
            }
        }

        if score >= 0.8 {
            steps.append("Try speaking faster while maintaining clarity")
            steps.append("Practice this phrase in a full conversation")
        }

        return steps
    }

    private func provideTargetedHelp(issues: [PronunciationIssue]) async {
        guard let firstIssue = issues.first else { return }

        // Provide slow, exaggerated pronunciation of the problem sound
        if let exampleWord = firstIssue.exampleWords.first {
            speakPhrase(exampleWord, language: targetLanguage, rate: 0.2) // Very slow
        }
    }

    // MARK: - Helper Methods

    private func speakPhrase(_ phrase: String, language: Language, rate: Float = 0.45) {
        let synthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: phrase)
        utterance.rate = rate
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0

        if let languageCode = getLanguageCode(for: language),
           let voice = AVSpeechSynthesisVoice(language: languageCode) {
            utterance.voice = voice
        }

        synthesizer.speak(utterance)
    }

    private func getLanguageCode(for language: Language) -> String {
        switch language {
        case .englishUS: return "en-US"
        case .englishUK: return "en-GB"
        case .spanish, .spanishSpain: return "es-ES"
        case .spanishLatinAmerica: return "es-MX"
        case .french: return "fr-FR"
        case .german: return "de-DE"
        case .italian: return "it-IT"
        case .portuguese: return "pt-PT"
        case .japanese: return "ja-JP"
        case .chinese, .chineseMandarin: return "zh-CN"
        case .korean: return "ko-KR"
        case .arabic: return "ar-SA"
        case .russian: return "ru-RU"
        }
    }

    private func calculateAudioLevel(buffer: AVAudioPCMBuffer) -> Float {
        guard let channelData = buffer.floatChannelData else { return 0.0 }

        let channelDataValue = channelData.pointee
        let channelDataValueArray = stride(from: 0, to: Int(buffer.frameLength), by: buffer.stride)
            .map { channelDataValue[$0] }

        let rms = sqrt(channelDataValueArray.map { $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))
        return min(max(rms * 20, 0), 1) // Normalize to 0-1 range
    }

    private func requestSpeechRecognition() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
}

// MARK: - Supporting Types

struct PronunciationFeedback {
    let score: Double
    let transcription: String
    let targetPhrase: String
    let specificIssues: [PronunciationIssue]
    let encouragement: String
    let nextSteps: [String]

    var scorePercentage: Int {
        Int(score * 100)
    }

    var scoreEmoji: String {
        switch score {
        case 0.9...1.0: return "🌟"
        case 0.8..<0.9: return "⭐"
        case 0.7..<0.8: return "👍"
        case 0.6..<0.7: return "💪"
        default: return "🎯"
        }
    }
}

struct PronunciationIssue: Identifiable {
    let id = UUID()
    let soundPattern: String
    let description: String
    let tip: String
    let exampleWords: [String]
}

struct PronunciationAttempt {
    let transcription: String
    let similarity: Double
    let timestamp: Date
    let issues: [PronunciationIssue]
}

struct DrillProgress {
    let phrase: String
    let language: Language
    let context: String
    var totalAttempts: Int
    var successfulAttempts: Int
    let specificSoundsToFocus: [String]

    var successRate: Double {
        guard totalAttempts > 0 else { return 0 }
        return Double(successfulAttempts) / Double(totalAttempts)
    }

    var isComplete: Bool {
        successfulAttempts >= 3 || (totalAttempts >= 3 && successRate >= 0.8)
    }
}

enum PronunciationError: Error {
    case permissionDenied
    case recognizerUnavailable
    case recognitionFailed
    case audioEngineError
}
