import Foundation

struct ConversationScenario: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let difficulty: String
    let context: String
    let suggestedPhrases: [String]
    let objectives: [String]
    let roleYouPlay: String
    let aiRole: String
    let autoVoiceEnabled: Bool

    init(id: String? = nil, title: String, description: String, difficulty: String,
         context: String, suggestedPhrases: [String], objectives: [String],
         roleYouPlay: String = "Student", aiRole: String = "Teacher",
         autoVoiceEnabled: Bool = false) {
        self.id = id ?? UUID().uuidString
        self.title = title
        self.description = description
        self.difficulty = difficulty
        self.context = context
        self.suggestedPhrases = suggestedPhrases
        self.objectives = objectives
        self.roleYouPlay = roleYouPlay
        self.aiRole = aiRole
        self.autoVoiceEnabled = autoVoiceEnabled
    }
}

