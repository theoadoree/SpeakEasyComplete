//
//  StoriesContentView.swift
//  SpeakEasy
//
//  Created by Claude on 2025-11-01.
//

import SwiftUI

struct StoriesContentView: View {
    @State private var selectedLevel: StoryLevel = .all
    @State private var stories: [Story] = []

    enum StoryLevel: String, CaseIterable {
        case all = "All Levels"
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Level Filter
            VStack(alignment: .leading, spacing: 12) {
                Text("Filter by Level")
                    .font(.headline)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(StoryLevel.allCases, id: \.self) { level in
                            LevelFilterButton(
                                level: level,
                                isSelected: selectedLevel == level,
                                action: { selectedLevel = level }
                            )
                        }
                    }
                }
            }

            // Stories Grid
            VStack(alignment: .leading, spacing: 16) {
                Text("Interactive Stories")
                    .font(.headline)

                Text("Learn Spanish through engaging stories with translations and explanations")
                    .font(.caption)
                    .foregroundColor(.secondary)

                ForEach(filteredStories) { story in
                    StoryCard(story: story)
                }
            }
        }
        .onAppear {
            loadStories()
        }
    }

    private func loadStories() {
        stories = sampleStories()
    }

    private var filteredStories: [Story] {
        if selectedLevel == .all {
            return stories
        }
        return stories.filter { $0.level == selectedLevel.rawValue }
    }

    private func sampleStories() -> [Story] {
        [
            Story(
                id: "1",
                title: "Un Día en el Mercado",
                description: "Follow María as she shops at a local market",
                level: "Beginner",
                duration: 5,
                wordCount: 150,
                hasAudio: true,
                hasDictionary: true,
                genre: "Daily Life",
                coverColor: .blue
            ),
            Story(
                id: "2",
                title: "El Viaje de Pablo",
                description: "Pablo's adventure traveling through Spain",
                level: "Intermediate",
                duration: 10,
                wordCount: 350,
                hasAudio: true,
                hasDictionary: true,
                genre: "Travel",
                coverColor: .orange
            ),
            Story(
                id: "3",
                title: "La Familia García",
                description: "Learn about family life in Mexico City",
                level: "Beginner",
                duration: 6,
                wordCount: 200,
                hasAudio: true,
                hasDictionary: true,
                genre: "Family",
                coverColor: .green
            ),
            Story(
                id: "4",
                title: "El Misterio del Museo",
                description: "A mystery unfolds in a Madrid museum",
                level: "Advanced",
                duration: 15,
                wordCount: 500,
                hasAudio: true,
                hasDictionary: true,
                genre: "Mystery",
                coverColor: .purple
            ),
            Story(
                id: "5",
                title: "Recetas de Abuela",
                description: "Traditional recipes passed down through generations",
                level: "Intermediate",
                duration: 8,
                wordCount: 280,
                hasAudio: true,
                hasDictionary: true,
                genre: "Culture",
                coverColor: .red
            )
        ]
    }
}

struct LevelFilterButton: View {
    let level: StoriesContentView.StoryLevel
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(level.rawValue)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.secondarySystemBackground))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(10)
        }
    }
}

struct Story: Identifiable {
    let id: String
    let title: String
    let description: String
    let level: String
    let duration: Int
    let wordCount: Int
    let hasAudio: Bool
    let hasDictionary: Bool
    let genre: String
    let coverColor: Color
}

struct StoryCard: View {
    let story: Story
    @State private var showingReader = false

    var body: some View {
        Button(action: { showingReader = true }) {
            HStack(spacing: 16) {
                // Story cover
                RoundedRectangle(cornerRadius: 10)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [story.coverColor, story.coverColor.opacity(0.6)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 100)
                    .overlay(
                        VStack {
                            Image(systemName: "book.fill")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                    )

                VStack(alignment: .leading, spacing: 6) {
                    Text(story.title)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(story.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)

                    HStack(spacing: 12) {
                        Label(story.level, systemImage: "chart.bar.fill")
                            .font(.caption2)
                            .foregroundColor(.blue)

                        Label("\(story.duration) min", systemImage: "clock")
                            .font(.caption2)
                            .foregroundColor(.secondary)

                        Label("\(story.wordCount)", systemImage: "doc.text")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    HStack(spacing: 8) {
                        if story.hasAudio {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.caption2)
                                .foregroundColor(.green)
                        }

                        if story.hasDictionary {
                            Image(systemName: "book.closed.fill")
                                .font(.caption2)
                                .foregroundColor(.orange)
                        }

                        Text(story.genre)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.purple.opacity(0.1))
                            .foregroundColor(.purple)
                            .cornerRadius(4)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
        .sheet(isPresented: $showingReader) {
            StoryReaderView(story: story)
        }
    }
}

struct StoryReaderView: View {
    let story: Story
    @Environment(\.dismiss) private var dismiss
    @State private var showingTranslation = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Story header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(story.title)
                            .font(.title)
                            .fontWeight(.bold)

                        HStack {
                            Label(story.level, systemImage: "chart.bar.fill")
                                .font(.caption)
                                .foregroundColor(.blue)

                            Text("•")
                                .foregroundColor(.secondary)

                            Text(story.genre)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()

                    // Audio controls
                    if story.hasAudio {
                        HStack {
                            Button(action: {}) {
                                Image(systemName: "play.circle.fill")
                                    .font(.title)
                            }

                            Slider(value: .constant(0.3))

                            Text("1:23")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                    }

                    // Story content
                    VStack(alignment: .leading, spacing: 12) {
                        Text(sampleStoryText())
                            .lineSpacing(8)
                            .padding()

                        if showingTranslation {
                            Divider()

                            Text(sampleTranslation())
                                .foregroundColor(.secondary)
                                .italic()
                                .padding()
                        }
                    }
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // Translation toggle
                    Button(action: { showingTranslation.toggle() }) {
                        HStack {
                            Image(systemName: showingTranslation ? "eye.slash" : "eye")
                            Text(showingTranslation ? "Hide Translation" : "Show Translation")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
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
    }

    private func sampleStoryText() -> String {
        """
        María se despierta temprano. Hoy es sábado y tiene que ir al mercado. El mercado está lleno de gente y hay muchos colores: frutas rojas, verduras verdes, y flores amarillas.

        "¿Cuánto cuestan los tomates?" pregunta María.

        "Tres euros el kilo," responde el vendedor con una sonrisa.

        María compra tomates, lechugas, y unas naranjas muy dulces. Le gusta ir al mercado porque puede hablar con la gente y practicar su español.
        """
    }

    private func sampleTranslation() -> String {
        """
        María wakes up early. Today is Saturday and she has to go to the market. The market is full of people and there are many colors: red fruits, green vegetables, and yellow flowers.

        "How much do the tomatoes cost?" asks María.

        "Three euros per kilo," responds the seller with a smile.

        María buys tomatoes, lettuce, and some very sweet oranges. She likes going to the market because she can talk with people and practice her Spanish.
        """
    }
}

#Preview {
    StoriesContentView()
}
