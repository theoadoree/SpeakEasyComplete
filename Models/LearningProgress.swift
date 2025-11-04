import Foundation

struct LearningProgress: Codable {
    let userId: String
    let language: Language
    let level: ProficiencyLevel
    let totalLessonsCompleted: Int
    let totalPracticeMinutes: Int
    let currentStreak: Int
    let longestStreak: Int
    let achievements: [Achievement]
    let vocabularyMastered: Int
    let lastActiveDate: Date
}

struct Achievement: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let dateEarned: Date
    let category: AchievementCategory

    enum AchievementCategory: String, Codable {
        case streak = "Streak"
        case vocabulary = "Vocabulary"
        case pronunciation = "Pronunciation"
        case conversation = "Conversation"
        case milestone = "Milestone"
    }

    enum CodingKeys: String, CodingKey {
        case title, description, icon, dateEarned, category
    }
}
