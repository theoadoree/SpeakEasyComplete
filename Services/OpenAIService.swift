import Foundation
import Alamofire

// OpenAI Service for Language Teacher LLM Backend
@MainActor
class OpenAIService: ObservableObject {
    static let shared = OpenAIService()

    private let apiKey: String
    private let apiURL = "https://api.openai.com/v1/chat/completions"
    private let model = "gpt-4o-mini" // Fast and cost-effective for language teaching

    @Published var isLoading = false
    @Published var currentResponse: String = ""

    init() {
        // In production, store this in Keychain or environment variable
        // For now, you'll need to add your API key here or load from config
        self.apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
    }

    // MARK: - Language Teaching Functions

    /// Generate a language lesson based on level and topic
    func generateLesson(language: String, level: String, topic: String) async throws -> LessonContent {
        let prompt = """
        You are an expert language teacher for \(language). Create a structured lesson for a \(level) level student on the topic: \(topic).

        Include:
        1. Key vocabulary (5-10 words/phrases with pronunciation guide)
        2. Grammar point explanation (brief and clear)
        3. Example sentences (3-5 practical examples)
        4. Practice dialogue (short, realistic conversation)
        5. Cultural tip related to the topic

        Format the response as JSON with these fields:
        {
            "title": "lesson title",
            "vocabulary": [{"word": "", "pronunciation": "", "translation": "", "example": ""}],
            "grammar": {"title": "", "explanation": "", "examples": []},
            "dialogue": [{"speaker": "A/B", "text": "", "translation": ""}],
            "culturalTip": "",
            "summary": ""
        }
        """

        let response = try await sendRequest(messages: [
            ["role": "system", "content": "You are a friendly and encouraging language teacher."],
            ["role": "user", "content": prompt]
        ])

        // Parse JSON response into LessonContent
        if let data = response.data(using: .utf8),
           let lessonContent = try? JSONDecoder().decode(LessonContent.self, from: data) {
            return lessonContent
        } else {
            throw OpenAIError.parsingError
        }
    }

    /// Generate conversational response for practice
    func generateConversationResponse(
        language: String,
        context: String,
        userInput: String,
        level: String
    ) async throws -> ConversationResponse {
        let prompt = """
        Language: \(language)
        Student Level: \(level)
        Context: \(context)
        Student said: "\(userInput)"

        Respond briefly and naturally in \(language). Keep your response under 25 words for natural conversation flow.
        
        Format as JSON:
        {
            "response": "brief natural response in target language (under 25 words)",
            "responseTranslation": "English translation",
            "corrections": [{"error": "", "correction": "", "explanation": ""}],
            "suggestions": [],
            "followUpQuestion": "",
            "encouragement": ""
        }
        """

        let response = try await sendRequest(
            messages: [
                ["role": "system", "content": "You are a conversational language teacher. Keep responses brief and natural."],
                ["role": "user", "content": prompt]
            ],
            temperature: 0.8,  // Higher temperature for more natural, varied responses
            maxTokens: 100  // Reduced for faster responses
        )

        if let data = response.data(using: .utf8),
           let conversationResponse = try? JSONDecoder().decode(ConversationResponse.self, from: data) {
            return conversationResponse
        } else {
            throw OpenAIError.parsingError
        }
    }

    /// Check pronunciation and provide feedback
    func checkPronunciation(
        language: String,
        targetPhrase: String,
        userTranscription: String
    ) async throws -> PronunciationFeedback {
        let prompt = """
        Language: \(language)
        Target phrase: "\(targetPhrase)"
        User's pronunciation (transcribed): "\(userTranscription)"

        Analyze the pronunciation and provide feedback:
        1. Accuracy score (0-100)
        2. Specific issues identified
        3. Tips for improvement
        4. Phonetic breakdown of correct pronunciation

        Format as JSON:
        {
            "score": 0,
            "isCorrect": false,
            "issues": [],
            "tips": [],
            "phoneticBreakdown": "",
            "encouragement": ""
        }
        """

        let response = try await sendRequest(messages: [
            ["role": "system", "content": "You are an expert in \(language) pronunciation."],
            ["role": "user", "content": prompt]
        ])

        if let data = response.data(using: .utf8),
           let feedback = try? JSONDecoder().decode(PronunciationFeedback.self, from: data) {
            return feedback
        } else {
            throw OpenAIError.parsingError
        }
    }

    // MARK: - Core Request Function

    private func sendRequest(
        messages: [[String: String]],
        temperature: Double = 0.7,
        maxTokens: Int = 150  // Reduced from 1000 to minimize latency
    ) async throws -> String {
        guard !apiKey.isEmpty else {
            throw OpenAIError.missingAPIKey
        }

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json"
        ]

        let parameters: [String: Any] = [
            "model": model,
            "messages": messages,
            "temperature": temperature,
            "max_tokens": maxTokens,
            "stream": false,  // Disable streaming for predictable timing
            "response_format": ["type": "json_object"]
        ]

        return try await withCheckedThrowingContinuation { continuation in
            AF.request(apiURL,
                      method: .post,
                      parameters: parameters,
                      encoding: JSONEncoding.default,
                      headers: headers)
                .responseDecodable(of: OpenAIResponse.self) { response in
                    switch response.result {
                    case .success(let aiResponse):
                        if let content = aiResponse.choices.first?.message.content {
                            continuation.resume(returning: content)
                        } else {
                            continuation.resume(throwing: OpenAIError.noContent)
                        }
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
}

// MARK: - Data Models

struct LessonContent: Codable {
    let title: String
    let vocabulary: [VocabularyItem]
    let grammar: GrammarPoint
    let dialogue: [DialogueLine]
    let culturalTip: String
    let summary: String
}

struct VocabularyItem: Codable, Identifiable {
    let id = UUID()
    let word: String
    let pronunciation: String
    let translation: String
    let example: String

    enum CodingKeys: String, CodingKey {
        case word, pronunciation, translation, example
    }
}

struct GrammarPoint: Codable {
    let title: String
    let explanation: String
    let examples: [String]
}

struct DialogueLine: Codable, Identifiable {
    let id = UUID()
    let speaker: String
    let text: String
    let translation: String

    enum CodingKeys: String, CodingKey {
        case speaker, text, translation
    }
}

struct ConversationResponse: Codable {
    let response: String
    let responseTranslation: String
    let corrections: [Correction]
    let suggestions: [String]
    let followUpQuestion: String
    let encouragement: String
}

struct Correction: Codable, Identifiable {
    let id = UUID()
    let error: String
    let correction: String
    let explanation: String

    enum CodingKeys: String, CodingKey {
        case error, correction, explanation
    }
}

struct PronunciationFeedback: Codable {
    let score: Int
    let isCorrect: Bool
    let issues: [String]
    let tips: [String]
    let phoneticBreakdown: String
    let encouragement: String
}

// MARK: - OpenAI Response Models

struct OpenAIResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: OpenAIMessage
}

struct OpenAIMessage: Codable {
    let content: String
}

// MARK: - Additional OpenAI Service Methods

extension OpenAIService {
    func generateChatResponse(
        messages: [ChatMessage],
        language: Language,
        level: ProficiencyLevel
    ) async throws -> (message: String, feedback: ConversationFeedback?) {
        // Optimized for low latency with brief, natural responses
        let response = try await sendRequest(
            messages: [
                ["role": "system", "content": "Brief conversational language teacher. Max 20 words."],
                ["role": "user", "content": "Respond naturally in \(language.rawValue)"]
            ],
            temperature: 0.8,
            maxTokens: 80  // Very short for quick responses
        )
        return (response, nil)
    }

    func generateLanguageTeacherResponse(
        userMessage: String,
        language: String,
        level: String,
        conversationHistory: [ChatMessage]
    ) async throws -> (message: String, feedback: ConversationFeedback?) {
        // Ultra-fast response generation for conversation flow
        let prompt = "User: \(userMessage)\nRespond briefly in \(language) (max 20 words):"
        
        let response = try await sendRequest(
            messages: [
                ["role": "system", "content": "You are a friendly language teacher. Keep responses under 20 words."],
                ["role": "user", "content": prompt]
            ],
            temperature: 0.85,  // More natural variation
            maxTokens: 60  // Limited for speed
        )
        
        // Extract just the text response for speed
        let cleanedResponse = response.replacingOccurrences(of: "\"", with: "")
        return (cleanedResponse, nil)
    }

    func synthesizeSpeech(text: String, voice: String = "nova", speed: Double = 1.15) async throws -> Data {
        // Use OpenAI's TTS endpoint for more natural speech with lower latency
        guard !apiKey.isEmpty else {
            throw OpenAIError.missingAPIKey
        }
        
        let ttsURL = "https://api.openai.com/v1/audio/speech"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json"
        ]
        
        // Optimized settings for natural, fluent speech with minimal latency
        // - nova voice: Most natural female voice with warmth and clarity
        // - speed 1.15: Slightly faster for natural conversation flow without sounding rushed
        // - tts-1: Low-latency model optimized for real-time applications
        // - opus format: Better compression and quality than mp3, lower latency
        let parameters: [String: Any] = [
            "model": "tts-1",  // Low-latency model (< 200ms typical response time)
            "input": text,
            "voice": voice,  // nova is most natural and fluent
            "speed": speed,  // 1.15 optimal for natural pacing and clarity
            "response_format": "opus"  // Better quality and lower latency than mp3
        ]
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(ttsURL,
                      method: .post,
                      parameters: parameters,
                      encoding: JSONEncoding.default,
                      headers: headers)
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        continuation.resume(returning: data)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
}

// MARK: - Errors

enum OpenAIError: Error, LocalizedError {
    case missingAPIKey
    case noContent
    case parsingError

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "OpenAI API key is missing. Please set OPENAI_API_KEY environment variable."
        case .noContent:
            return "No content received from OpenAI API"
        case .parsingError:
            return "Failed to parse OpenAI response"
        }
    }
}
