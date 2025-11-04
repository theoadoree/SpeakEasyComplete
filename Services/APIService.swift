#if false
import Foundation
import Alamofire

class APIService {
    static let shared = APIService()

    private let baseURL = "https://speakeasy-backend-823510409781.us-central1.run.app"
    private let session: Session

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        self.session = Session(configuration: configuration)
    }

    // MARK: - Generic Request
    func request<T: Decodable>(
        _ endpoint: String,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = JSONEncoding.default
    ) async throws -> T {
        let url = "\(baseURL)\(endpoint)"

        return try await withCheckedThrowingContinuation { continuation in
            session.request(url, method: method, parameters: parameters, encoding: encoding)
                .validate()
                .responseDecodable(of: T.self) { response in
                    switch response.result {
                    case .success(let data):
                        continuation.resume(returning: data)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }

    // MARK: - Health Check
    func healthCheck() async throws -> HealthResponse {
        try await request("/health")
    }

    // MARK: - Generate Content
    func generate(prompt: String, options: GenerateOptions? = nil) async throws -> GenerateResponse {
        var params: Parameters = ["prompt": prompt]
        if let options = options {
            params["model"] = options.model
            params["temperature"] = options.temperature
            params["max_tokens"] = options.maxTokens
        }

        return try await request("/api/generate", method: .post, parameters: params)
    }

    // MARK: - Story Generation
    func generateStory(
        nativeLanguage: String,
        targetLanguage: String,
        level: String,
        interests: [String]
    ) async throws -> StoryResponse {
        let params: Parameters = [
            "nativeLanguage": nativeLanguage,
            "targetLanguage": targetLanguage,
            "level": level,
            "interests": interests
        ]

        return try await request("/api/story/generate", method: .post, parameters: params)
    }

    // MARK: - Conversation Practice
    func sendPracticeMessage(
        message: String,
        conversationHistory: [[String: String]],
        targetLanguage: String,
        userLevel: String
    ) async throws -> MessageResponse {
        let params: Parameters = [
            "message": message,
            "conversationHistory": conversationHistory,
            "targetLanguage": targetLanguage,
            "userLevel": userLevel
        ]

        return try await request("/api/practice/message", method: .post, parameters: params)
    }

    // MARK: - Word Explanation
    func explainWord(
        word: String,
        context: String,
        targetLanguage: String,
        nativeLanguage: String
    ) async throws -> WordExplanationResponse {
        let params: Parameters = [
            "word": word,
            "context": context,
            "targetLanguage": targetLanguage,
            "nativeLanguage": nativeLanguage
        ]

        return try await request("/api/word/explain", method: .post, parameters: params)
    }

    // MARK: - Lesson Generation
    func generateLesson(
        targetLanguage: String,
        level: String,
        lessonType: String,
        topics: [String]
    ) async throws -> LessonResponse {
        let params: Parameters = [
            "targetLanguage": targetLanguage,
            "level": level,
            "lessonType": lessonType,
            "topics": topics
        ]

        return try await request("/api/lessons/generate", method: .post, parameters: params)
    }

    // MARK: - Assessment Evaluation
    func evaluateLevel(
        responses: [String],
        targetLanguage: String
    ) async throws -> AssessmentResponse {
        let params: Parameters = [
            "responses": responses,
            "targetLanguage": targetLanguage
        ]

        return try await request("/api/assessment/evaluate", method: .post, parameters: params)
    }
}

// MARK: - Request/Response Models

struct HealthResponse: Codable {
    let status: String
    let provider: String
    let timestamp: String
}

struct GenerateOptions {
    let model: String?
    let temperature: Double
    let maxTokens: Int

    init(model: String? = nil, temperature: Double = 0.7, maxTokens: Int = 1000) {
        self.model = model
        self.temperature = temperature
        self.maxTokens = maxTokens
    }
}

struct GenerateResponse: Codable {
    let success: Bool
    let response: String
    let model: String?
}

struct StoryResponse: Codable {
    let success: Bool
    let story: Story

    struct Story: Codable {
        let title: String
        let content: String
        let level: String
        let vocabulary: [String]
        let summary: String?
    }
}

struct MessageResponse: Codable {
    let success: Bool
    let message: String
    let role: String
}

struct WordExplanationResponse: Codable {
    let success: Bool
    let explanation: WordExplanation

    struct WordExplanation: Codable {
        let word: String
        let translation: String
        let definition: String
        let examples: [String]
        let pronunciation: String?
    }
}

struct LessonResponse: Codable {
    let success: Bool
    let lesson: Lesson

    struct Lesson: Codable {
        let title: String
        let content: String
        let exercises: [Exercise]
        let vocabulary: [String]
    }

    struct Exercise: Codable {
        let question: String
        let type: String
        let options: [String]?
        let answer: String
    }
}

struct AssessmentResponse: Codable {
    let success: Bool
    let assessment: AssessmentData

    struct AssessmentData: Codable {
        let level: String
        let score: Int
        let feedback: String
        let strengths: [String]
        let areasForImprovement: [String]
    }
}

#endif // Disabled duplicate service file. Use APIService.swift instead.
