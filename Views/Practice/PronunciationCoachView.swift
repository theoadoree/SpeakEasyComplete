// Views/Practice/PronunciationCoachView.swift
import SwiftUI
import Speech

struct PronunciationCoachView: View {
    @State private var selectedExercise: ExerciseType = .sounds
    @State private var isRecording = false
    @EnvironmentObject var appState: AppState

    enum ExerciseType: String, CaseIterable {
        case sounds = "Sounds"
        case words = "Words"
        case sentences = "Sentences"
        case intonation = "Intonation"

        var icon: String {
            switch self {
            case .sounds: return "waveform.circle.fill"
            case .words: return "text.bubble.fill"
            case .sentences: return "text.alignleft"
            case .intonation: return "chart.line.uptrend.xyaxis"
            }
        }

        var description: String {
            switch self {
            case .sounds: return "Master individual phonemes and sounds"
            case .words: return "Perfect word pronunciation"
            case .sentences: return "Practice natural sentence flow"
            case .intonation: return "Learn pitch patterns and rhythm"
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Exercise Type Selector
            Picker("Exercise Type", selection: $selectedExercise) {
                ForEach(ExerciseType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            // Exercise Description
            HStack {
                Image(systemName: selectedExercise.icon)
                    .font(.title3)
                    .foregroundColor(.blue)

                Text(selectedExercise.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom, 8)

            Divider()

            // Content Area
            ScrollView {
                switch selectedExercise {
                case .sounds:
                    SoundPracticeView()
                case .words:
                    WordPronunciationView()
                case .sentences:
                    SentencePracticeView()
                case .intonation:
                    IntonationPracticeView()
                }
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Sound Practice View

struct SoundPracticeView: View {
    @State private var selectedSound: PhonemePair?
    @State private var isRecording = false
    @State private var userScore: Double = 0
    @State private var showingFeedback = false
    @StateObject private var speechService = SpeechService.shared

    // Common difficult Spanish sounds for English speakers
    let difficultSounds: [PhonemePair] = [
        PhonemePair(phoneme: "rr", example: "perro", translation: "dog", difficulty: .hard),
        PhonemePair(phoneme: "r", example: "pero", translation: "but", difficulty: .medium),
        PhonemePair(phoneme: "j", example: "jota", translation: "letter J", difficulty: .medium),
        PhonemePair(phoneme: "ll", example: "llave", translation: "key", difficulty: .easy),
        PhonemePair(phoneme: "ñ", example: "mañana", translation: "tomorrow", difficulty: .easy),
        PhonemePair(phoneme: "v/b", example: "vaca/baca", translation: "cow/roof rack", difficulty: .hard),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            Text("Practice Sounds")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
                .padding(.top)

            // Sound Cards
            ForEach(difficultSounds, id: \.phoneme) { sound in
                SoundCard(
                    sound: sound,
                    isSelected: selectedSound?.phoneme == sound.phoneme,
                    isRecording: isRecording && selectedSound?.phoneme == sound.phoneme,
                    score: selectedSound?.phoneme == sound.phoneme ? userScore : nil,
                    onTap: {
                        selectedSound = sound
                        playExample(sound)
                    },
                    onRecord: {
                        if isRecording {
                            stopRecording()
                        } else {
                            selectedSound = sound
                            startRecording()
                        }
                    }
                )
                .padding(.horizontal)
            }
        }
        .padding(.bottom)
    }

    private func playExample(_ sound: PhonemePair) {
        // Play audio example using TTS or pre-recorded audio
        // TODO: Implement audio playback
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

        // Analyze pronunciation
        if !speechService.recognizedText.isEmpty {
            analyzePronunciation()
        }
    }

    private func analyzePronunciation() {
        // TODO: Implement pronunciation analysis using speech recognition confidence
        // For now, use a random score as placeholder
        userScore = Double.random(in: 0.6...1.0)
        showingFeedback = true

        // Clear recognized text
        speechService.clearRecognizedText()
    }
}

struct PhonemePair: Identifiable {
    let id = UUID()
    let phoneme: String
    let example: String
    let translation: String
    let difficulty: Difficulty

    enum Difficulty: String {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"

        var color: Color {
            switch self {
            case .easy: return .green
            case .medium: return .orange
            case .hard: return .red
            }
        }
    }
}

struct SoundCard: View {
    let sound: PhonemePair
    let isSelected: Bool
    let isRecording: Bool
    let score: Double?
    let onTap: () -> Void
    let onRecord: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                // Phoneme
                VStack(alignment: .leading, spacing: 4) {
                    Text(sound.phoneme)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)

                    Text(sound.difficulty.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(sound.difficulty.color.opacity(0.2))
                        .foregroundColor(sound.difficulty.color)
                        .cornerRadius(8)
                }

                Spacer()

                // Play Example Button
                Button(action: onTap) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(Color.blue.opacity(0.1)))
                }

                // Record Button
                Button(action: onRecord) {
                    Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.title2)
                        .foregroundColor(isRecording ? .red : .blue)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill((isRecording ? Color.red : Color.blue).opacity(0.1)))
                }
            }

            // Example Word
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Example:")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(sound.example)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text("(\(sound.translation))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Score Display
            if let score = score {
                HStack {
                    Text("Your Score:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    ProgressView(value: score, total: 1.0)
                        .tint(scoreColor(score))

                    Text("\(Int(score * 100))%")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(scoreColor(score))
                }
            }

            // Recording Indicator
            if isRecording {
                HStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)

                    Text("Recording...")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: isSelected ? Color.blue.opacity(0.3) : Color.black.opacity(0.05), radius: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
    }

    private func scoreColor(_ score: Double) -> Color {
        if score >= 0.8 {
            return .green
        } else if score >= 0.6 {
            return .orange
        } else {
            return .red
        }
    }
}

// MARK: - Word Pronunciation View

struct WordPronunciationView: View {
    @State private var selectedCategory: WordCategory = .common
    @State private var currentWordIndex = 0
    @State private var isRecording = false
    @State private var userScore: Double? = nil
    @StateObject private var speechService = SpeechService.shared

    enum WordCategory: String, CaseIterable {
        case common = "Common Words"
        case verbs = "Verbs"
        case food = "Food"
        case travel = "Travel"

        var words: [PracticeWord] {
            switch self {
            case .common:
                return [
                    PracticeWord(word: "gracias", translation: "thank you", ipa: "ˈɡɾa.sjas"),
                    PracticeWord(word: "por favor", translation: "please", ipa: "poɾ fa.ˈβoɾ"),
                    PracticeWord(word: "hola", translation: "hello", ipa: "ˈo.la"),
                    PracticeWord(word: "adiós", translation: "goodbye", ipa: "a.ˈði.os"),
                ]
            case .verbs:
                return [
                    PracticeWord(word: "hablar", translation: "to speak", ipa: "a.ˈβlaɾ"),
                    PracticeWord(word: "comer", translation: "to eat", ipa: "ko.ˈmeɾ"),
                    PracticeWord(word: "vivir", translation: "to live", ipa: "bi.ˈβiɾ"),
                    PracticeWord(word: "trabajar", translation: "to work", ipa: "tɾa.βa.ˈxaɾ"),
                ]
            case .food:
                return [
                    PracticeWord(word: "paella", translation: "paella", ipa: "pa.ˈe.ʎa"),
                    PracticeWord(word: "tortilla", translation: "omelet", ipa: "tor.ˈti.ʎa"),
                    PracticeWord(word: "jamón", translation: "ham", ipa: "xa.ˈmon"),
                    PracticeWord(word: "cerveza", translation: "beer", ipa: "θer.ˈβe.sa"),
                ]
            case .travel:
                return [
                    PracticeWord(word: "aeropuerto", translation: "airport", ipa: "a.e.ɾo.ˈpweɾ.to"),
                    PracticeWord(word: "estación", translation: "station", ipa: "es.ta.ˈsjon"),
                    PracticeWord(word: "hotel", translation: "hotel", ipa: "o.ˈtel"),
                    PracticeWord(word: "restaurante", translation: "restaurant", ipa: "res.taw.ˈɾan.te"),
                ]
            }
        }
    }

    var currentWord: PracticeWord {
        selectedCategory.words[currentWordIndex]
    }

    var body: some View {
        VStack(spacing: 20) {
            // Category Picker
            Picker("Category", selection: $selectedCategory) {
                ForEach(WordCategory.allCases, id: \.self) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding(.horizontal)
            .onChange(of: selectedCategory) { _ in
                currentWordIndex = 0
                userScore = nil
            }

            // Word Card
            VStack(spacing: 16) {
                // Progress Indicator
                HStack {
                    Text("\(currentWordIndex + 1) of \(selectedCategory.words.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text(selectedCategory.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                }

                // Main Word Display
                VStack(spacing: 12) {
                    Text(currentWord.word)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.primary)

                    Text(currentWord.translation)
                        .font(.title3)
                        .foregroundColor(.secondary)

                    Text("IPA: /\(currentWord.ipa)/")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                }
                .padding(.vertical, 24)

                // Controls
                HStack(spacing: 24) {
                    // Listen Button
                    Button(action: playWord) {
                        VStack {
                            Image(systemName: "speaker.wave.3.fill")
                                .font(.title)
                                .frame(width: 60, height: 60)
                                .background(Circle().fill(Color.blue))
                                .foregroundColor(.white)

                            Text("Listen")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    // Record Button
                    Button(action: toggleRecording) {
                        VStack {
                            Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                                .font(.title)
                                .frame(width: 60, height: 60)
                                .background(Circle().fill(isRecording ? Color.red : Color.green))
                                .foregroundColor(.white)

                            Text(isRecording ? "Stop" : "Record")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical)

                // Score Display
                if let score = userScore {
                    VStack(spacing: 8) {
                        HStack {
                            Text("Pronunciation Score")
                                .font(.headline)

                            Spacer()

                            Text("\(Int(score * 100))%")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(scoreColor(score))
                        }

                        ProgressView(value: score, total: 1.0)
                            .tint(scoreColor(score))

                        if score >= 0.8 {
                            Text("Excellent! 🎉")
                                .font(.subheadline)
                                .foregroundColor(.green)
                        } else if score >= 0.6 {
                            Text("Good! Keep practicing.")
                                .font(.subheadline)
                                .foregroundColor(.orange)
                        } else {
                            Text("Listen again and try to match the pronunciation.")
                                .font(.subheadline)
                                .foregroundColor(.red)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }

                // Navigation
                HStack(spacing: 16) {
                    Button(action: previousWord) {
                        Label("Previous", systemImage: "chevron.left")
                    }
                    .disabled(currentWordIndex == 0)

                    Spacer()

                    Button(action: nextWord) {
                        Label("Next", systemImage: "chevron.right")
                            .labelStyle(.trailingIcon)
                    }
                    .disabled(currentWordIndex >= selectedCategory.words.count - 1)
                }
                .padding(.top)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8)
            .padding()
        }
    }

    private func playWord() {
        // TODO: Play TTS audio for the current word
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
        userScore = nil
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
            analyzePronunciation()
        }
    }

    private func analyzePronunciation() {
        // TODO: Compare recognized text with target word
        // For now, use placeholder scoring
        let recognized = speechService.recognizedText.lowercased()
        let target = currentWord.word.lowercased()

        // Simple string similarity as placeholder
        if recognized.contains(target) || target.contains(recognized) {
            userScore = Double.random(in: 0.7...1.0)
        } else {
            userScore = Double.random(in: 0.4...0.7)
        }

        speechService.clearRecognizedText()
    }

    private func previousWord() {
        if currentWordIndex > 0 {
            currentWordIndex -= 1
            userScore = nil
        }
    }

    private func nextWord() {
        if currentWordIndex < selectedCategory.words.count - 1 {
            currentWordIndex += 1
            userScore = nil
        }
    }

    private func scoreColor(_ score: Double) -> Color {
        if score >= 0.8 { return .green }
        else if score >= 0.6 { return .orange }
        else { return .red }
    }
}

struct PracticeWord: Identifiable {
    let id = UUID()
    let word: String
    let translation: String
    let ipa: String
}

// Trailing icon label style
struct TrailingIconLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.title
            configuration.icon
        }
    }
}

extension LabelStyle where Self == TrailingIconLabelStyle {
    static var trailingIcon: TrailingIconLabelStyle { TrailingIconLabelStyle() }
}

// MARK: - Sentence Practice View

struct SentencePracticeView: View {
    @State private var currentSentenceIndex = 0
    @State private var isRecording = false
    @State private var userScore: Double? = nil
    @StateObject private var speechService = SpeechService.shared

    let sentences: [PracticeSentence] = [
        PracticeSentence(
            text: "¿Cómo estás?",
            translation: "How are you?",
            level: "Beginner",
            focusPoint: "Question intonation rises at the end"
        ),
        PracticeSentence(
            text: "Me llamo María y vivo en Madrid.",
            translation: "My name is María and I live in Madrid.",
            level: "Beginner",
            focusPoint: "Link words smoothly without pausing"
        ),
        PracticeSentence(
            text: "¿Dónde está la estación de tren?",
            translation: "Where is the train station?",
            level: "Intermediate",
            focusPoint: "Clear 'd' sound in 'dónde' and 'de'"
        ),
        PracticeSentence(
            text: "Quisiera reservar una mesa para dos personas.",
            translation: "I would like to reserve a table for two people.",
            level: "Intermediate",
            focusPoint: "Formal tone, soft 'd' in 'quisiera'"
        ),
    ]

    var currentSentence: PracticeSentence {
        sentences[currentSentenceIndex]
    }

    var body: some View {
        VStack(spacing: 20) {
            // Progress
            HStack {
                Text("\(currentSentenceIndex + 1) of \(sentences.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text(currentSentence.level)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(levelColor(currentSentence.level).opacity(0.2))
                    .foregroundColor(levelColor(currentSentence.level))
                    .cornerRadius(8)
            }
            .padding(.horizontal)

            // Sentence Card
            VStack(spacing: 20) {
                // Sentence Display
                VStack(spacing: 12) {
                    Text(currentSentence.text)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding()

                    Text(currentSentence.translation)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                // Focus Point
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.orange)

                    Text(currentSentence.focusPoint)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)

                // Controls
                HStack(spacing: 24) {
                    Button(action: playSentence) {
                        VStack {
                            Image(systemName: "speaker.wave.3.fill")
                                .font(.title)
                                .frame(width: 60, height: 60)
                                .background(Circle().fill(Color.blue))
                                .foregroundColor(.white)

                            Text("Listen")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Button(action: toggleRecording) {
                        VStack {
                            Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                                .font(.title)
                                .frame(width: 60, height: 60)
                                .background(Circle().fill(isRecording ? Color.red : Color.green))
                                .foregroundColor(.white)

                            Text(isRecording ? "Stop" : "Record")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical)

                // Score
                if let score = userScore {
                    ScoreFeedbackView(score: score)
                }

                // Navigation
                HStack(spacing: 16) {
                    Button(action: previousSentence) {
                        Label("Previous", systemImage: "chevron.left")
                    }
                    .disabled(currentSentenceIndex == 0)

                    Spacer()

                    Button(action: nextSentence) {
                        Label("Next", systemImage: "chevron.right")
                            .labelStyle(.trailingIcon)
                    }
                    .disabled(currentSentenceIndex >= sentences.count - 1)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8)
            .padding()
        }
    }

    private func playSentence() {
        // TODO: Implement TTS playback
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
        userScore = nil
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
            analyzePronunciation()
        }
    }

    private func analyzePronunciation() {
        // TODO: Implement sentence-level analysis
        userScore = Double.random(in: 0.6...1.0)
        speechService.clearRecognizedText()
    }

    private func previousSentence() {
        if currentSentenceIndex > 0 {
            currentSentenceIndex -= 1
            userScore = nil
        }
    }

    private func nextSentence() {
        if currentSentenceIndex < sentences.count - 1 {
            currentSentenceIndex += 1
            userScore = nil
        }
    }

    private func levelColor(_ level: String) -> Color {
        switch level.lowercased() {
        case "beginner": return .green
        case "intermediate": return .orange
        case "advanced": return .red
        default: return .blue
        }
    }
}

struct PracticeSentence: Identifiable {
    let id = UUID()
    let text: String
    let translation: String
    let level: String
    let focusPoint: String
}

struct ScoreFeedbackView: View {
    let score: Double

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Fluency Score")
                    .font(.headline)

                Spacer()

                Text("\(Int(score * 100))%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(scoreColor)
            }

            ProgressView(value: score, total: 1.0)
                .tint(scoreColor)

            Text(feedbackText)
                .font(.subheadline)
                .foregroundColor(scoreColor)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private var scoreColor: Color {
        if score >= 0.8 { return .green }
        else if score >= 0.6 { return .orange }
        else { return .red }
    }

    private var feedbackText: String {
        if score >= 0.8 {
            return "Excellent fluency! 🎉"
        } else if score >= 0.6 {
            return "Good job! Keep practicing for smoother flow."
        } else {
            return "Listen to the model and try to match the rhythm."
        }
    }
}

// MARK: - Intonation Practice View

struct IntonationPracticeView: View {
    @State private var selectedPattern: IntonationPattern = .rising
    @State private var isRecording = false
    @State private var userScore: Double? = nil

    enum IntonationPattern: String, CaseIterable {
        case rising = "Rising (Questions)"
        case falling = "Falling (Statements)"
        case risefall = "Rise-Fall (Surprise)"
        case fallrise = "Fall-Rise (Uncertainty)"

        var description: String {
            switch self {
            case .rising:
                return "Voice goes up at the end, typical for yes/no questions"
            case .falling:
                return "Voice goes down at the end, typical for statements"
            case .risefall:
                return "Voice rises then falls, showing surprise or excitement"
            case .fallrise:
                return "Voice falls then rises, indicating uncertainty"
            }
        }

        var examples: [String] {
            switch self {
            case .rising:
                return ["¿Hablas español?", "¿Quieres café?", "¿Estás bien?"]
            case .falling:
                return ["Hablo español.", "Quiero café.", "Estoy bien."]
            case .risefall:
                return ["¡Qué sorpresa!", "¡No me digas!", "¡Increíble!"]
            case .fallrise:
                return ["No sé...", "Tal vez...", "Bueno..."]
            }
        }

        var icon: String {
            switch self {
            case .rising: return "arrow.up.right"
            case .falling: return "arrow.down.right"
            case .risefall: return "arrow.up.and.down"
            case .fallrise: return "arrow.down.and.up"
            }
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            // Pattern Selector
            VStack(alignment: .leading, spacing: 12) {
                Text("Select Intonation Pattern")
                    .font(.headline)
                    .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(IntonationPattern.allCases, id: \.self) { pattern in
                            IntonationPatternCard(
                                pattern: pattern,
                                isSelected: selectedPattern == pattern,
                                onTap: {
                                    selectedPattern = pattern
                                    userScore = nil
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }

            // Pattern Info
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: selectedPattern.icon)
                        .font(.title2)
                        .foregroundColor(.blue)

                    Text(selectedPattern.rawValue)
                        .font(.title3)
                        .fontWeight(.semibold)
                }

                Text(selectedPattern.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Divider()

                Text("Practice Examples")
                    .font(.headline)

                ForEach(selectedPattern.examples, id: \.self) { example in
                    IntonationExampleRow(
                        text: example,
                        pattern: selectedPattern,
                        onPlay: { playExample(example) }
                    )
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8)
            .padding(.horizontal)

            // Record Section
            VStack(spacing: 16) {
                Text("Record Yourself")
                    .font(.headline)

                Button(action: toggleRecording) {
                    HStack {
                        Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                            .font(.title)

                        Text(isRecording ? "Stop Recording" : "Start Recording")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isRecording ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }

                if let score = userScore {
                    ScoreFeedbackView(score: score)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8)
            .padding(.horizontal)

            Spacer()
        }
        .padding(.top)
    }

    private func playExample(_ text: String) {
        // TODO: Play with proper intonation
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
        userScore = nil
    }

    private func stopRecording() {
        isRecording = false
        // TODO: Analyze intonation pattern
        userScore = Double.random(in: 0.6...1.0)
    }
}

struct IntonationPatternCard: View {
    let pattern: IntonationPracticeView.IntonationPattern
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: pattern.icon)
                    .font(.title2)

                Text(pattern.rawValue)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 120, height: 80)
            .background(isSelected ? Color.blue : Color(.secondarySystemBackground))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(12)
        }
    }
}

struct IntonationExampleRow: View {
    let text: String
    let pattern: IntonationPracticeView.IntonationPattern
    let onPlay: () -> Void

    var body: some View {
        HStack {
            Text(text)
                .font(.body)

            Spacer()

            Button(action: onPlay) {
                Image(systemName: "play.circle.fill")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

// MARK: - Preview

#Preview {
    PronunciationCoachView()
        .environmentObject(AppState())
}
