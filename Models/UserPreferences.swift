import Foundation

struct UserPreferences: Codable {
    var preferredLanguage: Language
    var currentLevel: ProficiencyLevel
    var dailyGoalMinutes: Int
    var enableSpeechRecognition: Bool
    var enableAutoSpeak: Bool
    var speakingRate: Float
    var preferredVoice: String?
    var notificationsEnabled: Bool
    var reminderTime: Date?
}
