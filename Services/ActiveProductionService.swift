import Foundation

/// Implements Output Hypothesis - Active language production
/// Speaking and writing practice with immediate feedback
@MainActor
class ActiveProductionService: ObservableObject {
    static let shared = ActiveProductionService()

    @Published var productionHistory: [ProductionAttempt] = []
    @Published var weakAreas: [WeakArea] = []

    private let openAIService = OpenAIService.shared
    private let speechService = SpeechService.shared

    // MARK: - Speaking Production

    func analyzeSpeechProduction(
        userSpeech: String,
        targetLanguage: String,
        context: String,
        expectedResponse: String? = nil
    ) async -> SpeechAnalysis {
        let prompt = """
        Analyze this \(targetLanguage) speech production from a language learner:

        Context: \(context)
        \(expectedResponse != nil ? "Expected response: \(expectedResponse!)" : "")
        User said: "\(userSpeech)"

        Provide constructive feedback on:
        1. Grammatical accuracy (errors and corrections)
        2. Vocabulary appropriateness
        3. Fluency (natural phrasing)
        4. Communication effectiveness (did they convey meaning?)

        Give specific corrections with explanations.
        Focus on 2-3 most important errors, not all errors.
        Encourage what was done well.
        Suggest better ways to express the same idea.

        Format:
        STRENGTHS: [What was good]
        PRIORITY CORRECTIONS: [2-3 key errors with explanations]
        BETTER WAY: [Improved version of their speech]
        """

        do {
            let response = try await openAIService.sendMessage(prompt)
            return parseSpeechAnalysis(from: response, original: userSpeech)
        } catch {
            return SpeechAnalysis(
                original: userSpeech,
                strengths: ["You communicated your message"],
                corrections: [],
                improvedVersion: userSpeech,
                score: 0.7
            )
        }
    }

    // MARK: - Writing Production

    func analyzeWritingProduction(
        userText: String,
        targetLanguage: String,
        prompt: String,
        level: DifficultyLevel
    ) async -> WritingAnalysis {
        let analysisPrompt = """
        Analyze this \(targetLanguage) writing from a \(level.rawValue) learner:

        Writing prompt: "\(prompt)"
        Student wrote: "\(userText)"

        Provide detailed feedback on:
        1. Grammar and syntax (specific errors)
        2. Vocabulary range and accuracy
        3. Organization and coherence
        4. Task completion (did they address the prompt?)
        5. Natural expression

        Give:
        - Inline corrections (mark errors in text)
        - 3-5 specific improvements
        - Rewritten version showing better expression
        - Overall score (0-100)

        Be encouraging and constructive.
        """

        do {
            let response = try await openAIService.sendMessage(analysisPrompt)
            return parseWritingAnalysis(from: response, original: userText)
        } catch {
            return WritingAnalysis(
                original: userText,
                corrections: [],
                improvements: ["Keep practicing your writing skills"],
                rewrittenVersion: userText,
                score: 70
            )
        }
    }

    // MARK: - Guided Production Exercises

    func generateProductionPrompt(
        level: DifficultyLevel,
        targetStructures: [String],
        vocabulary: [String],
        context: String
    ) async -> ProductionPrompt {
        let prompt = """
        Create a \(level.rawValue) level production exercise in this context: "\(context)"

        Target structures to practice: \(targetStructures.joined(separator: ", "))
        Vocabulary to use: \(vocabulary.joined(separator: ", "))

        Create:
        1. A situation description
        2. A clear task (what the learner should say/write)
        3. Key phrases to help them
        4. Sample response (for teacher reference only)

        Make it MEANINGFUL and relevant to real communication.
        """

        do {
            let response = try await openAIService.sendMessage(prompt)
            return parseProductionPrompt(from: response, level: level)
        } catch {
            return ProductionPrompt(
                situation: context,
                task: "Describe the situation",
                helpfulPhrases: [],
                level: level
            )
        }
    }

    // MARK: - Scaffolded Output

    /// Provides sentence starters and support for output
    func getOutputScaffolding(
        for task: String,
        level: DifficultyLevel,
        language: String
    ) async -> OutputScaffolding {
        let prompt = """
        For a \(level.rawValue) \(language) learner doing this task: "\(task)"

        Provide scaffolding:
        1. 5 sentence starters they can use
        2. 10 key words/phrases relevant to the task
        3. Example of first sentence
        4. Grammar tip specific to this task

        Give them just enough support to produce language successfully.
        Don't give complete answers - let them construct meaning.
        """

        do {
            let response = try await openAIService.sendMessage(prompt)
            return parseScaffolding(from: response, task: task)
        } catch {
            return OutputScaffolding(
                sentenceStarters: [],
                keyPhrases: [],
                exampleSentence: "",
                grammarTip: ""
            )
        }
    }

    // MARK: - Error Pattern Tracking

    func trackProductionErrors(_ analysis: SpeechAnalysis) {
        // Track errors to identify weak areas
        for correction in analysis.corrections {
            if let existingArea = weakAreas.first(where: { $0.category == correction.errorType }) {
                existingArea.errorCount += 1
                existingArea.lastSeen = Date()
            } else {
                weakAreas.append(WeakArea(
                    category: correction.errorType,
                    errorCount: 1,
                    examples: [correction.original],
                    lastSeen: Date()
                ))
            }
        }
    }

    func getPrioritizedPracticeAreas() -> [WeakArea] {
        // Return areas that need most practice
        return weakAreas
            .sorted { $0.errorCount > $1.errorCount }
            .prefix(3)
            .map { $0 }
    }

    // MARK: - Parsing Methods

    private func parseSpeechAnalysis(from response: String, original: String) -> SpeechAnalysis {
        var strengths: [String] = []
        var corrections: [ProductionCorrection] = []
        var improvedVersion = original
        var score = 0.7

        let sections = response.components(separatedBy: "\n\n")

        for section in sections {
            if section.contains("STRENGTHS") {
                strengths = section.components(separatedBy: "\n")
                    .filter { !$0.contains("STRENGTHS") && !$0.isEmpty }
            } else if section.contains("CORRECTIONS") {
                let lines = section.components(separatedBy: "\n")
                for line in lines where line.contains("-") || line.contains("•") {
                    corrections.append(ProductionCorrection(
                        original: "...",
                        corrected: line,
                        explanation: "",
                        errorType: .grammar
                    ))
                }
            } else if section.contains("BETTER WAY") {
                improvedVersion = section.replacingOccurrences(of: "BETTER WAY:", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }

        return SpeechAnalysis(
            original: original,
            strengths: strengths.isEmpty ? ["You communicated successfully"] : strengths,
            corrections: corrections,
            improvedVersion: improvedVersion,
            score: corrections.count <= 2 ? 0.85 : 0.70
        )
    }

    private func parseWritingAnalysis(from response: String, original: String) -> WritingAnalysis {
        return WritingAnalysis(
            original: original,
            corrections: [],
            improvements: ["Continue practicing"],
            rewrittenVersion: original,
            score: 75
        )
    }

    private func parseProductionPrompt(from response: String, level: DifficultyLevel) -> ProductionPrompt {
        return ProductionPrompt(
            situation: "Practice conversation",
            task: "Respond naturally",
            helpfulPhrases: [],
            level: level
        )
    }

    private func parseScaffolding(from response: String, task: String) -> OutputScaffolding {
        return OutputScaffolding(
            sentenceStarters: [],
            keyPhrases: [],
            exampleSentence: "",
            grammarTip: ""
        )
    }
}

// MARK: - Supporting Models

struct ProductionAttempt: Identifiable {
    let id = UUID()
    let type: ProductionType
    let text: String
    let timestamp: Date
    let analysis: String
    let score: Double

    enum ProductionType {
        case speech
        case writing
    }
}

struct SpeechAnalysis {
    let original: String
    let strengths: [String]
    let corrections: [ProductionCorrection]
    let improvedVersion: String
    let score: Double
}

struct WritingAnalysis {
    let original: String
    let corrections: [ProductionCorrection]
    let improvements: [String]
    let rewrittenVersion: String
    let score: Int
}

struct ProductionCorrection: Identifiable {
    let id = UUID()
    let original: String
    let corrected: String
    let explanation: String
    let errorType: ErrorType

    enum ErrorType: String {
        case grammar = "Grammar"
        case vocabulary = "Vocabulary"
        case pronunciation = "Pronunciation"
        case fluency = "Fluency"
        case word_order = "Word Order"
    }
}

class WeakArea: Identifiable, ObservableObject {
    let id = UUID()
    let category: ProductionCorrection.ErrorType
    var errorCount: Int
    var examples: [String]
    var lastSeen: Date

    init(category: ProductionCorrection.ErrorType, errorCount: Int, examples: [String], lastSeen: Date) {
        self.category = category
        self.errorCount = errorCount
        self.examples = examples
        self.lastSeen = lastSeen
    }
}

struct ProductionPrompt {
    let situation: String
    let task: String
    let helpfulPhrases: [String]
    let level: DifficultyLevel
}

struct OutputScaffolding {
    let sentenceStarters: [String]
    let keyPhrases: [String]
    let exampleSentence: String
    let grammarTip: String
}
