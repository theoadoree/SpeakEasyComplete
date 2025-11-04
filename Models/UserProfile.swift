import Foundation

struct UserProfile: Codable, Equatable {
    var name: String
    var nativeLanguage: String
    var targetLanguage: String
    var level: CEFRLevel
    var interests: [String]
    var assessmentPending: Bool
    var createdAt: Date

    enum CEFRLevel: String, Codable, Equatable {
        case unknown = "unknown"
        case a1 = "A1"
        case a2 = "A2"
        case b1 = "B1"
        case b2 = "B2"
        case c1 = "C1"
        case c2 = "C2"

        var toDifficultyLevel: DifficultyLevel {
            switch self {
            case .unknown, .a1:
                return .beginner
            case .a2:
                return .elementary
            case .b1:
                return .intermediate
            case .b2:
                return .upperIntermediate
            case .c1, .c2:
                return .advanced
            }
        }
    }

    init(
        name: String,
        nativeLanguage: String,
        targetLanguage: String,
        level: CEFRLevel = .unknown,
        interests: [String],
        assessmentPending: Bool = true,
        createdAt: Date = Date()
    ) {
        self.name = name
        self.nativeLanguage = nativeLanguage
        self.targetLanguage = targetLanguage
        self.level = level
        self.interests = interests
        self.assessmentPending = assessmentPending
        self.createdAt = createdAt
    }
}
