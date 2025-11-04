import SwiftUI

/// Chat transcript view with auto-scrolling message bubbles
/// Displays conversation between user and assistant in a scrollable list
struct ChatTranscriptView: View {
    let messages: [ChatMessage]

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(messages) { m in
                        HStack {
                            if m.role == .assistant {
                                Bubble(text: m.text, color: .gray.opacity(0.15), alignment: .leading)
                                Spacer(minLength: 32)
                            } else {
                                Spacer(minLength: 32)
                                Bubble(text: m.text, color: .accentColor.opacity(0.18), alignment: .trailing)
                            }
                        }
                        .id(m.id)
                        .padding(.horizontal, 4)
                    }
                }
                .padding(.vertical, 6)
            }
            .onChange(of: messages.count) { _ in
                if let last = messages.last {
                    withAnimation {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
    }
}

private struct Bubble: View {
    let text: String
    let color: Color
    let alignment: HorizontalAlignment

    var body: some View {
        Text(text)
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(color, in: RoundedRectangle(cornerRadius: 16))
            .frame(maxWidth: .infinity, alignment: alignment == .leading ? .leading : .trailing)
    }
}

#Preview {
    ChatTranscriptView(messages: [
        ChatMessage(role: .assistant, text: "Hello! How can I help you practice today?"),
        ChatMessage(role: .user, text: "I'd like to practice greetings in Spanish."),
        ChatMessage(role: .assistant, text: "Great! Let's start with 'Hola, ¿cómo estás?'")
    ])
    .padding()
}
