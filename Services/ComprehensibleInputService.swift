import Foundation

/// Implements Krashen's Input Hypothesis (i+1)
/// Provides content slightly above learner's current level
@MainActor
class ComprehensibleInputService: ObservableObject {
    static let shared = ComprehensibleInputService()

    @Published var currentUserLevel: DifficultyLevel = .beginner
    @Published var recommendedContent: [ContentItem] = []

    private let openAIService = OpenAIService.shared
    private let lessonGenerator = LessonContentGenerator.shared

    // MARK: - i+1 Level Determination

    /// Calculate the optimal input level (current + 1)
    func getOptimalInputLevel(for userLevel: DifficultyLevel) -> DifficultyLevel {
        // For beginners, stay at beginner with scaffolding
        // For others, provide content at current level with challenging elements
        switch userLevel {
        case .beginner:
            return .beginner // With 10% intermediate vocabulary
        case .intermediate:
            return .intermediate // With 10% advanced structures
        case .advanced:
            return .advanced // With native-like expressions
        }
    }

    /// Determine vocabulary complexity for i+1
    func getVocabularyMix(for level: DifficultyLevel) -> VocabularyMix {
        switch level {
        case .beginner:
            return VocabularyMix(
                known: 0.80,           // 80% high-frequency words
                target: 0.15,          // 15% new words (i+1)
                challenging: 0.05      // 5% slightly above
            )
        case .intermediate:
            return VocabularyMix(
                known: 0.75,
                target: 0.20,
                challenging: 0.05
            )
        case .advanced:
            return VocabularyMix(
                known: 0.70,
                target: 0.20,
                challenging: 0.10
            )
        }
    }

    // MARK: - Comprehensible Input Generation

    func generateComprehensibleStory(
        for userLevel: DifficultyLevel,
        topic: String,
        language: String,
        userVocabulary: [String]
    ) async -> Story? {
        let vocabMix = getVocabularyMix(for: userLevel)
        let optimalLevel = getOptimalInputLevel(for: userLevel)

        let prompt = """
        Create a \(language) story for a \(userLevel.rawValue) learner about "\(topic)".

        COMPREHENSIBLE INPUT REQUIREMENTS (i+1):
        - Use \(Int(vocabMix.known * 100))% vocabulary the learner already knows
        - Introduce \(Int(vocabMix.target * 100))% new vocabulary naturally in context
        - Include \(Int(vocabMix.challenging * 100))% slightly challenging structures
        - Make meaning clear through context, not just translation
        - Use repetition and paraphrasing for new concepts
        - Include visual/contextual clues where possible

        Known vocabulary to use: \(userVocabulary.prefix(50).joined(separator: ", "))

        Story structure:
        1. Title (engaging, appropriate level)
        2. Story text (250-400 words, divided into short paragraphs)
        3. New vocabulary introduced (with context sentences)
        4. Key grammar patterns used
        5. Comprehension questions (3-5)

        Make it INTERESTING and MEANINGFUL for the learner.
        Use natural, authentic language with contextual scaffolding.
        """

        do {
            let response = try await openAIService.sendMessage(prompt)
            return parseStory(from: response, level: userLevel, language: language)
        } catch {
            print("Error generating comprehensible input: \(error)")
            return nil
        }
    }

    func generateContextualDialogue(
        for userLevel: DifficultyLevel,
        scenario: String,
        language: String,
        userVocabulary: [String]
    ) async -> Dialogue? {
        let vocabMix = getVocabularyMix(for: userLevel)

        let prompt = """
        Create a natural \(language) conversation for a \(userLevel.rawValue) learner in this scenario: "\(scenario)".

        COMPREHENSIBLE INPUT GUIDELINES:
        - Use mostly familiar vocabulary (\(Int(vocabMix.known * 100))%)
        - Introduce new words naturally in context (\(Int(vocabMix.target * 100))%)
        - Make meaning clear through conversation flow
        - Include natural hesitations, clarifications, and repetitions
        - Show negotiation of meaning (asking for clarification)
        - Use authentic discourse markers

        Known vocabulary: \(userVocabulary.prefix(30).joined(separator: ", "))

        Create 10-15 exchanges between two speakers.
        Show how meaning is negotiated when understanding isn't clear.
        Include subtle grammar patterns naturally.
        """

        do {
            let response = try await openAIService.sendMessage(prompt)
            return parseDialogue(from: response, level: userLevel, language: language)
        } catch {
            print("Error generating dialogue: \(error)")
            return nil
        }
    }

    // MARK: - Adaptive Content Adjustment

    func adjustContentDifficulty(
        content: String,
        targetLevel: DifficultyLevel,
        userComprehension: Double
    ) async -> String? {
        // If comprehension is too low (<70%), simplify
        // If comprehension is too high (>95%), increase challenge

        guard userComprehension < 0.70 || userComprehension > 0.95 else {
            return content // Current difficulty is appropriate
        }

        let adjustment = userComprehension < 0.70 ? "simplify" : "make slightly more challenging"

        let prompt = """
        Take this \(targetLevel.rawValue) level content and \(adjustment) it slightly:

        \(content)

        Keep the same meaning and story, but adjust:
        - Vocabulary complexity
        - Sentence structure
        - Amount of context clues

        Goal: Make it comprehensible but still challenging (i+1).
        """

        do {
            return try await openAIService.sendMessage(prompt)
        } catch {
            return nil
        }
    }

    // MARK: - Parsing

    private func parseStory(from response: String, level: DifficultyLevel, language: String) -> Story {
        let sections = response.components(separatedBy: "\n\n")

        var title = "Untitled Story"
        var text = ""
        var newVocabulary: [String] = []
        var comprehensionQuestions: [String] = []

        for section in sections {
            if section.contains("Title") || section.contains("TITLE") {
                title = section.components(separatedBy: "\n").last ?? title
            } else if section.contains("Story") || section.contains("STORY") {
                text = section.replacingOccurrences(of: "Story:", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            } else if section.contains("Vocabulary") || section.contains("VOCABULARY") {
                newVocabulary = section.components(separatedBy: "\n")
                    .filter { $0.contains("-") || $0.contains(":") }
            } else if section.contains("Questions") || section.contains("QUESTIONS") {
                comprehensionQuestions = section.components(separatedBy: "\n")
                    .filter { $0.contains("?") }
            }
        }

        return Story(
            id: UUID(),
            title: title,
            text: text,
            level: level,
            language: language,
            newVocabulary: newVocabulary,
            comprehensionQuestions: comprehensionQuestions,
            estimatedReadingTime: calculateReadingTime(text: text, level: level)
        )
    }

    private func parseDialogue(from response: String, level: DifficultyLevel, language: String) -> Dialogue {
        let lines = response.components(separatedBy: "\n")
        var exchanges: [DialogueExchange] = []

        for line in lines {
            if line.contains(":") {
                let parts = line.components(separatedBy: ":")
                if parts.count >= 2 {
                    let speaker = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
                    let text = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
                    exchanges.append(DialogueExchange(speaker: speaker, text: text))
                }
            }
        }

        return Dialogue(
            id: UUID(),
            scenario: "Conversation Practice",
            exchanges: exchanges,
            level: level,
            language: language
        )
    }

    private func calculateReadingTime(text: String, level: DifficultyLevel) -> Int {
        let wordCount = text.components(separatedBy: .whitespaces).count
        let wordsPerMinute = level == .beginner ? 80 : level == .intermediate ? 120 : 160
        return max(1, wordCount / wordsPerMinute)
    }
}

// MARK: - Supporting Models

struct VocabularyMix {
    let known: Double          // Percentage of known vocabulary
    let target: Double         // Percentage of target new vocabulary (i+1)
    let challenging: Double    // Percentage of slightly above (i+2)
}

struct Story: Identifiable {
    let id: UUID
    let title: String
    let text: String
    let level: DifficultyLevel
    let language: String
    let newVocabulary: [String]
    let comprehensionQuestions: [String]
    let estimatedReadingTime: Int
}

struct Dialogue: Identifiable {
    let id: UUID
    let scenario: String
    let exchanges: [DialogueExchange]
    let level: DifficultyLevel
    let language: String
}

struct DialogueExchange: Identifiable {
    let id = UUID()
    let speaker: String
    let text: String
}

struct ContentItem: Identifiable {
    let id = UUID()
    let title: String
    let type: ContentType
    let level: DifficultyLevel
    let estimatedTime: Int
    let newWordsCount: Int

    enum ContentType {
        case story
        case dialogue
        case article
        case video
    }
}
