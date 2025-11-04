import Foundation

struct PracticeSession: Identifiable {
    let id = UUID()
    let lesson: Lesson
    let startTime: Date
    var endTime: Date?
    var score: Int = 0
    var feedback: [SessionFeedback] = []
    var recordedAudio: [URL] = []
}

struct SessionFeedback: Identifiable {
    let id = UUID()
    let timestamp: Date
    let type: FeedbackType
    let content: String
    let suggestion: String?

    enum FeedbackType {
        case pronunciation
        case grammar
        case vocabulary
        case fluency
        case comprehension
    }
}
