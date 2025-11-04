import Foundation

struct ConversationFeedback: Codable {
    let message: String?
    let fluencyScore: Double
    let suggestions: [String]
    let strengths: [String]
    let areasToImprove: [String]
    let grammarNotes: [String]?
    let pronunciationNotes: [String]?
    let improvements: [String]?

    init(message: String? = nil, fluencyScore: Double = 0, suggestions: [String] = [],
         strengths: [String] = [], areasToImprove: [String] = [],
         grammarNotes: [String]? = nil, pronunciationNotes: [String]? = nil,
         improvements: [String]? = nil) {
        self.message = message
        self.fluencyScore = fluencyScore
        self.suggestions = suggestions
        self.strengths = strengths
        self.areasToImprove = areasToImprove
        self.grammarNotes = grammarNotes
        self.pronunciationNotes = pronunciationNotes
        self.improvements = improvements
    }
}
