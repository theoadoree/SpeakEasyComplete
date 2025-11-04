import SwiftUI

struct MessageBubbleView: View {
    let message: Message

    var isUser: Bool {
        message.role == .user
    }

    var body: some View {
        HStack {
            if isUser {
                Spacer(minLength: 60)
            }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.body)
                    .foregroundColor(isUser ? .white : .primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        isUser ?
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [Color(.systemGray5), Color(.systemGray6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(18)
                    .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)

                Text(formatTime(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
            }

            if !isUser {
                Spacer(minLength: 60)
            }
        }
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    VStack(spacing: 16) {
        MessageBubbleView(
            message: Message(
                id: UUID(),
                role: .assistant,
                content: "Hello! How are you doing today?",
                timestamp: Date()
            )
        )

        MessageBubbleView(
            message: Message(
                id: UUID(),
                role: .user,
                content: "I'm doing great, thanks for asking!",
                timestamp: Date()
            )
        )

        MessageBubbleView(
            message: Message(
                id: UUID(),
                role: .assistant,
                content: "That's wonderful! What would you like to talk about today?",
                timestamp: Date()
            )
        )
    }
    .padding()
}
