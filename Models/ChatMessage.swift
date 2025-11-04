import Foundation

struct ChatMessage: Identifiable {
    enum Role {
        case user
        case assistant
        case system
    }

    let id = UUID()
    let role: Role
    let content: String
    let timestamp: Date = Date()

    // Convenience initializer for compatibility with new viseme system
    init(role: Role, text: String) {
        self.role = role
        self.content = text
    }

    // Original initializer
    init(role: Role, content: String) {
        self.role = role
        self.content = content
    }

    // Convenience property for text
    var text: String {
        return content
    }
}

