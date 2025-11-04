import Foundation

class AssessmentService {
    static let shared = AssessmentService()

    private let apiService = APIService.shared
    private let minimumExchanges = 3

    private init() {}

    // MARK: - Minimum Exchanges
    func getMinimumExchanges() -> Int {
        return minimumExchanges
    }

    // MARK: - Should Trigger Assessment
    func shouldTriggerAssessment(messages: [Message], assessmentPending: Bool) -> Bool {
        guard assessmentPending else { return false }

        let userMessageCount = messages.filter { $0.role == .user }.count
        return userMessageCount >= minimumExchanges
    }

    // MARK: - Evaluate Level
    func evaluateLevel(messages: [Message], targetLanguage: String) async throws -> AssessmentResult {
        // Extract user responses
        let userResponses = messages
            .filter { $0.role == .user }
            .map { $0.content }

        // Call backend API
        let response = try await apiService.evaluateLevel(
            responses: userResponses,
            targetLanguage: targetLanguage
        )

        guard response.success else {
            throw AssessmentError.evaluationFailed
        }

        // Map to AssessmentResult
        return AssessmentResult(
            level: mapToLevel(response.assessment.level),
            score: response.assessment.score,
            feedback: response.assessment.feedback,
            strengths: response.assessment.strengths,
            areasForImprovement: response.assessment.areasForImprovement,
            evaluatedAt: Date()
        )
    }

    // MARK: - Map Level String to CEFRLevel
    private func mapToLevel(_ levelString: String) -> UserProfile.CEFRLevel {
        let normalized = levelString.uppercased()

        switch normalized {
        case "A1":
            return .a1
        case "A2":
            return .a2
        case "B1":
            return .b1
        case "B2":
            return .b2
        case "C1":
            return .c1
        case "C2":
            return .c2
        default:
            // Default to A1 if unable to determine
            return .a1
        }
    }

    // MARK: - Level Description
    func getLevelDescription(_ level: UserProfile.CEFRLevel) -> String {
        switch level {
        case .unknown:
            return "Not yet assessed"
        case .a1:
            return "Beginner - Can understand and use familiar everyday expressions"
        case .a2:
            return "Elementary - Can communicate in simple and routine tasks"
        case .b1:
            return "Intermediate - Can deal with most situations while traveling"
        case .b2:
            return "Upper Intermediate - Can interact with fluency and spontaneity"
        case .c1:
            return "Advanced - Can use language flexibly and effectively"
        case .c2:
            return "Proficient - Can understand virtually everything with ease"
        }
    }

    // MARK: - Level Progress
    func getProgressPercentage(_ level: UserProfile.CEFRLevel) -> Double {
        switch level {
        case .unknown:
            return 0.0
        case .a1:
            return 16.67
        case .a2:
            return 33.33
        case .b1:
            return 50.0
        case .b2:
            return 66.67
        case .c1:
            return 83.33
        case .c2:
            return 100.0
        }
    }

    // MARK: - Next Level
    func getNextLevel(_ currentLevel: UserProfile.CEFRLevel) -> UserProfile.CEFRLevel? {
        switch currentLevel {
        case .unknown, .a1:
            return .a2
        case .a2:
            return .b1
        case .b1:
            return .b2
        case .b2:
            return .c1
        case .c1:
            return .c2
        case .c2:
            return nil // Already at highest level
        }
    }
}

// MARK: - Assessment Errors
enum AssessmentError: LocalizedError {
    case evaluationFailed
    case insufficientData

    var errorDescription: String? {
        switch self {
        case .evaluationFailed:
            return "Failed to evaluate language level"
        case .insufficientData:
            return "Not enough conversation data for assessment"
        }
    }
}
