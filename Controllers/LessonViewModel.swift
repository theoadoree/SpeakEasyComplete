import Foundation
import SwiftUI
import AVFoundation

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

    // ... (rest of the ViewModel implementation)
}

struct LessonContent: Codable {
    let title: String
    let vocabulary: [VocabularyItem]
    let grammar: GrammarPoint
    let dialogue: [DialogueLine]
    let culturalTip: String
    let summary: String
}

struct VocabularyItem: Codable, Identifiable {
    let id = UUID()
    let word: String
    let pronunciation: String
    let translation: String
    let example: String
    
    private enum CodingKeys: String, CodingKey {
        case word, pronunciation, translation, example
    }
}

struct GrammarPoint: Codable {
    let title: String
    let explanation: String
    let examples: [String]
}

struct DialogueLine: Codable, Identifiable {
    let id = UUID()
    let speaker: String
    let text: String
    let translation: String
    
    private enum CodingKeys: String, CodingKey {
        case speaker, text, translation
    }
}
