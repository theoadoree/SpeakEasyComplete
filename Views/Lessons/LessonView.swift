import SwiftUI
import AVFoundation

struct LessonView: View {
    @StateObject private var viewModel = LessonViewModel()
    @State private var teacherAvatar = TeacherAvatarController()
    @State private var selectedTab = 0
    @State private var userMessage = ""
    @State private var showingSettings = false

    let lesson: Lesson

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.97, blue: 1.0),
                    Color(red: 0.9, green: 0.95, blue: 1.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header with teacher avatar
                TeacherHeaderView(
                    avatar: $teacherAvatar,
                    lesson: lesson,
                    isSpeaking: viewModel.isSpeaking
                )
                .frame(height: 250)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                        .ignoresSafeArea(edges: .top)
                )

                // Tab selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(Tab.allCases, id: \.self) { tab in
                            TabButton(
                                title: tab.title,
                                icon: tab.icon,
                                isSelected: selectedTab == tab.rawValue,
                                action: {
                                    withAnimation(.spring()) {
                                        selectedTab = tab.rawValue
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 10)

                // Content area
                TabView(selection: $selectedTab) {
                    LessonVocabularyView(lessonContent: viewModel.lessonContent)
                        .tag(0)

                    GrammarView(lessonContent: viewModel.lessonContent)
                        .tag(1)

                    ConversationView(
                        viewModel: viewModel,
                        teacherAvatar: $teacherAvatar,
                        userMessage: $userMessage
                    )
                    .tag(2)

                    LessonPracticeView(viewModel: viewModel)
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }

            // Loading overlay
            if viewModel.isLoading {
                LoadingOverlay()
            }
        }
        .navigationBarHidden(true)
        .task {
            await viewModel.loadLesson(lesson)
            teacherAvatar.setExpression(.happy)

            // Welcome message
            if let language = viewModel.currentLesson?.language {
                viewModel.speakText(
                    "Welcome to your \(language.rawValue) lesson! Let's begin learning together.",
                    language: language
                )
                teacherAvatar.startSpeaking()

                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    teacherAvatar.stopSpeaking()
                }
            }
        }
    }

    enum Tab: Int, CaseIterable {
        case vocabulary = 0
        case grammar = 1
        case conversation = 2
        case practice = 3

        var title: String {
            switch self {
            case .vocabulary: return "Vocabulary"
            case .grammar: return "Grammar"
            case .conversation: return "Conversation"
            case .practice: return "Practice"
            }
        }

        var icon: String {
            switch self {
            case .vocabulary: return "book.fill"
            case .grammar: return "text.book.closed"
            case .conversation: return "bubble.left.and.bubble.right"
            case .practice: return "mic"
            }
        }
    }
}

// MARK: - Teacher Header

struct TeacherHeaderView: View {
    @Binding var avatar: TeacherAvatarController
    let lesson: Lesson
    let isSpeaking: Bool

    var body: some View {
        VStack {
            // Teacher Avatar Container
            TeacherAvatarContainer(controller: avatar)
                .frame(width: 200, height: 200)
                .scaleEffect(isSpeaking ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 0.3), value: isSpeaking)

            // Lesson info
            Text("\(lesson.language.flag) \(lesson.title)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            Text(lesson.level.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(lesson.level.color.opacity(0.2))
                .cornerRadius(12)
        }
    }
}

// MARK: - Tab Button

struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(title)
                    .font(.caption)
                    .fontWeight(isSelected ? .bold : .regular)
            }
            .foregroundColor(isSelected ? .white : .gray)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color.blue : Color.gray.opacity(0.1))
            )
        }
    }
}

// MARK: - Vocabulary View

struct LessonVocabularyView: View {
    let lessonContent: LessonContent?

    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                if let vocabulary = lessonContent?.vocabulary {
                    ForEach(vocabulary) { item in
                        VocabularyCardView(item: item)
                    }
                } else {
                    EmptyStateView(
                        icon: "book.fill",
                        message: "Loading vocabulary..."
                    )
                }
            }
            .padding()
        }
    }
}

struct VocabularyCardView: View {
    let item: VocabularyItem
    @State private var isFlipped = false

    var body: some View {
        ZStack {
            // Front (Word)
            if !isFlipped {
                CardFace(
                    title: item.word,
                    subtitle: item.pronunciation,
                    color: .blue
                )
            }

            // Back (Translation)
            if isFlipped {
                CardFace(
                    title: item.translation,
                    subtitle: item.example,
                    color: .green
                )
                .rotation3DEffect(
                    .degrees(180),
                    axis: (x: 0, y: 1, z: 0)
                )
            }
        }
        .frame(height: 120)
        .rotation3DEffect(
            .degrees(isFlipped ? 180 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
        .onTapGesture {
            withAnimation(.spring()) {
                isFlipped.toggle()
            }
        }
    }
}

struct CardFace: View {
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(subtitle)
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(
                    LinearGradient(
                        colors: [color, color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
}

// MARK: - Grammar View

struct GrammarView: View {
    let lessonContent: LessonContent?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let grammar = lessonContent?.grammar {
                    // Title
                    Text(grammar.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)

                    // Explanation
                    Text(grammar.explanation)
                        .font(.body)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue.opacity(0.1))
                        )
                        .padding(.horizontal)

                    // Examples
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Examples:")
                            .font(.headline)

                        ForEach(grammar.examples, id: \.self) { example in
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.caption)
                                Text(example)
                                    .font(.body)
                            }
                        }
                    }
                    .padding(.horizontal)
                } else {
                    EmptyStateView(
                        icon: "text.book.closed",
                        message: "Loading grammar..."
                    )
                }
            }
            .padding(.vertical)
        }
    }
}

// MARK: - Conversation View

struct ConversationView: View {
    @ObservedObject var viewModel: LessonViewModel
    @Binding var teacherAvatar: TeacherAvatarController
    @Binding var userMessage: String
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack {
            // Conversation history
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.conversationHistory) { turn in
                            MessageBubble(turn: turn)
                                .id(turn.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.conversationHistory.count) { _ in
                    withAnimation {
                        proxy.scrollTo(viewModel.conversationHistory.last?.id, anchor: .bottom)
                    }
                }
            }

            // Input area
            VStack(spacing: 8) {
                // Auto Voice Mode Toggle
                HStack {
                    Image(systemName: viewModel.isVoiceModeEnabled ? "mic.fill" : "mic.slash.fill")
                        .foregroundColor(viewModel.isVoiceModeEnabled ? .green : .gray)
                        .font(.caption)

                    Text("Auto Voice Mode")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Toggle("", isOn: Binding(
                        get: { viewModel.isVoiceModeEnabled },
                        set: { _ in viewModel.toggleVoiceMode() }
                    ))
                    .labelsHidden()
                }
                .padding(.horizontal)
                .padding(.vertical, 6)
                .background(Color(.systemGray6))

                HStack {
                    TextField("Type your message...", text: $userMessage)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($isInputFocused)

                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(Color.blue))
                    }
                    .disabled(userMessage.isEmpty || viewModel.isLoading)
                }
            }
            .padding()
            .background(Color.white)
        }
    }

    private func sendMessage() {
        let message = userMessage
        userMessage = ""
        isInputFocused = false

        Task {
            teacherAvatar.setExpression(.thinking)
            await viewModel.sendUserMessage(message)
            teacherAvatar.setExpression(.happy)

            // Animate teacher speaking
            if viewModel.isSpeaking {
                teacherAvatar.startSpeaking()

                // Stop animation when speech ends
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    teacherAvatar.stopSpeaking()
                }
            }
        }
    }
}

struct MessageBubble: View {
    let turn: LessonViewModel.ConversationTurn

    var body: some View {
        HStack {
            if turn.speaker == .user {
                Spacer()
            }

            VStack(alignment: turn.speaker == .user ? .trailing : .leading, spacing: 4) {
                Text(turn.text)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(turn.speaker == .user ? Color.blue : Color.gray.opacity(0.2))
                    )
                    .foregroundColor(turn.speaker == .user ? .white : .primary)

                if let translation = turn.translation {
                    Text(translation)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            if turn.speaker == .teacher {
                Spacer()
            }
        }
    }
}

// MARK: - Practice View

struct LessonPracticeView: View {
    @ObservedObject var viewModel: LessonViewModel

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "mic.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)

            Text("Practice Speaking")
                .font(.title2)
                .fontWeight(.bold)

            Text("Tap the microphone to start practicing your pronunciation")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: {
                // Start recording
            }) {
                Label("Start Practice", systemImage: "mic.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.green)
                    )
            }

            if let feedback = viewModel.currentSession?.feedback, !feedback.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Feedback:")
                        .font(.headline)

                    ForEach(feedback) { item in
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                            VStack(alignment: .leading) {
                                Text(item.content)
                                    .font(.body)
                                if let suggestion = item.suggestion {
                                    Text(suggestion)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.yellow.opacity(0.1))
                )
            }

            Spacer()
        }
        .padding()
    }
}

// MARK: - Helper Views

struct EmptyStateView: View {
    let icon: String
    let message: String

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                Text("Loading lesson...")
                    .font(.body)
                    .foregroundColor(.white)
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.black.opacity(0.8))
            )
        }
    }
}

// MARK: - Teacher Avatar Controller

class TeacherAvatarController: ObservableObject {
    @Published var isSpeaking = false
    @Published var expression: TeacherAvatarView.TeacherExpression = .neutral

    func startSpeaking() {
        isSpeaking = true
    }

    func stopSpeaking() {
        isSpeaking = false
    }

    func setExpression(_ newExpression: TeacherAvatarView.TeacherExpression) {
        expression = newExpression
    }
}

struct TeacherAvatarContainer: View {
    @ObservedObject var controller: TeacherAvatarController
    @State private var avatarView = TeacherAvatarViewState()

    var body: some View {
        TeacherAvatarView(isSpeaking: controller.isSpeaking, expression: controller.expression)
    }
}

class TeacherAvatarViewState: ObservableObject {
    @Published var isSpeaking = false
    @Published var expression: TeacherAvatarView.TeacherExpression = .neutral
}