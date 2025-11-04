import Foundation

enum AppTab {
    case home
    case practice
    case learn
    case progress
}

enum LanguageLevel: String, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case fluent = "Fluent"

    init(cefrLevel: UserProfile.CEFRLevel) {
        switch cefrLevel {
        case .unknown, .a1:
            self = .beginner
        case .a2, .b1:
            self = .intermediate
        case .b2, .c1:
            self = .advanced
        case .c2:
            self = .fluent
        }
    }
}
