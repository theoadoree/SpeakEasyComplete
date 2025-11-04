import Foundation

/// Implements Interaction Hypothesis (Long)
/// Two-way communication with negotiation of meaning
@MainActor
class MeaningfulInteractionService: ObservableObject {
    static let shared = MeaningfulInteractionService()

    @Published var conversationState: ConversationState = .idle
    @Published var comprehensionChecks: [ComprehensionCheck] = []
    @Published var clarificationRequests: Int = 0

    private let openAIService = OpenAIService.shared
    private let speechService = SpeechService.shared

    // MARK: - Negotiation of Meaning

    /// AI detects when learner doesn't understand and provides clarification
    func negotiateMeaning(
        userResponse: String,
        previousContext: String,
        targetLanguage: String
    ) async -> NegotiationResponse {
        let prompt = """
        You are a \(targetLanguage) teacher in a conversation. The student just said:
        "\(userResponse)"

        Previous context: \(previousContext)

        Analyze if the student:
        1. Understood correctly (continue naturally)
        2. Misunderstood (provide clarification)
        3. Needs help (offer assistance)
        4. Said something unclear (ask for clarification)

        Respond naturally as a conversation partner would:
        - Use confirmation checks ("You mean...?")
        - Rephrase if needed ("In other words...")
        - Ask clarification questions ("Could you explain that?")
        - Provide hints without giving answers

        Keep it conversational and supportive.
        """

        do {
            let response = try await openAIService.sendMessage(prompt)
            return parseNegotiationResponse(from: response)
        } catch {
            return NegotiationResponse(
                type: .continue,
                message: "I see, please continue.",
                hint: nil
            )
        }
    }

    /// Simulate communication breakdown for learning
    func simulateCommunicationBreakdown(
        context: String,
        level: DifficultyLevel,
        language: String
    ) async -> BreakdownScenario {
        let prompt = """
        Create a realistic communication breakdown scenario for a \(level.rawValue) \(language) learner:

        Context: \(context)

        The AI partner will:
        1. Say something ambiguous or unclear
        2. Wait for learner to ask for clarification
        3. Provide clarification when asked
        4. Continue conversation naturally

        Example exchanges showing:
        - Initial unclear statement
        - Learner asking for clarification (model different ways)
        - AI clarifying
        - Resolution

        Make it realistic - this happens in real conversations!
        """

        do {
            let response = try await openAIService.sendMessage(prompt)
            return parseBreakdownScenario(from: response)
        } catch {
            return BreakdownScenario(
                initialStatement: "...",
                clarificationPrompts: [],
                clarifiedStatement: ""
            )
        }
    }

    // MARK: - Comprehension Checks

    /// AI asks comprehension check questions
    func generateComprehensionCheck(
        after message: String,
        difficulty: DifficultyLevel,
        language: String
    ) async -> ComprehensionCheck {
        let prompt = """
        You just explained this in \(language):
        "\(message)"

        Create a natural comprehension check question for a \(difficulty.rawValue) learner.

        Types of checks:
        - Confirmation: "Did you understand that?"
        - Paraphrase: "Can you tell me what I just said in your own words?"
        - Specific: "What did I say about...?"
        - Action: "Can you show me/tell me how to...?"

        Make it conversational, not like a test.
        """

        do {
            let response = try await openAIService.sendMessage(prompt)
            return ComprehensionCheck(
                question: response,
                originalMessage: message,
                checkType: .paraphrase,
                timestamp: Date()
            )
        } catch {
            return ComprehensionCheck(
                question: "Do you understand?",
                originalMessage: message,
                checkType: .confirmation,
                timestamp: Date()
            )
        }
    }

    /// Evaluate learner's comprehension based on their response
    func evaluateComprehension(
        check: ComprehensionCheck,
        userResponse: String,
        language: String
    ) async -> ComprehensionEvaluation {
        let prompt = """
        Comprehension check question: "\(check.question)"
        Original message: "\(check.originalMessage)"
        Student's response: "\(userResponse)"

        Evaluate:
        1. Did they understand the main idea? (yes/partial/no)
        2. What did they understand correctly?
        3. What did they misunderstand?
        4. How should you respond? (continue/clarify/reteach)

        Respond naturally as a conversation partner.
        """

        do {
            let response = try await openAIService.sendMessage(prompt)
            return parseComprehensionEvaluation(from: response, check: check)
        } catch {
            return ComprehensionEvaluation(
                understood: .partial,
                correctAspects: [],
                misunderstood: [],
                nextAction: .continue,
                feedback: "Let's continue."
            )
        }
    }

    // MARK: - Clarification Requests

    /// Teach learner to request clarification
    func teachClarificationStrategies(
        language: String,
        level: DifficultyLevel
    ) -> [ClarificationStrategy] {
        switch level {
        case .beginner:
            return [
                ClarificationStrategy(
                    phrase: "Sorry, I don't understand",
                    function: "General non-understanding",
                    whenToUse: "When you don't understand at all"
                ),
                ClarificationStrategy(
                    phrase: "Please repeat",
                    function: "Request repetition",
                    whenToUse: "When you need to hear it again"
                ),
                ClarificationStrategy(
                    phrase: "What does [word] mean?",
                    function: "Ask about vocabulary",
                    whenToUse: "When you don't know a specific word"
                )
            ]

        case .intermediate:
            return [
                ClarificationStrategy(
                    phrase: "Could you explain that differently?",
                    function: "Request paraphrase",
                    whenToUse: "When you need another way of explaining"
                ),
                ClarificationStrategy(
                    phrase: "Do you mean...?",
                    function: "Confirmation check",
                    whenToUse: "When you think you understand but want to confirm"
                ),
                ClarificationStrategy(
                    phrase: "I'm not sure about...",
                    function: "Express partial understanding",
                    whenToUse: "When you understand some but not all"
                )
            ]

        case .advanced:
            return [
                ClarificationStrategy(
                    phrase: "What exactly do you mean by...?",
                    function: "Request precision",
                    whenToUse: "When you need more specific information"
                ),
                ClarificationStrategy(
                    phrase: "Could you elaborate on...?",
                    function: "Request expansion",
                    whenToUse: "When you want more details"
                ),
                ClarificationStrategy(
                    phrase: "If I understand correctly...",
                    function: "Paraphrase for confirmation",
                    whenToUse: "To check your understanding"
                )
            ]
        }
    }

    /// Provide feedback when learner uses clarification strategy
    func provideClarificationFeedback(
        strategy used: String,
        appropriate: Bool
    ) -> String {
        if appropriate {
            return "Great! That's a very natural way to ask for clarification. 👍"
        } else {
            return "You can ask for clarification, but try using: '\(suggestBetterStrategy(for: used))'"
        }
    }

    // MARK: - Repair Sequences

    /// Handle conversational repair (fixing misunderstandings)
    func generateRepairSequence(
        misunderstanding: String,
        originalIntent: String,
        language: String
    ) async -> RepairSequence {
        let prompt = """
        In a \(language) conversation:
        What you meant: \(originalIntent)
        What they understood: \(misunderstanding)

        Create a natural repair sequence:
        1. Recognize the misunderstanding
        2. Repair it naturally
        3. Confirm understanding
        4. Continue conversation

        Show authentic repair language.
        """

        do {
            let response = try await openAIService.sendMessage(prompt)
            return parseRepairSequence(from: response)
        } catch {
            return RepairSequence(
                recognition: "I think there was a misunderstanding",
                repair: "What I meant was...",
                confirmation: "Does that make sense now?",
                continuation: "So..."
            )
        }
    }

    // MARK: - Helper Methods

    private func parseNegotiationResponse(from text: String) -> NegotiationResponse {
        // Simplified parsing
        if text.contains("?") {
            return NegotiationResponse(type: .clarify, message: text, hint: nil)
        } else if text.contains("mean") || text.contains("understand") {
            return NegotiationResponse(type: .confirm, message: text, hint: nil)
        } else {
            return NegotiationResponse(type: .continue, message: text, hint: nil)
        }
    }

    private func parseBreakdownScenario(from text: String) -> BreakdownScenario {
        return BreakdownScenario(
            initialStatement: "...",
            clarificationPrompts: [],
            clarifiedStatement: ""
        )
    }

    private func parseComprehensionEvaluation(
        from text: String,
        check: ComprehensionCheck
    ) -> ComprehensionEvaluation {
        return ComprehensionEvaluation(
            understood: .partial,
            correctAspects: [],
            misunderstood: [],
            nextAction: .continue,
            feedback: text
        )
    }

    private func parseRepairSequence(from text: String) -> RepairSequence {
        return RepairSequence(
            recognition: "",
            repair: text,
            confirmation: "",
            continuation: ""
        )
    }

    private func suggestBetterStrategy(for attempt: String) -> String {
        return "Could you please explain that?"
    }
}

// MARK: - Supporting Models

enum ConversationState {
    case idle
    case listening
    case processing
    case responding
    case negotiating
}

struct NegotiationResponse {
    let type: NegotiationType
    let message: String
    let hint: String?

    enum NegotiationType {
        case `continue`    // Understanding is clear
        case clarify     // AI needs clarification from learner
        case confirm     // AI confirms understanding
        case help        // AI offers assistance
    }
}

struct ComprehensionCheck: Identifiable {
    let id = UUID()
    let question: String
    let originalMessage: String
    let checkType: CheckType
    let timestamp: Date

    enum CheckType {
        case confirmation
        case paraphrase
        case specific
        case action
    }
}

struct ComprehensionEvaluation {
    let understood: UnderstandingLevel
    let correctAspects: [String]
    let misunderstood: [String]
    let nextAction: NextAction
    let feedback: String

    enum UnderstandingLevel {
        case full
        case partial
        case minimal
        case none
    }

    enum NextAction {
        case `continue`
        case clarify
        case reteach
        case simplify
    }
}

struct ClarificationStrategy: Identifiable {
    let id = UUID()
    let phrase: String
    let function: String
    let whenToUse: String
}

struct BreakdownScenario {
    let initialStatement: String
    let clarificationPrompts: [String]
    let clarifiedStatement: String
}

struct RepairSequence {
    let recognition: String
    let repair: String
    let confirmation: String
    let continuation: String
}
