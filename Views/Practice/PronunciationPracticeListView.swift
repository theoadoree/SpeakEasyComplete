import SwiftUI

struct PronunciationPracticeListView: View {
    @State private var selectedCategory: String = "All"
    @State private var searchText = ""
    @State private var selectedPhrase: PracticePhrase?

    let categories = ["All", "Basics", "Travel", "Business", "Daily Life", "Advanced"]

    let practicePhrases: [PracticePhrase] = [
        // Basics
        PracticePhrase(
            id: UUID(),
            phrase: "Hello, how are you today?",
            difficulty: .beginner,
            category: "Basics",
            focusPoints: ["Intonation", "Natural flow"]
        ),
        PracticePhrase(
            id: UUID(),
            phrase: "Thank you very much for your help",
            difficulty: .beginner,
            category: "Basics",
            focusPoints: ["Stress patterns", "Gratitude tone"]
        ),

        // Travel
        PracticePhrase(
            id: UUID(),
            phrase: "Could you tell me where the nearest station is?",
            difficulty: .intermediate,
            category: "Travel",
            focusPoints: ["Polite requests", "Question intonation"]
        ),
        PracticePhrase(
            id: UUID(),
            phrase: "I'd like to book a room for two nights, please",
            difficulty: .intermediate,
            category: "Travel",
            focusPoints: ["Contractions", "Formal register"]
        ),

        // Business
        PracticePhrase(
            id: UUID(),
            phrase: "I'd like to schedule a meeting for next Tuesday",
            difficulty: .intermediate,
            category: "Business",
            focusPoints: ["Professional tone", "Clear articulation"]
        ),
        PracticePhrase(
            id: UUID(),
            phrase: "Let me clarify the key points of our proposal",
            difficulty: .advanced,
            category: "Business",
            focusPoints: ["Emphasis", "Presentation skills"]
        ),

        // Daily Life
        PracticePhrase(
            id: UUID(),
            phrase: "Would you like to grab coffee sometime?",
            difficulty: .elementary,
            category: "Daily Life",
            focusPoints: ["Casual tone", "Friendly invitation"]
        ),
        PracticePhrase(
            id: UUID(),
            phrase: "I'm running a bit late, I'll be there in 10 minutes",
            difficulty: .intermediate,
            category: "Daily Life",
            focusPoints: ["Connected speech", "Apologetic tone"]
        ),

        // Advanced
        PracticePhrase(
            id: UUID(),
            phrase: "The methodology we've implemented has yielded significant results",
            difficulty: .advanced,
            category: "Advanced",
            focusPoints: ["Complex vocabulary", "Academic register"]
        ),
        PracticePhrase(
            id: UUID(),
            phrase: "Nevertheless, we should consider alternative approaches",
            difficulty: .advanced,
            category: "Advanced",
            focusPoints: ["Transition words", "Persuasive tone"]
        )
    ]

    var filteredPhrases: [PracticePhrase] {
        practicePhrases.filter { phrase in
            (selectedCategory == "All" || phrase.category == selectedCategory) &&
            (searchText.isEmpty || phrase.phrase.localizedCaseInsensitiveContains(searchText))
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search and Filter
            VStack(spacing: 12) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)

                    TextField("Search phrases...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.1))
                )

                // Category filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(categories, id: \.self) { category in
                            CategoryPill(
                                title: category,
                                isSelected: selectedCategory == category,
                                action: { selectedCategory = category }
                            )
                        }
                    }
                }
            }
            .padding()
            .background(Color(hex: "F2F2F7"))

            // Phrases List
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filteredPhrases) { phrase in
                        PhraseCard(
                            phrase: phrase,
                            action: {
                                selectedPhrase = phrase
                            }
                        )
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Pronunciation Practice")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedPhrase) { phrase in
            NavigationView {
                VoiceComparisonView(
                    targetPhrase: phrase.phrase
                )
                .navigationTitle("Practice")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    trailing: Button("Done") {
                        selectedPhrase = nil
                    }
                )
            }
        }
    }
}

// MARK: - Category Pill
struct CategoryPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : Color(hex: "007AFF"))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color(hex: "007AFF") : Color.white)
                        .overlay(
                            Capsule()
                                .stroke(Color(hex: "007AFF"), lineWidth: isSelected ? 0 : 1)
                        )
                )
        }
    }
}

// MARK: - Phrase Card
struct PhraseCard: View {
    let phrase: PracticePhrase
    let action: () -> Void

    var difficultyColor: Color {
        switch phrase.difficulty {
        case .beginner: return Color(hex: "34C759")
        case .elementary: return Color(hex: "007AFF")
        case .intermediate: return Color(hex: "FF9500")
        case .advanced: return Color(hex: "FF3B30")
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Label(phrase.category, systemImage: categoryIcon(phrase.category))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)

                    Spacer()

                    // Difficulty badge
                    Text(phrase.difficulty.rawValue.capitalized)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(difficultyColor)
                        )
                }

                // Phrase
                Text(phrase.phrase)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                // Focus points
                HStack {
                    Image(systemName: "target")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "007AFF"))

                    Text(phrase.focusPoints.joined(separator: " • "))
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }

                // Practice button
                HStack {
                    Spacer()

                    HStack(spacing: 6) {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 14))
                        Text("Practice")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(Color(hex: "007AFF"))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
            )
        }
    }

    private func categoryIcon(_ category: String) -> String {
        switch category {
        case "Basics": return "abc"
        case "Travel": return "airplane"
        case "Business": return "briefcase.fill"
        case "Daily Life": return "house.fill"
        case "Advanced": return "graduationcap.fill"
        default: return "text.bubble.fill"
        }
    }
}

// MARK: - Practice Phrase Model
struct PracticePhrase: Identifiable {
    let id: UUID
    let phrase: String
    let difficulty: VocabularyCard.Difficulty
    let category: String
    let focusPoints: [String]
}

#Preview {
    NavigationView {
        PronunciationPracticeListView()
    }
}