//
//  SongLearningView.swift
//  SpeakEasy
//
//  Created by Claude on 2025-11-01.
//

import SwiftUI
import AVFoundation

struct SongLearningView: View {
    let song: Song
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: SongLearningViewModel
    @State private var selectedTab: LearningTab = .lyrics

    enum LearningTab: String, CaseIterable {
        case lyrics = "Lyrics"
        case vocabulary = "Vocabulary"
        case grammar = "Grammar"
        case culture = "Culture"
    }

    init(song: Song) {
        self.song = song
        self._viewModel = StateObject(wrappedValue: SongLearningViewModel(song: song))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Song Header
                SongHeaderView(song: song)

                // Tab Selector
                Picker("Learning Mode", selection: $selectedTab) {
                    ForEach(LearningTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                // Content Area
                ScrollView {
                    Group {
                        switch selectedTab {
                        case .lyrics:
                            LyricsView(viewModel: viewModel)
                        case .vocabulary:
                            VocabularyView(viewModel: viewModel)
                        case .grammar:
                            GrammarView(viewModel: viewModel)
                        case .culture:
                            CultureView(viewModel: viewModel)
                        }
                    }
                    .padding()
                }

                // Action Bar
                ActionBarView(song: song, viewModel: viewModel)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            viewModel.analyzeSong()
        }
    }
}

struct SongHeaderView: View {
    let song: Song

    var body: some View {
        VStack(spacing: 12) {
            // Album Art
            RoundedRectangle(cornerRadius: 15)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [.blue, .purple]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 120, height: 120)
                .overlay(
                    Image(systemName: "music.note")
                        .font(.system(size: 50))
                        .foregroundColor(.white.opacity(0.8))
                )
                .shadow(radius: 10)

            // Song Info
            Text(song.title)
                .font(.title2)
                .fontWeight(.bold)

            Text(song.artist)
                .font(.subheadline)
                .foregroundColor(.secondary)

            // Difficulty & Stats
            HStack(spacing: 20) {
                HStack(spacing: 4) {
                    Image(systemName: "chart.bar.fill")
                        .font(.caption)
                    Text(difficultyText)
                        .font(.caption)
                }
                .foregroundColor(.blue)

                HStack(spacing: 4) {
                    Image(systemName: "text.book.closed.fill")
                        .font(.caption)
                    Text("\(song.vocabularyCount) words")
                        .font(.caption)
                }
                .foregroundColor(.green)

                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.caption)
                    Text(song.duration)
                        .font(.caption)
                }
                .foregroundColor(.orange)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
    }

    private var difficultyText: String {
        switch song.difficultyLevel {
        case 1: return "Beginner"
        case 2: return "Intermediate"
        case 3: return "Advanced"
        default: return "Unknown"
        }
    }
}

struct LyricsView: View {
    @ObservedObject var viewModel: SongLearningViewModel
    @State private var selectedWord: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if viewModel.isAnalyzing {
                ProgressView("Analyzing lyrics with AI...")
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                // Interactive Lyrics
                Text("Tap any word for translation and explanation")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if let lyrics = viewModel.analyzedLyrics {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(lyrics.lines, id: \.self) { line in
                            LyricLine(line: line, selectedWord: $selectedWord)
                        }
                    }
                } else {
                    Text("Lyrics not available")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
        }
        .sheet(item: $selectedWord) { word in
            WordDetailSheet(word: word, viewModel: viewModel)
        }
    }
}

struct LyricLine: View {
    let line: String
    @Binding var selectedWord: String?

    var body: some View {
        let words = line.split(separator: " ").map(String.init)

        FlowLayout(spacing: 8) {
            ForEach(words, id: \.self) { word in
                Button(action: {
                    selectedWord = cleanWord(word)
                }) {
                    Text(word)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)
                }
            }
        }
    }

    private func cleanWord(_ word: String) -> String {
        word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
    }
}

struct VocabularyView: View {
    @ObservedObject var viewModel: SongLearningViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if viewModel.isAnalyzing {
                ProgressView("Extracting vocabulary...")
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                Text("Key Vocabulary from This Song")
                    .font(.headline)

                if let vocab = viewModel.vocabulary {
                    ForEach(vocab, id: \.word) { item in
                        VocabularyCard(item: item)
                    }
                } else {
                    Text("No vocabulary data available")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

struct VocabularyCard: View {
    let item: VocabularyItem
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.word)
                            .font(.headline)
                            .foregroundColor(.primary)

                        Text(item.translation)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.blue)
                }
            }

            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    // Context from song
                    if let context = item.contextInSong {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("In the song:")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)

                            Text("\"\(context)\"")
                                .font(.caption)
                                .italic()
                                .padding(8)
                                .background(Color(.tertiarySystemBackground))
                                .cornerRadius(6)
                        }
                    }

                    // Example sentence
                    if let example = item.exampleSentence {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Example:")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)

                            Text(example)
                                .font(.caption)
                                .padding(8)
                                .background(Color(.tertiarySystemBackground))
                                .cornerRadius(6)
                        }
                    }

                    // Grammar notes
                    if let grammar = item.grammarNotes {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Grammar:")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)

                            Text(grammar)
                                .font(.caption)
                                .padding(8)
                                .background(Color(.tertiarySystemBackground))
                                .cornerRadius(6)
                        }
                    }

                    // Add to SRS button
                    Button(action: {
                        // Add to spaced repetition system
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add to Review")
                        }
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct GrammarView: View {
    @ObservedObject var viewModel: SongLearningViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if viewModel.isAnalyzing {
                ProgressView("Analyzing grammar patterns...")
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                Text("Grammar Patterns in This Song")
                    .font(.headline)

                if let patterns = viewModel.grammarPatterns {
                    ForEach(patterns, id: \.pattern) { pattern in
                        GrammarPatternCard(pattern: pattern)
                    }
                } else {
                    Text("No grammar analysis available")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

struct GrammarPatternCard: View {
    let pattern: GrammarPattern
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(pattern.pattern)
                            .font(.headline)
                            .foregroundColor(.primary)

                        Text(pattern.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.blue)
                }
            }

            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(pattern.examples, id: \.self) { example in
                        Text("• \(example)")
                            .font(.caption)
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.tertiarySystemBackground))
                            .cornerRadius(6)
                    }

                    if let explanation = pattern.explanation {
                        Text(explanation)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct CultureView: View {
    @ObservedObject var viewModel: SongLearningViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if viewModel.isAnalyzing {
                ProgressView("Discovering cultural context...")
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                Text("Cultural Context")
                    .font(.headline)

                if let culture = viewModel.culturalContext {
                    VStack(alignment: .leading, spacing: 16) {
                        // Artist background
                        if let artistInfo = culture.artistBackground {
                            InfoCard(
                                title: "About \(song.artist)",
                                content: artistInfo,
                                icon: "person.fill",
                                color: .blue
                            )
                        }

                        // Song meaning
                        if let meaning = culture.songMeaning {
                            InfoCard(
                                title: "Song Meaning",
                                content: meaning,
                                icon: "music.note",
                                color: .purple
                            )
                        }

                        // Cultural references
                        if let references = culture.culturalReferences {
                            InfoCard(
                                title: "Cultural References",
                                content: references,
                                icon: "globe",
                                color: .green
                            )
                        }

                        // Musical style
                        if let style = culture.musicalStyle {
                            InfoCard(
                                title: "Musical Style: \(song.genre)",
                                content: style,
                                icon: "waveform",
                                color: .orange
                            )
                        }
                    }
                } else {
                    Text("No cultural context available")
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    let song: Song

    init(viewModel: SongLearningViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self.song = viewModel.song
    }
}

struct InfoCard: View {
    let title: String
    let content: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
                    .foregroundColor(color)
            }

            Text(content)
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct ActionBarView: View {
    let song: Song
    @ObservedObject var viewModel: SongLearningViewModel

    var body: some View {
        HStack(spacing: 16) {
            // Play button
            Button(action: {
                // Play song preview or open in music service
            }) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Play")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }

            // Add all vocabulary
            Button(action: {
                viewModel.addAllToSRS()
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add All")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(12)
            }

            // Share
            Button(action: {
                // Share song
            }) {
                Image(systemName: "square.and.arrow.up")
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .shadow(color: Color.black.opacity(0.1), radius: 5, y: -2)
    }
}

// MARK: - View Model

class SongLearningViewModel: ObservableObject {
    let song: Song
    @Published var isAnalyzing = false
    @Published var analyzedLyrics: AnalyzedLyrics?
    @Published var vocabulary: [VocabularyItem]?
    @Published var grammarPatterns: [GrammarPattern]?
    @Published var culturalContext: CulturalContext?

    private let openAIService: OpenAIService

    init(song: Song) {
        self.song = song
        self.openAIService = OpenAIService()
    }

    func analyzeSong() {
        Task {
            await performAnalysis()
        }
    }

    @MainActor
    private func performAnalysis() async {
        isAnalyzing = true

        // In production, call OpenAI API to analyze lyrics
        // For now, use sample data
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds

        // Sample analyzed data
        analyzedLyrics = AnalyzedLyrics(
            lines: [
                "Bailando, bailando, bailando",
                "Tu cuerpo y el mío llenando el vacío",
                "Subiendo y bajando",
                "Bailando, bailando, bailando"
            ]
        )

        vocabulary = [
            VocabularyItem(
                word: "bailando",
                translation: "dancing",
                contextInSong: "Bailando, bailando, bailando",
                exampleSentence: "Me gusta bailando salsa los fines de semana.",
                grammarNotes: "Gerund form of 'bailar' (to dance). Used for continuous actions.",
                difficulty: 1
            ),
            VocabularyItem(
                word: "cuerpo",
                translation: "body",
                contextInSong: "Tu cuerpo y el mío llenando el vacío",
                exampleSentence: "El ejercicio es bueno para el cuerpo.",
                grammarNotes: "Masculine noun. Plural: cuerpos",
                difficulty: 1
            ),
            VocabularyItem(
                word: "vacío",
                translation: "emptiness, void",
                contextInSong: "llenando el vacío",
                exampleSentence: "Siento un vacío en mi corazón.",
                grammarNotes: "Can be used as noun or adjective",
                difficulty: 2
            )
        ]

        grammarPatterns = [
            GrammarPattern(
                pattern: "Gerund (-ando/-iendo)",
                description: "Present continuous action",
                examples: [
                    "bailando (dancing)",
                    "llenando (filling)",
                    "subiendo (going up)",
                    "bajando (going down)"
                ],
                explanation: "The gerund is formed by adding -ando to -ar verbs and -iendo to -er/-ir verbs. It expresses ongoing actions."
            )
        ]

        culturalContext = CulturalContext(
            artistBackground: "Enrique Iglesias is a Spanish singer who became one of the most successful Latin artists worldwide. He's known for blending pop with Latin rhythms.",
            songMeaning: "This song celebrates the joy and freedom of dancing, using it as a metaphor for romantic connection and living in the moment.",
            culturalReferences: "The song incorporates elements of reggaeton and Latin pop, which are hugely popular across Latin America and Spain.",
            musicalStyle: "Pop Latino combines traditional Latin rhythms with contemporary pop music, characterized by catchy melodies and danceable beats."
        )

        isAnalyzing = false
    }

    func addAllToSRS() {
        // Add all vocabulary to spaced repetition system
        guard let vocab = vocabulary else { return }
        // Implementation would save to Core Data/SRS system
        print("Adding \(vocab.count) words to SRS")
    }
}

// MARK: - Supporting Models

struct AnalyzedLyrics {
    let lines: [String]
}

struct VocabularyItem {
    let word: String
    let translation: String
    let contextInSong: String?
    let exampleSentence: String?
    let grammarNotes: String?
    let difficulty: Int
}

struct GrammarPattern {
    let pattern: String
    let description: String
    let examples: [String]
    let explanation: String?
}

struct CulturalContext {
    let artistBackground: String?
    let songMeaning: String?
    let culturalReferences: String?
    let musicalStyle: String?
}

// MARK: - Helper Views

struct WordDetailSheet: View {
    let word: String
    @ObservedObject var viewModel: SongLearningViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(word)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                if let item = viewModel.vocabulary?.first(where: { $0.word.lowercased() == word.lowercased() }) {
                    VocabularyCard(item: item)
                } else {
                    Text("Loading definition...")
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Word Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// Custom Flow Layout for wrapping text
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

extension String: Identifiable {
    public var id: String { self }
}

#Preview {
    SongLearningView(song: Song(
        id: "1",
        title: "Bailando",
        artist: "Enrique Iglesias",
        album: "Sex and Love",
        duration: "4:03",
        spotifyURL: nil,
        appleMusicURL: nil,
        youtubeURL: nil,
        difficultyLevel: 1,
        vocabularyCount: 45,
        lyrics: nil,
        genre: "Pop Latino",
        releaseYear: 2014
    ))
}
