import SwiftUI
import Speech

struct ConversationPracticeView: View {
    let lesson: Lesson
    let scenario: ConversationScenario

    @StateObject private var autoVoiceService = AutoVoiceService.shared
    @State private var messages: [ConversationMessage] = []
    @State private var isRecording = false
    @State private var showingFeedback = false
    @State private var sessionMetrics = ConversationSessionMetrics()
    @State private var showingResults = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var isAwaitingAIResponse = false
    @State private var error: String?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            // ChatGPT-style black background (adapts to light/dark mode)
            Color(.systemBackground)
                .ignoresSafeArea()
                .preferredColorScheme(.dark)  // Force dark mode for Practice tab

            VStack(spacing: 0) {
                // Header - Minimal like ChatGPT
                PracticeHeaderView(
                    scenario: scenario,
                    onClose: {
                        showingResults = true
                    }
                )
                .background(Color(.systemBackground))

                // Messages Area - ChatGPT style with centered teacher avatar
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 24) {
                            // Centered Teacher Avatar in Circle (ChatGPT-style)
                            VStack(spacing: 16) {
                                ZStack {
                                    // Circular container background
                                    Circle()
                                        .fill(Color(.secondarySystemBackground))
                                        .frame(width: 240, height: 240)
                                        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)

                                    // TalkingTeacherView with animated mouth
                                    TalkingTeacherView(meter: autoVoiceService.audioLevelMonitor)
                                        .frame(width: 200, height: 200)
                                        .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                autoVoiceService.isSpeaking ?
                                                    Color.blue.opacity(0.5) :
                                                    Color.clear,
                                                lineWidth: 3
                                            )
                                            .animation(.easeInOut(duration: 0.3), value: autoVoiceService.isSpeaking)
                                    )
                                }
                                
                                // Speech indicator below avatar
                                if autoVoiceService.isSpeaking {
                                    HStack(spacing: 6) {
                                        ForEach(0..<3) { index in
                                            Circle()
                                                .fill(Color.blue)
                                                .frame(width: 6, height: 6)
                                                .opacity(autoVoiceService.isSpeaking ? 1.0 : 0.3)
                                        }
                                    }
                                    .transition(.opacity)
                                }
                            }
                            .padding(.top, 40)
                            .padding(.bottom, 20)

                            // Messages
                            ForEach(messages) { message in
                                ConversationMessageBubble(message: message)
                                    .id(message.id)
                            }
                            // Show placeholder bubble while awaiting AI response
                            if isAwaitingAIResponse {
                                // Gray bubble indicating AI is typing/processing
                                HStack {
                                    Spacer(minLength: 60)
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 150, height: 44)
                                        .overlay(
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                                        )
                                }
                                .id("awaitingAIResponse")
                            }

                            // Live transcription
                            if isRecording && !autoVoiceService.transcribedText.isEmpty {
                                LiveTranscriptionView(text: autoVoiceService.transcribedText)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                    }
                    .background(Color(.systemBackground))
                    .onChange(of: messages.count) { _ in
                        withAnimation {
                            if isAwaitingAIResponse {
                                proxy.scrollTo("awaitingAIResponse", anchor: .bottom)
                            } else {
                                proxy.scrollTo(messages.last?.id, anchor: .bottom)
                            }
                        }
                    }
                }

                // Fluency Metrics Bar
                FluencyMetricsBar(metrics: autoVoiceService.fluencyMetrics)
                    .padding(.horizontal)
                    .padding(.vertical, 8)

                // Voice Control - ChatGPT style minimal bar
                VoiceControlBar(
                    isRecording: isRecording,
                    isProcessing: autoVoiceService.isProcessing || isAwaitingAIResponse,
                    amplitude: autoVoiceService.currentAmplitude,
                    isSpeaking: autoVoiceService.isSpeaking,
                    onToggleRecording: toggleRecording,
                    onAutoVoiceToggle: toggleAutoVoice
                )
                .background(Color(.systemBackground))
                .padding(.bottom, keyboardHeight > 0 ? keyboardHeight : 30)
            }

            // Feedback Overlay
            if showingFeedback {
                FeedbackOverlay(
                    feedback: sessionMetrics.lastFeedback,
                    onDismiss: {
                        showingFeedback = false
                    }
                )
            }
            
            // Error Alert - ChatGPT style
            if let error = error {
                VStack {
                    Spacer()
                    HStack {
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.red.opacity(0.9))
                            )
                            .padding(.horizontal, 16)
                        Spacer()
                    }
                    .padding(.bottom, 100)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            print("ConversationPracticeView appeared")  // Debug
            requestPermissionsAndStart()
            setupKeyboardObservers()
        }
        .onDisappear {
            autoVoiceService.stopListening()
        }
        .sheet(isPresented: $showingResults) {
            PracticeResultsView(
                lesson: lesson,
                scenario: scenario,
                metrics: SessionMetrics(
                    sessionStartTime: sessionMetrics.sessionStartTime ?? Date(),
                    messageCount: sessionMetrics.messageCount,
                    totalWords: sessionMetrics.totalWords,
                    currentFluencyScore: sessionMetrics.currentFluencyScore,
                    lastFeedback: sessionMetrics.lastFeedback
                ),
                onContinue: {
                    presentationMode.wrappedValue.dismiss()
                },
                onRetry: {
                    showingResults = false
                    resetConversation()
                }
            )
        }
        .onReceive(NotificationCenter.default.publisher(for: .showConversationFeedback)) { notification in
            if let feedback = notification.object as? ConversationFeedback {
                sessionMetrics.lastFeedback = feedback
                showingFeedback = true
            }
        }
    }

    // MARK: - Methods

    private func requestPermissionsAndStart() {
        Task {
            let granted = await SpeechService.shared.requestAuthorizations()
            if granted {
                print("✅ Permissions granted, starting conversation")
                await startConversation()
            } else {
                print("❌ Permissions denied - check Settings")
                // Show alert or message to user
                await MainActor.run {
                    self.error = "Microphone and speech recognition permissions are required. " +
                        "Please enable them in Settings."
                }
            }
        }
    }

    private func startConversation() async {
        // Add initial scenario context message
        let contextMessage = ConversationMessage(
            role: .system,
            content: "📍 \(scenario.context)\n\nYou are: \(scenario.roleYouPlay)\nSpeaking with: \(scenario.aiRole)",
            timestamp: Date()
        )
        messages.append(contextMessage)

        isAwaitingAIResponse = true
        
        // Temporary health check for backend
        do {
            let health = try await APIService.shared.healthCheck()
            print("✅ Backend healthy: \(health.status)")
        } catch {
            print("❌ Backend error: \(error)")
        }
        
        // Generate AI greeting response via new fetchAIResponse method
        let aiGreeting: String
        if let fetchedGreeting = await fetchAIResponse(userText: nil) {
            aiGreeting = fetchedGreeting
            print("✅ Got AI greeting from API")
        } else {
            // Fallback greeting if API fails
            aiGreeting = "Hello! How are you today? Let's practice."
            print("⚠️ Using fallback greeting due to API failure")
        }
        
        await MainActor.run {
            let aiMessage = ConversationMessage(role: .assistant, content: aiGreeting, timestamp: Date())
            messages.append(aiMessage)
            isAwaitingAIResponse = false
            sessionMetrics.messageCount += 1
            sessionMetrics.totalWords += aiGreeting.split(separator: " ").count
            sessionMetrics.currentFluencyScore = autoVoiceService.fluencyMetrics.confidenceScore
        }

        // Speak the greeting
        print("🔊 About to speak AI greeting: \(aiGreeting)")
        await autoVoiceService.speakText(aiGreeting)

        // Start auto-voice conversation if enabled
        if scenario.autoVoiceEnabled {
            print("🎤 Auto-voice enabled, starting listening")
            autoVoiceService.startListening()
            await MainActor.run {
                isRecording = true
            }
        }

        // Start session timer
        await MainActor.run {
            sessionMetrics.sessionStartTime = Date()
        }
    }

    private func toggleRecording() {
        print("🎤 Toggle recording: currently \(isRecording)")
        if isRecording {
            print("⏹ Stopping recording")
            autoVoiceService.stopListening()
            processTranscription()
            isRecording = false
        } else {
            print("▶ Starting recording")
            autoVoiceService.startListening()
            isRecording = true
        }
    }

    private func toggleAutoVoice() {
        autoVoiceService.settings.autoStartRecording.toggle()
        if autoVoiceService.settings.autoStartRecording {
            autoVoiceService.startListening()
            isRecording = true
        }
    }

    private func processTranscription() {
        guard !autoVoiceService.transcribedText.isEmpty else {
            print("⚠️ No transcribed text to process")
            // If no text but recording stopped, restart listening if auto-voice enabled
            if scenario.autoVoiceEnabled {
                Task {
                    await MainActor.run {
                        autoVoiceService.startListening()
                        isRecording = true
                    }
                }
            }
            return
        }
        let userText = autoVoiceService.transcribedText
        print("📝 Processing transcription: '\(userText)'")

        let userMessage = ConversationMessage(
            role: .user,
            content: userText,
            timestamp: Date()
        )
        messages.append(userMessage)

        // Update metrics for user message
        sessionMetrics.messageCount += 1
        sessionMetrics.totalWords += userText.split(separator: " ").count
        sessionMetrics.currentFluencyScore = autoVoiceService.fluencyMetrics.confidenceScore

        // Store transcribed text before clearing (needed for AI response)
        let transcriptionToProcess = userText
        
        // Clear transcribed text for next input AFTER we've stored it
        autoVoiceService.transcribedText = ""

        isAwaitingAIResponse = true

        Task {
            print("🤖 Generating AI response for: '\(transcriptionToProcess)'")
            // Generate AI response based on updated conversation via fetchAIResponse
            if let aiResponseText = await fetchAIResponse(userText: transcriptionToProcess) {
                print("✅ Got AI response: \(aiResponseText)")
                await MainActor.run {
                    let aiMessage = ConversationMessage(role: .assistant, content: aiResponseText, timestamp: Date())
                    messages.append(aiMessage)
                    isAwaitingAIResponse = false

                    // Update metrics for AI response
                    sessionMetrics.messageCount += 1
                    sessionMetrics.totalWords += aiResponseText.split(separator: " ").count
                    sessionMetrics.currentFluencyScore = autoVoiceService.fluencyMetrics.confidenceScore
                }

                // Speak AI response
                print("🔊 Speaking AI response")
                await autoVoiceService.speakText(aiResponseText)

                // If autoVoice is enabled, start listening again after speaking
                if scenario.autoVoiceEnabled {
                    print("🎤 Auto-voice: Restarting listening")
                    autoVoiceService.startListening()
                    await MainActor.run {
                        isRecording = true
                    }
                }
            } else {
                print("❌ Failed to get AI response")
                // If AI response fails, just stop loading
                await MainActor.run {
                    isAwaitingAIResponse = false
                }
                if scenario.autoVoiceEnabled {
                    autoVoiceService.startListening()
                    await MainActor.run {
                        isRecording = true
                    }
                }
            }
        }
    }

    private func resetConversation() {
        messages.removeAll()
        sessionMetrics = ConversationSessionMetrics()
        isAwaitingAIResponse = false
        isRecording = false
        Task {
            await startConversation()
        }
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                withAnimation {
                    keyboardHeight = keyboardFrame.height
                }
            }
        }

        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
            withAnimation {
                keyboardHeight = 0
            }
        }
    }

    private func expression(for state: AutoVoiceService.ConversationState) -> TeacherAvatarView.TeacherExpression {
        switch state {
        case .speaking:
            return .encouraging
        case .processing:
            return .thinking
        case .listening:
            return .happy
        case .waitingForResponse:
            return .neutral
        case .idle:
            return .neutral
        }
    }

    // MARK: - New helper method to fetch AI response using APIService
    private func fetchAIResponse(userText: String?) async -> String? {
        // Build conversation history as [[String: String]]
        // Start with the system/context message(s)
        var conversationHistory: [[String: String]] = []
        for message in messages {
            let roleString: String
            switch message.role {
            case .system:
                roleString = "system"
            case .user:
                roleString = "user"
            case .assistant:
                roleString = "assistant"
            }
            conversationHistory.append([
                "role": roleString,
                "content": message.content
            ])
        }

        // If userText is provided and not empty, append as the last user message
        if let userText = userText, !userText.isEmpty {
            conversationHistory.append([
                "role": "user",
                "content": userText
            ])
        }

        do {
            print("📡 Calling API with \(conversationHistory.count) messages")
            let assistantMessage = try await APIService.shared.sendPracticeMessage(
                message: userText ?? "",
                conversationHistory: conversationHistory,
                targetLanguage: lesson.language.rawValue,
                userLevel: lesson.level.rawValue
            )
            
            print("📥 Received API response: \(String(describing: assistantMessage))")
            
            // Extract the text content from the MessageResponse
            // Try different property access methods
            var responseText: String?
            
            // Method 1: Try direct property access via AnyObject
            if let messageText = (assistantMessage as AnyObject).value(forKey: "message") as? String {
                responseText = messageText
            } else if let text = (assistantMessage as AnyObject).value(forKey: "text") as? String {
                responseText = text
            }
            
            // Method 2: Try Mirror reflection
            if responseText == nil {
                let mirror = Mirror(reflecting: assistantMessage)
                for child in mirror.children {
                    if let label = child.label?.lowercased(),
                       (label.contains("message") || label.contains("text") || label.contains("content")),
                       let value = child.value as? String,
                       !value.isEmpty {
                        responseText = value
                        break
                    }
                }
            }
            
            // Method 3: Try string description and extract meaningful content
            if let text = responseText, !text.isEmpty {
                print("✅ Extracted response text: \(text.prefix(50))...")
                return text
            } else {
                let description = String(describing: assistantMessage)
                if !description.isEmpty && description != "nil" {
                    print("⚠️ Using description as fallback: \(description.prefix(50))...")
                    return description
                }
            }
            
            print("❌ Could not extract text from API response")
            return nil
        } catch {
            print("❌ Error fetching AI response: \(error.localizedDescription)")
            print("❌ Full error: \(error)")
            return nil
        }
    }
}

// MARK: - Practice Header View (ChatGPT-style minimal)
struct PracticeHeaderView: View {
    let scenario: ConversationScenario
    let onClose: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(scenario.title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)

                HStack(spacing: 6) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 11))
                    Text(scenario.roleYouPlay)
                        .font(.system(size: 12))
                }
                .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: onClose) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.secondary)
                    .symbolRenderingMode(.hierarchical)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
}

// MARK: - Message Bubble (ChatGPT-style)
struct ConversationMessageBubble: View {
    let message: ConversationMessage
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if message.role == .user {
                Spacer(minLength: 60)
            }

            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                if message.role == .system {
                    Text(message.content)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                } else {
                    Text(message.content)
                        .font(.system(size: 16))
                        .foregroundColor(message.role == .user ? .white : .primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(message.role == .user ?
                                     Color.blue :  // User messages: blue
                                     Color(.secondarySystemBackground))  // AI: gray in dark mode
                        )
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: message.role == .user ? .trailing : .leading)
                }

                Text(message.timestamp, style: .time)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: message.role == .user ? .trailing : .leading)

            if message.role == .assistant {
                Spacer(minLength: 60)
            }
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Live Transcription View
struct LiveTranscriptionView: View {
    let text: String
    @State private var dots = ""

    var body: some View {
        HStack {
            Spacer(minLength: 60)

            HStack(spacing: 8) {
                Image(systemName: "mic.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.blue)

                Text(text)
                    .font(.system(size: 16))
                    .foregroundColor(.black.opacity(0.6))
                    .italic()

                Text(dots)
                    .font(.system(size: 16))
                    .foregroundColor(.blue)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.blue.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.blue, lineWidth: 1)
                            .opacity(0.5)
                    )
            )
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                withAnimation {
                    dots = dots.count < 3 ? dots + "." : ""
                }
            }
        }
    }
}

// MARK: - Fluency Metrics Bar
struct FluencyMetricsBar: View {
    let metrics: FluencyMetrics

    var body: some View {
        HStack(spacing: 16) {
            MetricPill(
                icon: "speedometer",
                value: "\(Int(metrics.wordsPerMinute))",
                label: "WPM",
                color: metricsColor(for: metrics.wordsPerMinute, target: 120)
            )

            MetricPill(
                icon: "pause.circle",
                value: "\(Int(metrics.pauseFrequency))",
                label: "Pauses/min",
                color: metricsColor(for: 10 - metrics.pauseFrequency, target: 5)
            )

            MetricPill(
                icon: "star.fill",
                value: String(format: "%.1f", metrics.confidenceScore),
                label: "Confidence",
                color: metricsColor(for: metrics.confidenceScore, target: 7)
            )

            MetricPill(
                icon: "waveform",
                value: String(format: "%.0f%%", metrics.naturalness * 10),
                label: "Natural",
                color: metricsColor(for: metrics.naturalness, target: 7)
            )
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))  // Dark mode adaptive
                .shadow(color: .black.opacity(0.3), radius: 5, y: 2)
        )
    }

    func metricsColor(for value: Double, target: Double) -> Color {
        let ratio = value / target
        if ratio >= 0.8 {
            return .green
        } else if ratio >= 0.6 {
            return .orange
        } else {
            return .red
        }
    }
}

// MARK: - Metric Pill
struct MetricPill: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                Text(value)
                    .font(.system(size: 12, weight: .bold))
            }
            .foregroundColor(color)

            Text(label)
                .font(.system(size: 9))
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Voice Control Bar
struct VoiceControlBar: View {
    let isRecording: Bool
    let isProcessing: Bool
    let amplitude: Float
    let isSpeaking: Bool
    let onToggleRecording: () -> Void
    let onAutoVoiceToggle: () -> Void

    @State private var animateWaves = false

    var body: some View {
        HStack(spacing: 20) {
            // Auto Voice Toggle (left)
            Button(action: onAutoVoiceToggle) {
                VStack(spacing: 4) {
                    Image(systemName: "mic.and.signal.meter")
                        .font(.system(size: 20))
                        .foregroundColor(AutoVoiceService.shared.settings.autoStartRecording ?
                                       .green : .gray)

                    Text("Auto")
                        .font(.system(size: 10))
                        .foregroundColor(AutoVoiceService.shared.settings.autoStartRecording ?
                                       .green : .gray)
                }
            }

            // Teacher Avatar as Main Record Button (center) - TalkingTeacherView
            Button(action: onToggleRecording) {
                ZStack {
                    // Circular background
                    Circle()
                        .fill(Color(.secondarySystemBackground))
                        .frame(width: 80, height: 80)

                    TalkingTeacherView(meter: AutoVoiceService.shared.audioLevelMonitor)
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                }
                .scaleEffect(isProcessing ? 0.95 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isProcessing)
                .overlay(
                    Group {
                        // Ring animation when recording
                        if isRecording {
                            Circle()
                                .stroke(Color.blue.opacity(0.5), lineWidth: 2)
                                .scaleEffect(animateWaves ? 1.4 : 1.0)
                                .opacity(animateWaves ? 0.5 : 1)
                                .animation(
                                    Animation.easeOut(duration: 1.5)
                                        .repeatForever(autoreverses: false),
                                    value: animateWaves
                                )
                        }
                    }
                )
            }
            .disabled(isProcessing)

            // Waveform Visualizer (right)
            VStack(spacing: 4) {
                ConversationWaveformView(amplitude: amplitude, isActive: isRecording || isSpeaking)
                    .frame(width: 40, height: 30)

                Text(isRecording ? "Listening..." : (isSpeaking ? "Speaking..." : "Tap to speak"))
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 0)
                .fill(Color(.systemBackground))  // Black in dark mode
                .shadow(color: .black.opacity(0.5), radius: 0, y: -2)
        )
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(.separator))
                .offset(y: -0.5),
            alignment: .top
        )
        .onAppear {
            animateWaves = true
        }
    }
}

// MARK: - Waveform View
struct ConversationWaveformView: View {
    let amplitude: Float
    let isActive: Bool

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<5) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(isActive ? .blue : Color.gray.opacity(0.3))
                    .frame(width: 4, height: waveHeight(for: index))
                    .animation(.easeInOut(duration: 0.1), value: amplitude)
            }
        }
    }

    func waveHeight(for index: Int) -> CGFloat {
        guard isActive else { return 4 }
        let baseHeight: CGFloat = 4
        let maxHeight: CGFloat = 30
        let variation = CGFloat(amplitude) * 100
        let offset = sin(Double(index) * .pi / 4) * variation
        return min(maxHeight, max(baseHeight, baseHeight + offset))
    }
}

// MARK: - Models
struct ConversationMessage: Identifiable {
    let id = UUID()
    let role: MessageRole
    let content: String
    let timestamp: Date

    enum MessageRole {
        case system
        case user
        case assistant
    }
}

struct ConversationSessionMetrics {
    var sessionStartTime: Date?
    var messageCount = 0
    var totalWords = 0
    var currentFluencyScore = 0.0
    var lastFeedback: ConversationFeedback?
}

// MARK: - Feedback Overlay
struct FeedbackOverlay: View {
    let feedback: ConversationFeedback?
    let onDismiss: () -> Void

    var body: some View {
        if let feedback = feedback {
            VStack(spacing: 20) {
                Text("Quick Feedback")
                    .font(.system(size: 20, weight: .bold))

                VStack(alignment: .leading, spacing: 12) {
                    if !feedback.strengths.isEmpty {
                        Label(feedback.strengths.first ?? "", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }

                    if let improvements = feedback.improvements, !improvements.isEmpty {
                        Label(improvements.first ?? "", systemImage: "lightbulb.fill")
                            .foregroundColor(.orange)
                    }
                }

                Button("Continue", action: onDismiss)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(radius: 20)
            )
            .padding(40)
        }
    }
}

#Preview {
    ConversationPracticeView(
        lesson: Lesson.getAllLessons().first!,
        scenario: Lesson.getAllLessons().first!.scenarios.first!
    )
}

