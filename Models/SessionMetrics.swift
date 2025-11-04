import Foundation

struct SessionMetrics {
    let sessionStartTime: Date
    let messageCount: Int
    let totalWords: Int
    let currentFluencyScore: Double
    let lastFeedback: ConversationFeedback?
}
