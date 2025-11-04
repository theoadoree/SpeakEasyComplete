import SwiftUI

enum ProficiencyLevel: String, CaseIterable, Codable {
    case beginner = "Beginner"
    case elementary = "Elementary"
    case intermediate = "Intermediate"
    case upperIntermediate = "Upper Intermediate"
    case advanced = "Advanced"
    case fluent = "Fluent"

    var color: Color {
        switch self {
        case .beginner: return .green
        case .elementary: return .mint
        case .intermediate: return .blue
        case .upperIntermediate: return .indigo
        case .advanced: return .purple
        case .fluent: return .orange
        }
    }

    var description: String {
        switch self {
        case .beginner: return "A1 - Basic phrases and greetings"
        case .elementary: return "A2 - Simple conversations"
        case .intermediate: return "B1 - Everyday situations"
        case .upperIntermediate: return "B2 - Complex discussions"
        case .advanced: return "C1 - Professional fluency"
        case .fluent: return "C2 - Native-like proficiency"
        }
    }
}
