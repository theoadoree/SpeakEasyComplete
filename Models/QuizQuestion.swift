import Foundation

struct QuizQuestion: Identifiable, Codable {
    let id: UUID
    let text: String
    let type: QuestionType
    let options: [String]
    let correctAnswer: String
    let explanation: String?
    let audioURL: String?
    let imageURL: String?

    enum QuestionType: String, Codable {
        case multipleChoice = "Multiple Choice"
        case fillInBlank = "Fill in the Blank"
        case translation = "Translation"
        case listening = "Listening"
        case matching = "Matching"
    }
}
