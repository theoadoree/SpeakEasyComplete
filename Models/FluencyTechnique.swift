import Foundation

enum FluencyTechnique: String, CaseIterable {
    case shadowSpeaking = "Shadow Speaking"
    case tongueTwitters = "Tongue Twisters"
    case rapidResponse = "Rapid Response"
    case storytelling = "Storytelling"
    case paraphrasing = "Paraphrasing"
    case debating = "Debating"

    var description: String {
        switch self {
        case .shadowSpeaking: return "Mimic native speaker pronunciation and rhythm"
        case .tongueTwitters: return "Practice difficult sound combinations"
        case .rapidResponse: return "Quick thinking and speaking practice"
        case .storytelling: return "Create and tell stories fluently"
        case .paraphrasing: return "Express the same idea in different ways"
        case .debating: return "Express opinions and argue points"
        }
    }

    var icon: String {
        switch self {
        case .shadowSpeaking: return "person.wave.2"
        case .tongueTwitters: return "mouth"
        case .rapidResponse: return "bolt"
        case .storytelling: return "book.pages"
        case .paraphrasing: return "arrow.2.circlepath"
        case .debating: return "bubble.left.and.exclamationmark.bubble.right"
        }
    }
}
