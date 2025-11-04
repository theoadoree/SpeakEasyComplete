import SwiftUI
import Speech

struct PracticeView: View {
    @State private var selectedMode: PracticeMode = .conversation
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var profileViewModel: UserProfileViewModel
    @EnvironmentObject var conversationViewModel: ConversationViewModel

    enum PracticeMode: String, CaseIterable {
        case conversation = "Conversation"
        case roleplay = "Scenarios"
        case accent = "Pronunciation"
        case guided = "Guided"

        var icon: String {
            switch self {
            case .conversation: return "bubble.left.and.bubble.right.fill"
            case .roleplay: return "theatermasks.fill"
            case .accent: return "waveform"
            case .guided: return "list.bullet.rectangle"
            }
        }

        var description: String {
            switch self {
            case .conversation: return "Chat naturally with AI"
            case .roleplay: return "Practice real-life scenarios"
            case .accent: return "Perfect your pronunciation"
            case .guided: return "Structured exercises"
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Mode Selector with Icons - Adaptive background
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(PracticeMode.allCases, id: \.self) { mode in
                            PracticeModeCard(
                                mode: mode,
                                isSelected: selectedMode == mode,
                                action: {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedMode = mode
                                    }
                                }
                            )
                        }
                    }
                    .padding()
                }
                .background(Color(.systemGroupedBackground))  // Adaptive

                Divider()

                // Content Area - Adaptive
                Group {
                    switch selectedMode {
                    case .conversation:
                        ConversationPracticeView(
                            lesson: Lesson(
                                language: .spanish,
                                level: .intermediate,
                                category: .conversation,
                                title: "Free Practice",
                                description: "Practice speaking",
                                duration: 15,
                                objectives: ["Practice speaking"],
                                completionDate: nil
                            ),
                            scenario: ConversationScenario(
                                id: "practice",
                                title: "Free Practice",
                                description: "Practice conversation",
                                difficulty: "intermediate",
                                context: "General conversation",
                                suggestedPhrases: ["Hola"],
                                objectives: ["Practice"],
                                roleYouPlay: "Student",
                                aiRole: "Teacher",
                                autoVoiceEnabled: true
                            )
                        )
                        .environmentObject(conversationViewModel)
                    case .roleplay:
                        ScenarioPracticeView()
                    case .accent:
                        PronunciationCoachView()
                    case .guided:
                        GuidedPracticeView()
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
            .navigationTitle("Practice")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemBackground))  // Adaptive full background
        }
    }
}

struct PracticeModeCard: View {
    let mode: PracticeView.PracticeMode
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: mode.icon)
                    .font(.title2)
                    .frame(height: 30)
                    .foregroundColor(isSelected ? .white : .primary)  // Adaptive

                Text(mode.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)

                Text(mode.description)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)  // Adaptive secondary
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(width: 110, height: 100)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(isSelected ? Color.accentColor : Color(.secondarySystemBackground))  // Adaptive accent/background
                    .shadow(color: isSelected ? Color.accentColor.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PlaceholderPracticeView: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "wrench.and.screwdriver.fill")
                .font(.system(size: 60))
                .foregroundColor(.secondary)  // Adaptive

            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            Text(subtitle)
                .font(.body)
                .foregroundColor(.secondary)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))  // Adaptive
    }
}

#Preview {
    PracticeView()
        .environmentObject(AppState())
        .environmentObject(UserProfileViewModel())
        .environmentObject(ConversationViewModel())
        .preferredColorScheme(.light)  // Light preview
}

#Preview {
    PracticeView()
        .environmentObject(AppState())
        .environmentObject(UserProfileViewModel())
        .environmentObject(ConversationViewModel())
        .preferredColorScheme(.dark)  // Dark preview
}
