// Views/Practice/GuidedPracticeView.swift
import SwiftUI

struct GuidedPracticeView: View {
    @State private var selectedLesson: GuidedLesson?
    @State private var showingLesson = false

    let lessons: [GuidedLesson] = [
        GuidedLesson(
            title: "Greetings & Introductions",
            level: .beginner,
            duration: "10 min",
            exercises: [
                GuidedExercise(type: .listen, content: "¡Hola! ¿Cómo estás?", translation: "Hello! How are you?"),
                GuidedExercise(type: .repeat, content: "Me llamo [nombre]", translation: "My name is [name]"),
                GuidedExercise(type: .respond, content: "¿De dónde eres?", translation: "Where are you from?", expectedResponse: "Soy de..."),
                GuidedExercise(type: .practice, content: "Mucho gusto", translation: "Nice to meet you"),
            ],
            description: "Learn essential greetings and how to introduce yourself",
            icon: "hand.wave.fill"
        ),
        GuidedLesson(
            title: "Numbers & Time",
            level: .beginner,
            duration: "15 min",
            exercises: [
                GuidedExercise(type: .listen, content: "uno, dos, tres", translation: "one, two, three"),
                GuidedExercise(type: .repeat, content: "¿Qué hora es?", translation: "What time is it?"),
                GuidedExercise(type: .respond, content: "Son las tres", translation: "It's 3 o'clock", expectedResponse: "Es la.../Son las..."),
            ],
            description: "Master numbers and telling time in Spanish",
            icon: "clock.fill"
        ),
        GuidedLesson(
            title: "Food & Ordering",
            level: .intermediate,
            duration: "20 min",
            exercises: [
                GuidedExercise(type: .listen, content: "Quisiera un café, por favor", translation: "I would like a coffee, please"),
                GuidedExercise(type: .repeat, content: "¿Qué recomiendas?", translation: "What do you recommend?"),
                GuidedExercise(type: .respond, content: "¿Qué vas a tomar?", translation: "What are you going to have?", expectedResponse: "Voy a tomar..."),
                GuidedExercise(type: .practice, content: "La cuenta, por favor", translation: "The check, please"),
            ],
            description: "Learn to order food and drinks confidently",
            icon: "fork.knife"
        ),
        GuidedLesson(
            title: "Directions & Navigation",
            level: .intermediate,
            duration: "15 min",
            exercises: [
                GuidedExercise(type: .listen, content: "¿Dónde está la estación?", translation: "Where is the station?"),
                GuidedExercise(type: .repeat, content: "Siga todo recto", translation: "Go straight ahead"),
                GuidedExercise(type: .respond, content: "¿Cómo llego al museo?", translation: "How do I get to the museum?", expectedResponse: "Gire a la..."),
                GuidedExercise(type: .practice, content: "Está a la izquierda", translation: "It's on the left"),
            ],
            description: "Navigate Spanish cities with confidence",
            icon: "map.fill"
        ),
        GuidedLesson(
            title: "Past Tense Practice",
            level: .advanced,
            duration: "25 min",
            exercises: [
                GuidedExercise(type: .listen, content: "Ayer fui al mercado", translation: "Yesterday I went to the market"),
                GuidedExercise(type: .repeat, content: "Comí paella", translation: "I ate paella"),
                GuidedExercise(type: .respond, content: "¿Qué hiciste ayer?", translation: "What did you do yesterday?", expectedResponse: "Ayer..."),
                GuidedExercise(type: .practice, content: "Hablé con mis amigos", translation: "I spoke with my friends"),
            ],
            description: "Master past tense conjugations",
            icon: "clock.arrow.circlepath"
        ),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Guided Practice")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Structured lessons with step-by-step exercises")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.top)

                // Level Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterChip(label: "All Levels", isSelected: true)
                        FilterChip(label: "Beginner", isSelected: false)
                        FilterChip(label: "Intermediate", isSelected: false)
                        FilterChip(label: "Advanced", isSelected: false)
                    }
                    .padding(.horizontal)
                }

                // Lessons
                VStack(spacing: 16) {
                    ForEach(lessons) { lesson in
                        GuidedLessonCard(
                            lesson: lesson,
                            onStart: {
                                selectedLesson = lesson
                                showingLesson = true
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom)
        }
        .background(Color(.systemGroupedBackground))
        .fullScreenCover(isPresented: $showingLesson) {
            if let lesson = selectedLesson {
                GuidedLessonSessionView(lesson: lesson)
            }
        }
    }
}

struct FilterChip: View {
    let label: String
    let isSelected: Bool

    var body: some View {
        Text(label)
            .font(.subheadline)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color(.secondarySystemBackground))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
    }
}

struct GuidedLessonCard: View {
    let lesson: GuidedLesson
    let onStart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                // Icon
                Image(systemName: lesson.icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.blue.opacity(0.1)))

                VStack(alignment: .leading, spacing: 4) {
                    Text(lesson.title)
                        .font(.headline)

                    Text(lesson.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                Spacer()
            }

            // Details
            HStack(spacing: 16) {
                Label(lesson.level.rawValue, systemImage: "chart.bar.fill")
                    .font(.caption)
                    .foregroundColor(lesson.level.color)

                Label(lesson.duration, systemImage: "clock.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Label("\(lesson.exercises.count) exercises", systemImage: "list.bullet")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Progress (if started)
            // ProgressView(value: 0.3)
            //     .tint(.blue)

            // Start Button
            Button(action: onStart) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Start Lesson")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8)
    }
}

// MARK: - Guided Lesson Session View

struct GuidedLessonSessionView: View {
    let lesson: GuidedLesson
    @Environment(\.dismiss) var dismiss
    @State private var currentExerciseIndex = 0
    @State private var isRecording = false
    @State private var userResponse = ""
    @State private var exerciseCompleted = false
    @State private var showingFeedback = false
    @StateObject private var speechService = SpeechService.shared

    var currentExercise: GuidedExercise {
        lesson.exercises[currentExerciseIndex]
    }

    var progress: Double {
        Double(currentExerciseIndex) / Double(lesson.exercises.count)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress Bar
                VStack(spacing: 8) {
                    HStack {
                        Text("Exercise \(currentExerciseIndex + 1) of \(lesson.exercises.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Spacer()

                        Text(currentExercise.type.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(currentExercise.type.color.opacity(0.2))
                            .foregroundColor(currentExercise.type.color)
                            .cornerRadius(8)
                    }

                    ProgressView(value: progress)
                        .tint(.blue)
                }
                .padding()
                .background(Color(.systemGroupedBackground))

                Divider()

                // Exercise Content
                ScrollView {
                    VStack(spacing: 24) {
                        // Instruction
                        Text(currentExercise.type.instruction)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .padding()

                        // Spanish Text
                        VStack(spacing: 12) {
                            Text(currentExercise.content)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                                .padding()

                            Text(currentExercise.translation)
                                .font(.title3)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 8)

                        // Expected Response (for respond type)
                        if currentExercise.type == .respond, let expected = currentExercise.expectedResponse {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "lightbulb.fill")
                                        .foregroundColor(.orange)
                                    Text("Try using:")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }

                                Text(expected)
                                    .font(.body)
                                    .foregroundColor(.primary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(12)
                        }

                        // Controls based on exercise type
                        VStack(spacing: 16) {
                            switch currentExercise.type {
                            case .listen:
                                Button(action: playAudio) {
                                    HStack {
                                        Image(systemName: "speaker.wave.3.fill")
                                            .font(.title2)
                                        Text("Play Audio")
                                            .font(.headline)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }

                            case .repeat, .respond, .practice:
                                VStack(spacing: 12) {
                                    // Play button
                                    Button(action: playAudio) {
                                        HStack {
                                            Image(systemName: "speaker.wave.2.fill")
                                            Text("Hear Example")
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(10)
                                    }

                                    // Record button
                                    Button(action: toggleRecording) {
                                        HStack {
                                            Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                                                .font(.title2)
                                            Text(isRecording ? "Stop Recording" : "Record Your Voice")
                                                .font(.headline)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(isRecording ? Color.red : Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                    }

                                    if isRecording {
                                        VoiceWaveformView()
                                            .frame(height: 60)
                                    }
                                }
                            }

                            // Completion feedback
                            if exerciseCompleted {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.title2)

                                    Text("Great job!")
                                        .font(.headline)
                                        .foregroundColor(.green)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                }
                .background(Color(.systemGroupedBackground))

                // Navigation
                HStack(spacing: 16) {
                    if currentExerciseIndex > 0 {
                        Button(action: previousExercise) {
                            Label("Previous", systemImage: "chevron.left")
                        }
                        .padding()
                    }

                    Spacer()

                    if currentExerciseIndex < lesson.exercises.count - 1 {
                        Button(action: nextExercise) {
                            Label("Next", systemImage: "chevron.right")
                                .labelStyle(.trailingIcon)
                        }
                        .padding()
                    } else {
                        Button(action: completeLesson) {
                            Text("Complete Lesson")
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding()
                    }
                }
                .background(Color(.systemBackground))
            }
            .navigationTitle(lesson.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Exit") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func playAudio() {
        // TODO: Implement TTS playback
        exerciseCompleted = true
    }

    private func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        isRecording = true
        do {
            try speechService.startRecording(language: "es-ES")
        } catch {
            print("Failed to start recording: \(error)")
        }
    }

    private func stopRecording() {
        speechService.stopRecording()
        isRecording = false

        if !speechService.recognizedText.isEmpty {
            userResponse = speechService.recognizedText
            exerciseCompleted = true
            speechService.clearRecognizedText()
        }
    }

    private func previousExercise() {
        if currentExerciseIndex > 0 {
            currentExerciseIndex -= 1
            resetExercise()
        }
    }

    private func nextExercise() {
        if currentExerciseIndex < lesson.exercises.count - 1 {
            currentExerciseIndex += 1
            resetExercise()
        }
    }

    private func resetExercise() {
        exerciseCompleted = false
        userResponse = ""
    }

    private func completeLesson() {
        // Show completion screen
        dismiss()
    }
}

// MARK: - Models

struct GuidedLesson: Identifiable {
    let id = UUID()
    let title: String
    let level: LessonLevel
    let duration: String
    let exercises: [GuidedExercise]
    let description: String
    let icon: String

    enum LessonLevel: String {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"

        var color: Color {
            switch self {
            case .beginner: return .green
            case .intermediate: return .orange
            case .advanced: return .red
            }
        }
    }
}

struct GuidedExercise: Identifiable {
    let id = UUID()
    let type: ExerciseType
    let content: String
    let translation: String
    var expectedResponse: String? = nil

    enum ExerciseType: String {
        case listen = "Listen"
        case `repeat` = "Repeat"
        case respond = "Respond"
        case practice = "Practice"

        var instruction: String {
            switch self {
            case .listen:
                return "Listen carefully to the phrase"
            case .repeat:
                return "Listen and repeat after the speaker"
            case .respond:
                return "How would you respond?"
            case .practice:
                return "Practice saying this phrase"
            }
        }

        var color: Color {
            switch self {
            case .listen: return .blue
            case .repeat: return .purple
            case .respond: return .orange
            case .practice: return .green
            }
        }
    }
}

// MARK: - Preview

#Preview {
    GuidedPracticeView()
}
