import Foundation

// Assessment Result Model (received from backend and stored locally)
struct AssessmentResult: Codable {
    let level: UserProfile.CEFRLevel
    let score: Int
    let feedback: String
    let strengths: [String]
    let areasForImprovement: [String]
    let evaluatedAt: Date

    init(
        level: UserProfile.CEFRLevel,
        score: Int,
        feedback: String,
        strengths: [String],
        areasForImprovement: [String],
        evaluatedAt: Date = Date()
    ) {
        self.level = level
        self.score = score
        self.feedback = feedback
        self.strengths = strengths
        self.areasForImprovement = areasForImprovement
        self.evaluatedAt = evaluatedAt
    }
}
