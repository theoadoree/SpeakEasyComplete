import Foundation
import SwiftUI
import AVFoundation

// MARK: - Lesson Models

struct Lesson: Identifiable, Codable {
    let id = UUID()
    let language: Language
    let level: ProficiencyLevel
    let category: LessonCategory
    let title: String
    let description: String
    let duration: Int // minutes
    let objectives: [String]
    let isCompleted: Bool = false
    let completionDate: Date?

    enum CodingKeys: String, CodingKey {
        case language, level, category, title, description, duration, objectives, isCompleted, completionDate
    }
}

// MARK: - View Model

@MainActor
class LessonViewModel: ObservableObject {
    @Published var currentLesson: Lesson?
    @Published var lessonContent: LessonContent?
    @Published var isLoading = false
    @Published var error: String?
    @Published var currentSession: PracticeSession?
    @Published var isSpeaking = false
    @Published var userInput = ""
    @Published var conversationHistory: [ConversationTurn] = []
    @Published var isVoiceModeEnabled = false

    private let openAIService = OpenAIService.shared
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var audioEngine = AVAudioEngine()
    private var speechRecognizer: SpeechRecognizer?
    private let autoVoiceService = AutoVoiceService.shared

    struct ConversationTurn: Identifiable {
        let id = UUID()
        let speaker: Speaker
        let text: String
        let translation: String?
        let timestamp: Date

        enum Speaker {
            case user
            case teacher
        }
    }

    // MARK: - Lesson Management

    func loadLesson(_ lesson: Lesson) async {
        currentLesson = lesson
        isLoading = true
        error = nil

        do {
            // Generate lesson content using OpenAI
            lessonContent = try await openAIService.generateLesson(
                language: lesson.language.apiLanguageCode,
                level: lesson.level.rawValue,
                topic: lesson.category.rawValue
            )
        } catch {
            // Fallback to mock data if API fails
            print("OpenAI API failed: \(error.localizedDescription). Using mock data.")
            lessonContent = createMockLessonContent(for: lesson)
        }

        // Start practice session
        currentSession = PracticeSession(
            lesson: lesson,
            startTime: Date()
        )

        isLoading = false
    }

    private func createMockLessonContent(for lesson: Lesson) -> LessonContent {
        // Create mock vocabulary based on language
        let isSpanish = [.spanish, .spanishSpain, .spanishLatinAmerica].contains(lesson.language)
        let isEnglish = [.englishUS, .englishUK].contains(lesson.language)

        let vocabulary: [VocabularyItem] = [
            VocabularyItem(
                word: isSpanish ? "Hola" : (isEnglish ? "Hello" : "Bonjour"),
                pronunciation: isSpanish ? "OH-lah" : (isEnglish ? "heh-LOH" : "bon-ZHOOR"),
                translation: isEnglish ? "Hello" : (isSpanish ? "Hello" : "Hello"),
                example: isSpanish ? "¡Hola! ¿Cómo estás?" : (isEnglish ? "Hello! How are you?" : "Bonjour! Comment allez-vous?")
            ),
            VocabularyItem(
                word: isSpanish ? "Gracias" : (isEnglish ? "Thank you" : "Merci"),
                pronunciation: isSpanish ? "GRAH-see-ahs" : (isEnglish ? "thank YOO" : "mer-SEE"),
                translation: "Thank you",
                example: isSpanish ? "Muchas gracias por tu ayuda" : (isEnglish ? "Thank you very much for your help" : "Merci beaucoup pour votre aide")
            ),
            VocabularyItem(
                word: isSpanish ? "Por favor" : (isEnglish ? "Please" : "S'il vous plaît"),
                pronunciation: isSpanish ? "pohr fah-VOHR" : (isEnglish ? "PLEEZ" : "seel voo PLEH"),
                translation: "Please",
                example: isSpanish ? "Un café, por favor" : (isEnglish ? "A coffee, please" : "Un café, s'il vous plaît")
            )
        ]

        let grammar = GrammarPoint(
            title: "Basic \(lesson.category.rawValue) Phrases",
            explanation: "These are essential phrases for everyday \(lesson.category.rawValue) situations.",
            examples: [
                isSpanish ? "¿Hablas inglés?" : (isEnglish ? "Do you speak English?" : "Parlez-vous anglais?"),
                isSpanish ? "No entiendo" : (isEnglish ? "I don't understand" : "Je ne comprends pas"),
                isSpanish ? "¿Dónde está...?" : (isEnglish ? "Where is...?" : "Où est...?")
            ]
        )

        let dialogue: [DialogueLine] = [
            DialogueLine(
                speaker: "A",
                text: isSpanish ? "¡Hola! ¿Cómo estás?" : (isEnglish ? "Hello! How are you?" : "Bonjour! Comment allez-vous?"),
                translation: "Hello! How are you?"
            ),
            DialogueLine(
                speaker: "B",
                text: isSpanish ? "Muy bien, gracias. ¿Y tú?" : (isEnglish ? "Very well, thanks. And you?" : "Très bien, merci. Et vous?"),
                translation: "Very well, thanks. And you?"
            )
        ]

        return LessonContent(
            title: "\(lesson.language.rawValue) - \(lesson.category.rawValue)",
            vocabulary: vocabulary,
            grammar: grammar,
            dialogue: dialogue,
            culturalTip: "When greeting people in \(lesson.language.apiLanguageCode), it's customary to make eye contact and smile!",
            summary: "This lesson covers basic \(lesson.category.rawValue) vocabulary and phrases."
        )
    }

    // MARK: - Speech Functions

    func speakText(_ text: String, language: Language) {
        guard !isSpeaking else { return }

        isSpeaking = true

        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.45 // Slower for language learning
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0

        // Set language voice
        if let languageCode = getLanguageCode(for: language),
           let voice = AVSpeechSynthesisVoice(language: languageCode) {
            utterance.voice = voice
        }

        speechSynthesizer.speak(utterance)

        // Monitor when speech completes
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(text.count) * 0.06) {
            self.isSpeaking = false
        }
    }

    func stopSpeaking() {
        speechSynthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
    }

    // MARK: - Conversation Management

    func sendUserMessage(_ message: String) async {
        // Add user message to history
        conversationHistory.append(ConversationTurn(
            speaker: .user,
            text: message,
            translation: nil,
            timestamp: Date()
        ))

        isLoading = true

        do {
            // Get AI response
            let response = try await openAIService.generateConversationResponse(
                language: currentLesson?.language.rawValue ?? "Spanish",
                context: currentLesson?.category.rawValue ?? "General",
                userInput: message,
                level: currentLesson?.level.rawValue ?? "Beginner"
            )

            // Add teacher response to history
            conversationHistory.append(ConversationTurn(
                speaker: .teacher,
                text: response.response,
                translation: response.responseTranslation,
                timestamp: Date()
            ))

            // Speak the response
            if let language = currentLesson?.language {
                speakText(response.response, language: language)
            }

            // Add feedback to session
            if currentSession != nil {
                for correction in response.corrections {
                    currentSession?.feedback.append(SessionFeedback(
                        timestamp: Date(),
                        type: .grammar,
                        content: correction.error,
                        suggestion: correction.correction
                    ))
                }
            }
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Voice Mode Control

    func toggleVoiceMode() {
        isVoiceModeEnabled.toggle()

        if isVoiceModeEnabled {
            // Start voice mode - begin listening
            autoVoiceService.startListening()
        } else {
            // Stop voice mode
            autoVoiceService.stopListening()
        }
    }

    func sendVoiceMessage(_ text: String) async {
        // Use the same sendUserMessage logic
        await sendUserMessage(text)

        // After AI responds, automatically speak if voice mode is active
        if isVoiceModeEnabled, let lastTurn = conversationHistory.last, lastTurn.speaker == .teacher {
            // Speak using AutoVoiceService for better quality
            Task {
                await autoVoiceService.speakText(lastTurn.text)

                // Auto-restart listening after AI finishes speaking
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    if self.isVoiceModeEnabled && !self.autoVoiceService.isSpeaking {
                        self.autoVoiceService.startListening()
                    }
                }
            }
        }
    }

    // MARK: - Helper Functions

    private func getLanguageCode(for language: Language) -> String? {
        switch language {
        case .englishUS: return "en-US"
        case .englishUK: return "en-GB"
        case .spanish, .spanishSpain: return "es-ES"
        case .spanishLatinAmerica: return "es-MX"
        case .spanishCaribbean: return "es-PR"
        case .portugueseBrazil: return "pt-BR"
        case .portuguesePortugal, .portuguese: return "pt-PT"
        case .chineseMandarin, .chinese: return "zh-CN"
        case .chineseCantonese: return "zh-HK"
        case .french: return "fr-FR"
        case .german: return "de-DE"
        case .italian: return "it-IT"
        case .japanese: return "ja-JP"
        case .korean: return "ko-KR"
        case .arabic: return "ar-SA"
        case .russian: return "ru-RU"
        case .hindi: return "hi-IN"
        case .dutch: return "nl-NL"
        case .swedish: return "sv-SE"
        case .polish: return "pl-PL"
        case .turkish: return "tr-TR"
        case .vietnamese: return "vi-VN"
        case .thai: return "th-TH"
        }
    }

    func completeSession() {
        currentSession?.endTime = Date()

        // Calculate and save score
        if let session = currentSession {
            let duration = session.endTime?.timeIntervalSince(session.startTime) ?? 0
            let minutesPracticed = Int(duration / 60)

            // Simple scoring: 10 points per minute + bonus for no errors
            var score = minutesPracticed * 10
            if session.feedback.isEmpty {
                score += 50 // Perfect bonus
            }
            currentSession?.score = score
        }
    }
}

// MARK: - Speech Recognition Placeholder

class SpeechRecognizer: ObservableObject {
    // Placeholder for speech recognition
    // In production, implement using Speech framework
    @Published var recognizedText = ""
    @Published var isListening = false
}

// MARK: - Additional Types for Fluency Features

extension Lesson {
    // Type aliases are not needed as LessonCategory is already defined above

    static func getAllLessons() -> [Lesson] {
        // Sample lessons for demonstration
        return [
            Lesson(
                language: .spanish,
                level: .beginner,
                category: .greetings,
                title: "Basic Greetings",
                description: "Learn essential greetings and introductions",
                duration: 15,
                objectives: ["Greet people formally and informally", "Introduce yourself"],
                completionDate: nil
            ),
            Lesson(
                language: .spanish,
                level: .elementary,
                category: .food,
                title: "Ordering Food",
                description: "Practice ordering in restaurants",
                duration: 20,
                objectives: ["Order food and drinks", "Ask about menu items"],
                completionDate: nil
            )
        ]
    }

    var scenarios: [ConversationScenario] {
        // Generate scenarios based on lesson category
        switch category {
        case .greetings:
            return [
                ConversationScenario(
                    id: UUID().uuidString,
                    title: "Meeting Someone New",
                    description: "Practice introducing yourself",
                    difficulty: level.rawValue,
                    context: "You meet a new colleague at work",
                    suggestedPhrases: ["Nice to meet you", "My name is..."],
                    objectives: ["Introduce yourself", "Ask about the other person"],
                    roleYouPlay: "New Employee",
                    aiRole: "Colleague",
                    autoVoiceEnabled: true
                )
            ]
        case .food:
            return [
                ConversationScenario(
                    id: UUID().uuidString,
                    title: "Restaurant Order",
                    description: "Order a meal at a restaurant",
                    difficulty: level.rawValue,
                    context: "You're at a local restaurant for dinner",
                    suggestedPhrases: ["I would like...", "Could I have..."],
                    objectives: ["Order food", "Ask about menu items"],
                    roleYouPlay: "Customer",
                    aiRole: "Waiter",
                    autoVoiceEnabled: true
                )
            ]
        default:
            return [
                ConversationScenario(
                    id: UUID().uuidString,
                    title: "General Practice",
                    description: "Practice conversation",
                    difficulty: level.rawValue,
                    context: "General conversation practice",
                    suggestedPhrases: [],
                    objectives: ["Practice fluency"],
                    roleYouPlay: "Student",
                    aiRole: "Teacher",
                    autoVoiceEnabled: false
                )
            ]
        }
    }
}