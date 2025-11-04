import Foundation

/// Represents the learner's overall difficulty band that drives adaptive content.
enum DifficultyLevel: String, Codable, CaseIterable {
    case beginner = "Beginner"
    case elementary = "Elementary"
    case intermediate = "Intermediate"
    case upperIntermediate = "Upper-Intermediate"
    case advanced = "Advanced"
}

extension String {
    /// Converts stored difficulty labels into an ordinal value for quick comparisons.
    var difficultyValue: Int {
        switch self {
        case DifficultyLevel.beginner.rawValue: return 1
        case DifficultyLevel.elementary.rawValue: return 2
        case DifficultyLevel.intermediate.rawValue: return 3
        case DifficultyLevel.upperIntermediate.rawValue: return 4
        case DifficultyLevel.advanced.rawValue: return 5
        default: return 3
        }
    }
}
