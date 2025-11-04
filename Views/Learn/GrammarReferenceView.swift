//
//  GrammarReferenceView.swift
//  SpeakEasy
//
//  Created by Claude on 2025-11-01.
//

import SwiftUI

struct GrammarReferenceView: View {
    @State private var selectedCategory: GrammarCategory = .all
    @State private var searchText = ""
    @State private var grammarTopics: [GrammarTopic] = []

    enum GrammarCategory: String, CaseIterable {
        case all = "All"
        case verbs = "Verbs"
        case nouns = "Nouns"
        case pronouns = "Pronouns"
        case adjectives = "Adjectives"
        case prepositions = "Prepositions"
        case tenses = "Tenses"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Search
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)

                TextField("Search grammar topics...", text: $searchText)

                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(10)
            .background(Color(.tertiarySystemBackground))
            .cornerRadius(10)

            // Category filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(GrammarCategory.allCases, id: \.self) { category in
                        GrammarCategoryButton(
                            category: category,
                            isSelected: selectedCategory == category,
                            action: { selectedCategory = category }
                        )
                    }
                }
            }

            // Grammar topics
            VStack(alignment: .leading, spacing: 12) {
                Text("Grammar Reference")
                    .font(.headline)

                ForEach(filteredTopics) { topic in
                    GrammarTopicCard(topic: topic)
                }
            }
        }
        .onAppear {
            loadGrammarTopics()
        }
    }

    private func loadGrammarTopics() {
        grammarTopics = sampleGrammarTopics()
    }

    private var filteredTopics: [GrammarTopic] {
        var topics = grammarTopics

        if selectedCategory != .all {
            topics = topics.filter { $0.category == selectedCategory.rawValue }
        }

        if !searchText.isEmpty {
            topics = topics.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }

        return topics
    }

    private func sampleGrammarTopics() -> [GrammarTopic] {
        [
            GrammarTopic(
                id: "1",
                title: "Present Tense (Presente)",
                description: "Regular and irregular verb conjugations",
                category: "Tenses",
                level: "Beginner",
                iconColor: .blue
            ),
            GrammarTopic(
                id: "2",
                title: "Ser vs Estar",
                description: "When to use each 'to be' verb",
                category: "Verbs",
                level: "Beginner",
                iconColor: .green
            ),
            GrammarTopic(
                id: "3",
                title: "Gender and Articles",
                description: "El/La, Un/Una, masculine and feminine",
                category: "Nouns",
                level: "Beginner",
                iconColor: .orange
            ),
            GrammarTopic(
                id: "4",
                title: "Subject Pronouns",
                description: "Yo, tú, él, ella, nosotros, vosotros, ellos",
                category: "Pronouns",
                level: "Beginner",
                iconColor: .purple
            ),
            GrammarTopic(
                id: "5",
                title: "Adjective Agreement",
                description: "Matching adjectives with nouns",
                category: "Adjectives",
                level: "Beginner",
                iconColor: .red
            ),
            GrammarTopic(
                id: "6",
                title: "Por vs Para",
                description: "Understanding these tricky prepositions",
                category: "Prepositions",
                level: "Intermediate",
                iconColor: .blue
            ),
            GrammarTopic(
                id: "7",
                title: "Preterite vs Imperfect",
                description: "Choosing the right past tense",
                category: "Tenses",
                level: "Intermediate",
                iconColor: .green
            ),
            GrammarTopic(
                id: "8",
                title: "Subjunctive Mood",
                description: "When and how to use the subjunctive",
                category: "Verbs",
                level: "Advanced",
                iconColor: .orange
            )
        ]
    }
}

struct GrammarCategoryButton: View {
    let category: GrammarReferenceView.GrammarCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(category.rawValue)
                .font(.subheadline)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.secondarySystemBackground))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(10)
        }
    }
}

struct GrammarTopic: Identifiable {
    let id: String
    let title: String
    let description: String
    let category: String
    let level: String
    let iconColor: Color
}

struct GrammarTopicCard: View {
    let topic: GrammarTopic
    @State private var showingDetail = false

    var body: some View {
        Button(action: { showingDetail = true }) {
            HStack(spacing: 16) {
                // Icon
                Circle()
                    .fill(topic.iconColor.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: iconForCategory(topic.category))
                            .foregroundColor(topic.iconColor)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(topic.title)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(topic.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)

                    HStack {
                        Text(topic.level)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(4)

                        Text(topic.category)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
        .sheet(isPresented: $showingDetail) {
            GrammarDetailView(topic: topic)
        }
    }

    private func iconForCategory(_ category: String) -> String {
        switch category {
        case "Verbs": return "text.word.spacing"
        case "Nouns": return "textformat"
        case "Pronouns": return "person.fill"
        case "Adjectives": return "paintbrush.fill"
        case "Prepositions": return "arrow.triangle.branch"
        case "Tenses": return "clock.fill"
        default: return "book.fill"
        }
    }
}

struct GrammarDetailView: View {
    let topic: GrammarTopic
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(topic.title)
                            .font(.title)
                            .fontWeight(.bold)

                        HStack {
                            Label(topic.level, systemImage: "chart.bar.fill")
                                .font(.caption)
                                .foregroundColor(.blue)

                            Text("•")
                                .foregroundColor(.secondary)

                            Text(topic.category)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()

                    // Explanation
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Explanation")
                            .font(.headline)

                        Text(getExplanation(for: topic))
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // Examples
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Examples")
                            .font(.headline)

                        ForEach(getExamples(for: topic), id: \.self) { example in
                            ExampleRow(example: example)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // Practice button
                    Button(action: {
                        // Start practice exercises
                    }) {
                        HStack {
                            Image(systemName: "pencil")
                            Text("Practice This Topic")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    .padding()
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

    private func getExplanation(for topic: GrammarTopic) -> String {
        switch topic.title {
        case "Ser vs Estar":
            return """
            Both 'ser' and 'estar' mean 'to be' in English, but they're used in different contexts:

            SER is used for:
            • Permanent characteristics (tall, smart, blue)
            • Occupations and relationships
            • Origin and nationality
            • Time and dates
            • Material or composition

            ESTAR is used for:
            • Location and position
            • Temporary states and conditions
            • Emotions and feelings
            • Progressive tenses (-ing)
            """
        case "Present Tense (Presente)":
            return """
            The present tense in Spanish is used to describe actions happening now, habitual actions, and general truths.

            Regular verb endings:
            -AR verbs: -o, -as, -a, -amos, -áis, -an
            -ER verbs: -o, -es, -e, -emos, -éis, -en
            -IR verbs: -o, -es, -e, -imos, -ís, -en
            """
        default:
            return topic.description
        }
    }

    private func getExamples(for topic: GrammarTopic) -> [String] {
        switch topic.title {
        case "Ser vs Estar":
            return [
                "Soy alto. (I am tall - permanent)",
                "Estoy cansado. (I am tired - temporary)",
                "Ella es médica. (She is a doctor - occupation)",
                "Estamos en Madrid. (We are in Madrid - location)",
                "El café está caliente. (The coffee is hot - current state)"
            ]
        case "Present Tense (Presente)":
            return [
                "Yo hablo español. (I speak Spanish)",
                "Tú comes pan. (You eat bread)",
                "Él vive en México. (He lives in Mexico)",
                "Nosotros estudiamos mucho. (We study a lot)"
            ]
        default:
            return [
                "Example 1: Coming soon",
                "Example 2: Coming soon"
            ]
        }
    }
}

struct ExampleRow: View {
    let example: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "quote.bubble.fill")
                .foregroundColor(.blue)
                .font(.caption)

            Text(example)
                .font(.body)
        }
        .padding(12)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(8)
    }
}

#Preview {
    GrammarReferenceView()
}
