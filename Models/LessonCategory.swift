import SwiftUI

enum LessonCategory: String, CaseIterable, Codable {
    case greetings = "Greetings & Introductions"
    case numbers = "Numbers & Counting"
    case time = "Time & Dates"
    case family = "Family & Relationships"
    case food = "Food & Dining"
    case travel = "Travel & Directions"
    case shopping = "Shopping & Money"
    case work = "Work & Business"
    case health = "Health & Medical"
    case culture = "Culture & Traditions"
    case grammar = "Grammar Focus"
    case pronunciation = "Pronunciation Practice"
    case conversation = "Conversation Practice"

    var icon: String {
        switch self {
        case .greetings: return "hand.wave"
        case .numbers: return "number"
        case .time: return "clock"
        case .family: return "person.2"
        case .food: return "fork.knife"
        case .travel: return "airplane"
        case .shopping: return "cart"
        case .work: return "briefcase"
        case .health: return "heart"
        case .culture: return "globe"
        case .grammar: return "book"
        case .pronunciation: return "waveform"
        case .conversation: return "bubble.left.and.bubble.right"
        }
    }

    var color: Color {
        switch self {
        case .greetings: return .blue
        case .numbers: return .purple
        case .time: return .orange
        case .family: return .pink
        case .food: return .green
        case .travel: return .cyan
        case .shopping: return .indigo
        case .work: return .gray
        case .health: return .red
        case .culture: return .yellow
        case .grammar: return .mint
        case .pronunciation: return .teal
        case .conversation: return .brown
        }
    }
}
