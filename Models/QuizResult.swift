import Foundation

struct QuizResult: Identifiable, Codable {
    let id: UUID
    let quizId: UUID
    let score: Int // percentage
    let correctAnswers: Int
    let totalQuestions: Int
    let timeSpent: TimeInterval
    let answers: [QuizAnswer]
    let completedAt: Date

    var passed: Bool {
        score >= 70 // Default passing score
    }
}

struct QuizAnswer: Codable {
    let questionId: UUID
    let userAnswer: String
    let isCorrect: Bool
    let timeSpent: TimeInterval
}
