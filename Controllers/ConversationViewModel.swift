import Foundation
import SwiftUI

@MainActor
class ConversationViewModel: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var currentConversation: Conversation?
    @Published var messages: [Message] = []
    @Published var isLoading = false
    @Published var isSending = false
    @Published var error: String?
    @Published var isVoiceModeEnabled = false

    private let storageService = StorageService.shared
    private let apiService = APIService.shared
    private let assessmentService = AssessmentService.shared
    private let autoVoiceService = AutoVoiceService.shared

    init() {
        loadConversations()
    }

    // MARK: - Load Conversations
    func loadConversations() {
        conversations = storageService.getConversationHistory()
    }

    // MARK: - Start New Conversation
    func startNewConversation(title: String, language: String) {
        let conversation = Conversation(
            id: UUID(),
            title: title,
            language: language,
            messages: [],
            createdAt: Date(),
            updatedAt: Date()
        )

        currentConversation = conversation
        messages = []

        // Add system greeting
        let greeting = Message(
            id: UUID(),
            role: .assistant,
            content: "Hello! I'm here to help you practice \(language). Let's have a conversation!",
            timestamp: Date()
        )
        messages.append(greeting)
    }

    // MARK: - Load Conversation
    func loadConversation(_ conversation: Conversation) {
        currentConversation = conversation
        messages = conversation.messages
    }

    // MARK: - Send Message
    func sendMessage(_ text: String, userProfile: UserProfile) async {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        guard let conversation = currentConversation else { return }

        isSending = true
        error = nil

        // Add user message
        let userMessage = Message(
            id: UUID(),
            role: .user,
            content: text,
            timestamp: Date()
        )
        messages.append(userMessage)

        do {
            // Prepare conversation history for API
            let history = messages.map { message in
                ["role": message.role.rawValue, "content": message.content]
            }

            var responseMessage: String

            do {
                // Try to send to backend
                let response = try await apiService.sendPracticeMessage(
                    message: text,
                    conversationHistory: history,
                    targetLanguage: userProfile.targetLanguage,
                    userLevel: userProfile.level.rawValue
                )
                responseMessage = response.message
            } catch {
                // Fallback to mock response if backend is unavailable
                print("Backend unavailable: \(error.localizedDescription). Using mock response.")
                responseMessage = generateMockResponse(for: text, language: userProfile.targetLanguage, level: userProfile.level.rawValue)
            }

            // Add assistant response
            let assistantMessage = Message(
                id: UUID(),
                role: .assistant,
                content: responseMessage,
                timestamp: Date()
            )
            messages.append(assistantMessage)

            // Save conversation
            var updatedConversation = conversation
            updatedConversation.messages = messages
            updatedConversation.updatedAt = Date()
            currentConversation = updatedConversation

            try saveConversation(updatedConversation)

            // Check if assessment should be triggered
            if assessmentService.shouldTriggerAssessment(
                messages: messages,
                assessmentPending: userProfile.assessmentPending
            ) {
                // Trigger assessment (handled by PracticeScreen)
            }

        } catch {
            self.error = "Failed to send message: \(error.localizedDescription)"
            // Remove the user message if sending failed
            messages.removeLast()
        }

        isSending = false
    }

    // MARK: - Save Conversation
    private func saveConversation(_ conversation: Conversation) throws {
        // Check if conversation already exists
        if let index = conversations.firstIndex(where: { $0.id == conversation.id }) {
            conversations[index] = conversation
        } else {
            conversations.append(conversation)
        }

        try storageService.saveConversationHistory(conversations)
    }

    // MARK: - Delete Conversation
    func deleteConversation(_ conversation: Conversation) {
        do {
            try storageService.deleteConversation(id: conversation.id)
            conversations.removeAll { $0.id == conversation.id }

            if currentConversation?.id == conversation.id {
                currentConversation = nil
                messages = []
            }
        } catch {
            self.error = "Failed to delete conversation: \(error.localizedDescription)"
        }
    }

    // MARK: - Clear Current Conversation
    func clearCurrentConversation() {
        currentConversation = nil
        messages = []
    }

    // MARK: - Get Conversation Stats
    func getConversationStats() -> (total: Int, messageCount: Int) {
        let total = conversations.count
        let messageCount = conversations.reduce(0) { $0 + $1.messages.count }
        return (total, messageCount)
    }

    // MARK: - Clear Error
    func clearError() {
        error = nil
    }

    // MARK: - Voice Mode Control
    func toggleVoiceMode() {
        isVoiceModeEnabled.toggle()

        if isVoiceModeEnabled {
            // Start voice mode - begin listening
            autoVoiceService.startListening()
        } else {
            // Stop voice mode
            autoVoiceService.stopListening()
        }
    }

    func sendVoiceMessage(_ text: String, userProfile: UserProfile) async {
        // Use the same sendMessage logic but optimized for voice
        await sendMessage(text, userProfile: userProfile)

        // After AI responds, automatically speak the response if voice mode is active
        if isVoiceModeEnabled, let lastMessage = messages.last, lastMessage.role == .assistant {
            speakMessage(lastMessage.content, language: userProfile.targetLanguage)

            // Auto-restart listening after AI finishes speaking
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if self.isVoiceModeEnabled && !self.autoVoiceService.isSpeaking {
                    self.autoVoiceService.startListening()
                }
            }
        }
    }

    func speakMessage(_ text: String, language: String) {
        // Use AutoVoiceService to speak the message
        Task {
            await autoVoiceService.speakText(text)
        }
    }

    // MARK: - Mock Response Generator
    private func generateMockResponse(for userInput: String, language: String, level: String) -> String {
        // Simple mock responses based on language
        let input = userInput.lowercased()

        // Language-specific greetings and common responses
        if input.contains("hello") || input.contains("hi") || input.contains("hola") || input.contains("bonjour") {
            switch language {
            case "Spanish", "Spanish (Spain)", "Spanish (Latin America)":
                return "¡Hola! ¿Cómo estás? I'm happy to practice Spanish with you! Let's have a conversation."
            case "French":
                return "Bonjour! Comment allez-vous? I'm here to help you practice French. What would you like to talk about?"
            case "German":
                return "Guten Tag! Wie geht es Ihnen? Great to practice German with you! What topic interests you?"
            case "Japanese":
                return "こんにちは！元気ですか？Let's practice Japanese together. What would you like to discuss?"
            case "Chinese", "Chinese (Mandarin)":
                return "你好！你好吗？I'm excited to help you practice Chinese! What shall we talk about?"
            default:
                return "Hello! I'm your language tutor. Let's practice \(language) together. What topic would you like to discuss?"
            }
        }

        // Common question responses
        if input.contains("how are you") || input.contains("como estas") || input.contains("comment") {
            switch language {
            case "Spanish", "Spanish (Spain)", "Spanish (Latin America)":
                return "¡Muy bien, gracias! ¿Y tú? (Very well, thanks! And you?) Let's practice more conversational Spanish!"
            case "French":
                return "Je vais très bien, merci! Et vous? (I'm very well, thanks! And you?) Excellent question!"
            case "German":
                return "Mir geht es gut, danke! Und Ihnen? (I'm doing well, thanks! And you?) Great job practicing!"
            default:
                return "I'm doing great! How can I help you practice \(language) today?"
            }
        }

        // Default encouraging response
        let responses = [
            "That's interesting! Can you tell me more about that in \(language)?",
            "Great! Let's continue our conversation. What else would you like to practice?",
            "Excellent! Keep practicing. Would you like to try describing something else?",
            "Very good! Let's keep going. Can you ask me a question in \(language)?",
            "Nice work! For a \(level) level, you're doing well. Let's practice some more!"
        ]

        return responses.randomElement() ?? "Let's keep practicing \(language)! What would you like to talk about?"
    }
}
