import Foundation

enum LanguageSkill: String, CaseIterable {
    case speaking = "Speaking"
    case listening = "Listening"
    case reading = "Reading"
    case writing = "Writing"
    case grammar = "Grammar"
    case vocabulary = "Vocabulary"

    var icon: String {
        switch self {
        case .speaking: return "mic"
        case .listening: return "ear"
        case .reading: return "book"
        case .writing: return "pencil"
        case .grammar: return "text.book.closed"
        case .vocabulary: return "character.book.closed"
        }
    }
}
