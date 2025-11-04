import Foundation

@MainActor
class LessonContentGenerator: ObservableObject {
    static let shared = LessonContentGenerator()

    private let openAIService = OpenAIService.shared

    // MARK: - Lesson Generation

    func generateLessonContent(
        language: String,
        level: DifficultyLevel,
        category: LessonCategory,
        topic: String? = nil
    ) async -> LessonContent? {
        let prompt = createLessonPrompt(
            language: language,
            level: level,
            category: category,
            topic: topic
        )

        do {
            let response = try await openAIService.sendMessage(prompt)
            return parseLessonContent(from: response, language: language, level: level, category: category)
        } catch {
            print("Error generating lesson content: \(error)")
            return nil
        }
    }

    func generateBatchLessons(
        language: String,
        level: DifficultyLevel,
        count: Int = 5
    ) async -> [LessonContent] {
        var lessons: [LessonContent] = []

        for category in LessonCategory.allCases.prefix(count) {
            if let lesson = await generateLessonContent(
                language: language,
                level: level,
                category: category
            ) {
                lessons.append(lesson)
            }
        }

        return lessons
    }

    // MARK: - Scenario Generation

    func generateConversationScenarios(
        language: String,
        level: DifficultyLevel,
        lessonTopic: String,
        count: Int = 3
    ) async -> [ConversationScenario] {
        let prompt = """
        Generate \(count) conversation scenarios for a \(level.rawValue) level \(language) lesson about "\(lessonTopic)".

        For each scenario, provide:
        1. Title (short, descriptive)
        2. Context (what's happening in the scenario)
        3. Role for the student
        4. Role for the teacher/AI
        5. 5-7 key phrases that might be used
        6. Learning objectives (what the student will practice)

        Format each scenario clearly and make them progressively challenging.
        Include cultural context where appropriate.
        """

        do {
            let response = try await openAIService.sendMessage(prompt)
            return parseConversationScenarios(from: response, language: language, level: level)
        } catch {
            print("Error generating scenarios: \(error)")
            return defaultScenarios(language: language, level: level, topic: lessonTopic)
        }
    }

    // MARK: - Vocabulary Generation

    func generateVocabularyList(
        language: String,
        level: DifficultyLevel,
        category: String,
        count: Int = 20
    ) async -> [VocabularyCard] {
        let prompt = """
        Generate \(count) vocabulary words for \(level.rawValue) level \(language) learners studying "\(category)".

        For each word, provide:
        1. Word in target language
        2. English translation
        3. Pronunciation guide (IPA or phonetic)
        4. Example sentence using the word
        5. Part of speech
        6. Common collocations or related words

        Focus on practical, high-frequency words that beginners need to know.
        """

        do {
            let response = try await openAIService.sendMessage(prompt)
            return parseVocabularyCards(from: response, language: language, level: level, category: category)
        } catch {
            print("Error generating vocabulary: \(error)")
            return []
        }
    }

    // MARK: - Prompt Creation

    private func createLessonPrompt(
        language: String,
        level: DifficultyLevel,
        category: LessonCategory,
        topic: String?
    ) -> String {
        let topicText = topic ?? category.rawValue

        return """
        Create a comprehensive \(level.rawValue) level \(language) lesson for the category: \(category.rawValue)
        Topic: \(topicText)

        Please provide:

        1. LESSON TITLE: An engaging title

        2. LESSON DESCRIPTION: A brief overview (2-3 sentences) of what students will learn

        3. LEARNING OBJECTIVES: 3-5 specific learning goals

        4. KEY VOCABULARY: 10-15 essential words/phrases with translations and pronunciation

        5. GRAMMAR POINTS: Main grammar concepts covered (if applicable)

        6. CULTURAL NOTES: Relevant cultural context or etiquette

        7. FLUENCY TECHNIQUES: Specific techniques for improving fluency in this context

        8. PRACTICE SCENARIOS: 3 conversation scenarios where students can practice
           - Each scenario should have a title, context, and suggested phrases

        9. COMMON MISTAKES: Typical errors learners make and how to avoid them

        10. PROGRESSION TIPS: How to advance beyond this lesson

        Make the content practical, engaging, and appropriate for \(level.rawValue) learners.
        Include phonetic pronunciations where helpful.
        Focus on real-world communication skills.
        """
    }

    // MARK: - Content Parsing

    private func parseLessonContent(
        from response: String,
        language: String,
        level: DifficultyLevel,
        category: LessonCategory
    ) -> LessonContent {
        // Parse the AI response into structured lesson content
        // This is a simplified parser - in production, use more robust parsing

        let sections = response.components(separatedBy: "\n\n")

        var title = ""
        var description = ""
        var vocabulary: [VocabularyItem] = []
        var grammarPoints: [String] = []
        var culturalNotes: [String] = []
        var fluencyTechniques: [String] = []

        for section in sections {
            let lines = section.components(separatedBy: "\n")

            if section.contains("TITLE") {
                title = lines.last ?? "Untitled Lesson"
            } else if section.contains("DESCRIPTION") {
                description = lines.dropFirst().joined(separator: " ")
            } else if section.contains("VOCABULARY") {
                vocabulary = parseVocabularyItems(from: section)
            } else if section.contains("GRAMMAR") {
                grammarPoints = parseListItems(from: section)
            } else if section.contains("CULTURAL") {
                culturalNotes = parseListItems(from: section)
            } else if section.contains("FLUENCY") {
                fluencyTechniques = parseListItems(from: section)
            }
        }

        return LessonContent(
            title: title.isEmpty ? "\(category.rawValue) - \(level.rawValue)" : title,
            description: description.isEmpty ? "Learn essential \(category.rawValue) skills in \(language)" : description,
            language: language,
            level: level,
            category: category,
            vocabulary: vocabulary,
            grammarPoints: grammarPoints,
            culturalNotes: culturalNotes,
            fluencyTechniques: fluencyTechniques,
            duration: estimateDuration(vocabularyCount: vocabulary.count, grammarPoints: grammarPoints.count)
        )
    }

    private func parseVocabularyItems(from text: String) -> [VocabularyItem] {
        let lines = text.components(separatedBy: "\n")
        var items: [VocabularyItem] = []

        for line in lines {
            // Look for patterns like: "word - translation (pronunciation)"
            if line.contains("-") && !line.contains("VOCABULARY") {
                let parts = line.components(separatedBy: "-")
                if parts.count >= 2 {
                    let word = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
                    let rest = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)

                    let item = VocabularyItem(
                        word: word,
                        translation: rest,
                        pronunciation: extractPronunciation(from: rest)
                    )
                    items.append(item)
                }
            }
        }

        return items
    }

    private func parseListItems(from text: String) -> [String] {
        let lines = text.components(separatedBy: "\n")
        return lines
            .filter { $0.contains("•") || $0.contains("-") || $0.contains(".") }
            .map { $0.trimmingCharacters(in: CharacterSet(charactersIn: "•-0123456789. ")) }
            .filter { !$0.isEmpty }
    }

    private func extractPronunciation(from text: String) -> String? {
        // Extract text within parentheses
        if let start = text.firstIndex(of: "("),
           let end = text.firstIndex(of: ")") {
            return String(text[text.index(after: start)..<end])
        }
        return nil
    }

    private func parseConversationScenarios(
        from response: String,
        language: String,
        level: DifficultyLevel
    ) -> [ConversationScenario] {
        // Simplified parsing - return default scenarios for now
        // In production, implement robust parsing of AI response
        return defaultScenarios(language: language, level: level, topic: "General")
    }

    private func parseVocabularyCards(
        from response: String,
        language: String,
        level: DifficultyLevel,
        category: String
    ) -> [VocabularyCard] {
        var cards: [VocabularyCard] = []
        let lines = response.components(separatedBy: "\n")

        for line in lines {
            if line.contains("-") && !line.isEmpty {
                let parts = line.components(separatedBy: "-")
                if parts.count >= 2 {
                    let word = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
                    let translation = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)

                    let card = VocabularyCard(
                        word: word,
                        translation: translation,
                        pronunciation: extractPronunciation(from: translation) ?? "",
                        exampleSentence: "Example sentence for \(word)",
                        category: category,
                        difficulty: convertDifficultyLevel(level),
                        audioURL: nil,
                        imageURL: nil
                    )
                    cards.append(card)
                }
            }
        }

        return cards
    }

    // MARK: - Helper Methods

    private func estimateDuration(vocabularyCount: Int, grammarPoints: Int) -> Int {
        // Estimate lesson duration based on content
        let baseMinutes = 10
        let vocabMinutes = vocabularyCount * 2
        let grammarMinutes = grammarPoints * 3
        return baseMinutes + vocabMinutes + grammarMinutes
    }

    private func convertDifficultyLevel(_ level: DifficultyLevel) -> VocabularyCard.Difficulty {
        switch level {
        case .beginner:
            return .beginner
        case .intermediate:
            return .intermediate
        case .advanced:
            return .advanced
        }
    }

    private func defaultScenarios(language: String, level: DifficultyLevel, topic: String) -> [ConversationScenario] {
        // Provide default scenarios when AI generation fails
        return [
            ConversationScenario(
                title: "Greeting and Introduction",
                context: "Meet someone for the first time and introduce yourself",
                roleYouPlay: "A student meeting a new classmate",
                roleAIPlays: "A friendly classmate",
                keyPhrases: [
                    "Hello, nice to meet you",
                    "My name is...",
                    "Where are you from?",
                    "What do you study?",
                    "It's nice to talk with you"
                ],
                suggestedOpener: "Start by greeting your classmate",
                learningObjectives: ["Practice greetings", "Learn to introduce yourself", "Ask and answer basic questions"],
                difficulty: level,
                autoVoiceEnabled: true
            ),
            ConversationScenario(
                title: "Asking for Directions",
                context: "You're lost and need to find a specific location",
                roleYouPlay: "A tourist looking for help",
                roleAIPlays: "A helpful local",
                keyPhrases: [
                    "Excuse me, can you help me?",
                    "How do I get to...?",
                    "Is it far from here?",
                    "Thank you for your help",
                    "Have a nice day"
                ],
                suggestedOpener: "Politely ask for help finding a location",
                learningObjectives: ["Practice asking questions", "Understand directions", "Use polite expressions"],
                difficulty: level,
                autoVoiceEnabled: true
            ),
            ConversationScenario(
                title: "Ordering at a Restaurant",
                context: "Order food and drinks at a restaurant",
                roleYouPlay: "A customer at a restaurant",
                roleAIPlays: "A waiter/waitress",
                keyPhrases: [
                    "I would like to order...",
                    "What do you recommend?",
                    "Can I have the bill, please?",
                    "This looks delicious",
                    "Thank you very much"
                ],
                suggestedOpener: "Look at the menu and start your order",
                learningObjectives: ["Practice ordering food", "Learn restaurant vocabulary", "Use polite requests"],
                difficulty: level,
                autoVoiceEnabled: true
            )
        ]
    }
}

// MARK: - Supporting Models

struct LessonContent {
    let title: String
    let description: String
    let language: String
    let level: DifficultyLevel
    let category: LessonCategory
    let vocabulary: [VocabularyItem]
    let grammarPoints: [String]
    let culturalNotes: [String]
    let fluencyTechniques: [String]
    let duration: Int
}

struct VocabularyItem: Identifiable {
    let id = UUID()
    let word: String
    let translation: String
    let pronunciation: String?

    var displayText: String {
        if let pronunciation = pronunciation {
            return "\(word) - \(translation) (\(pronunciation))"
        }
        return "\(word) - \(translation)"
    }
}
