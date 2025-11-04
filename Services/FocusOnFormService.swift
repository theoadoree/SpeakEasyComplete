import Foundation

/// Implements Noticing Hypothesis (Schmidt)
/// Directs attention to linguistic features in meaningful context
@MainActor
class FocusOnFormService: ObservableObject {
    static let shared = FocusOnFormService()

    @Published var noticedPatterns: [NoticedPattern] = []
    @Published var readyToNotice: [GrammarPattern] = []

    private let openAIService = OpenAIService.shared

    // MARK: - Pattern Noticing

    /// Highlight grammar patterns in context
    func highlightPattern(
        in text: String,
        pattern: GrammarPattern,
        language: String
    ) -> HighlightedText {
        // Mark instances of the pattern in the text
        var highlights: [TextHighlight] = []
        var currentText = text

        // Use regex or simple string matching to find pattern instances
        let examples = findPatternInstances(text: text, pattern: pattern)

        for (index, example) in examples.enumerated() {
            if let range = currentText.range(of: example) {
                let location = currentText.distance(from: currentText.startIndex, to: range.lowerBound)
                highlights.append(TextHighlight(
                    range: NSRange(location: location, length: example.count),
                    pattern: pattern,
                    example: example,
                    explanation: pattern.simpleExplanation
                ))
            }
        }

        return HighlightedText(
            originalText: text,
            highlights: highlights,
            focusPattern: pattern
        )
    }

    /// Generate awareness-raising activities
    func generateNoticingActivity(
        pattern: GrammarPattern,
        level: DifficultyLevel,
        language: String
    ) async -> NoticingActivity? {
        let prompt = """
        Create a noticing activity for \(level.rawValue) level \(language) learners to notice this pattern:

        Pattern: \(pattern.name)
        Function: \(pattern.function)

        Create a short text (100-150 words) where this pattern appears 5-7 times naturally.
        Make the context meaningful and interesting.
        Don't explain the grammar - let learners discover the pattern.

        Then provide:
        1. Questions to guide noticing (e.g., "Look at the highlighted words. What do they have in common?")
        2. Discovery questions (e.g., "When is this form used?")
        3. Rule formulation (let learner state the rule after noticing)

        Text should be comprehensible but with clear examples of the target pattern.
        """

        do {
            let response = try await openAIService.sendMessage(prompt)
            return parseNoticingActivity(from: response, pattern: pattern, level: level)
        } catch {
            print("Error generating noticing activity: \(error)")
            return nil
        }
    }

    /// Input enhancement - make forms visually salient
    func enhanceInput(
        text: String,
        targetForms: [String],
        enhancementType: EnhancementType
    ) -> EnhancedText {
        var enhancements: [InputEnhancement] = []

        for form in targetForms {
            var searchText = text
            while let range = searchText.range(of: form, options: .caseInsensitive) {
                let location = searchText.distance(from: searchText.startIndex, to: range.lowerBound)

                enhancements.append(InputEnhancement(
                    range: NSRange(location: location, length: form.count),
                    text: form,
                    type: enhancementType
                ))

                searchText = String(searchText[range.upperBound...])
            }
        }

        return EnhancedText(
            originalText: text,
            enhancements: enhancements
        )
    }

    // MARK: - Consciousness-Raising

    /// Task that makes learners conscious of a form
    func generateConsciousnessRaisingTask(
        pattern: GrammarPattern,
        level: DifficultyLevel,
        language: String
    ) async -> ConsciousnessRaisingTask? {
        let prompt = """
        Create a consciousness-raising task for \(language) learners about:

        Pattern: \(pattern.name)

        Provide:
        1. Two example sentences clearly showing the pattern
        2. Three guided discovery questions that lead learners to understand:
           - The form (how it's constructed)
           - The meaning (what it expresses)
           - The use (when to use it)
        3. A simple visual diagram showing the pattern structure
        4. Practice task where learners identify the pattern in context

        Make it inductive - learners discover the rule, you don't tell them directly.
        """

        do {
            let response = try await openAIService.sendMessage(prompt)
            return parseConsciousnessRaisingTask(from: response, pattern: pattern)
        } catch {
            return nil
        }
    }

    // MARK: - Form-Meaning Connections

    /// Help learners connect form with meaning/function
    func explainFormMeaningConnection(
        form: String,
        context: String,
        language: String
    ) async -> FormMeaningExplanation? {
        let prompt = """
        Explain why this \(language) form is used in this context:

        Form: \(form)
        Context: \(context)

        Explain:
        1. What meaning/function does this form express?
        2. Why is this form chosen over alternatives?
        3. When would a learner use this form?
        4. Common mistakes with this form

        Keep explanation simple and example-based.
        """

        do {
            let response = try await openAIService.sendMessage(prompt)
            return FormMeaningExplanation(
                form: form,
                meaning: response,
                whenToUse: "",
                commonMistakes: []
            )
        } catch {
            return nil
        }
    }

    // MARK: - Timing of Focus on Form

    /// Determine if learner is ready to notice a pattern
    func isReadyToNotice(
        pattern: GrammarPattern,
        userLevel: DifficultyLevel,
        exposureCount: Int
    ) -> Bool {
        // Learners need sufficient exposure before noticing is beneficial
        let minimumExposure = pattern.complexity == .low ? 3 : 5

        // Must be developmentally ready
        let developmentallyReady = pattern.typicalLevel.rawValue <= userLevel.rawValue

        return exposureCount >= minimumExposure && developmentallyReady
    }

    // MARK: - Helper Methods

    private func findPatternInstances(text: String, pattern: GrammarPattern) -> [String] {
        // Simplified pattern matching - in production use proper regex
        var instances: [String] = []

        for example in pattern.examples {
            let words = text.components(separatedBy: .whitespaces)
            let exampleWords = example.components(separatedBy: .whitespaces)

            for i in 0...(words.count - exampleWords.count) {
                let slice = words[i..<min(i + exampleWords.count, words.count)]
                if slice.joined(separator: " ").lowercased() == example.lowercased() {
                    instances.append(example)
                }
            }
        }

        return Array(Set(instances)) // Remove duplicates
    }

    private func parseNoticingActivity(
        from response: String,
        pattern: GrammarPattern,
        level: DifficultyLevel
    ) -> NoticingActivity {
        return NoticingActivity(
            id: UUID(),
            pattern: pattern,
            contextText: response,
            noticingQuestions: [],
            discoveryQuestions: [],
            level: level
        )
    }

    private func parseConsciousnessRaisingTask(
        from response: String,
        pattern: GrammarPattern
    ) -> ConsciousnessRaisingTask {
        return ConsciousnessRaisingTask(
            pattern: pattern,
            examples: [],
            discoveryQuestions: [],
            diagram: "",
            practiceTask: ""
        )
    }
}

// MARK: - Supporting Models

struct GrammarPattern: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let function: String
    let examples: [String]
    let simpleExplanation: String
    let typicalLevel: DifficultyLevel
    let complexity: PatternComplexity

    enum PatternComplexity {
        case low, medium, high
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: GrammarPattern, rhs: GrammarPattern) -> Bool {
        lhs.id == rhs.id
    }
}

struct NoticedPattern: Identifiable {
    let id = UUID()
    let pattern: GrammarPattern
    let noticedDate: Date
    let exposureCount: Int
    var masteryLevel: Double // 0.0 to 1.0
}

struct HighlightedText {
    let originalText: String
    let highlights: [TextHighlight]
    let focusPattern: GrammarPattern
}

struct TextHighlight: Identifiable {
    let id = UUID()
    let range: NSRange
    let pattern: GrammarPattern
    let example: String
    let explanation: String
}

struct EnhancedText {
    let originalText: String
    let enhancements: [InputEnhancement]
}

struct InputEnhancement {
    let range: NSRange
    let text: String
    let type: EnhancementType
}

enum EnhancementType {
    case bold
    case underline
    case highlight
    case color
}

struct NoticingActivity: Identifiable {
    let id: UUID
    let pattern: GrammarPattern
    let contextText: String
    let noticingQuestions: [String]
    let discoveryQuestions: [String]
    let level: DifficultyLevel
}

struct ConsciousnessRaisingTask {
    let pattern: GrammarPattern
    let examples: [String]
    let discoveryQuestions: [String]
    let diagram: String
    let practiceTask: String
}

struct FormMeaningExplanation {
    let form: String
    let meaning: String
    let whenToUse: String
    let commonMistakes: [String]
}
