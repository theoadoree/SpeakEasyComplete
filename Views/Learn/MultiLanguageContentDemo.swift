import SwiftUI

/// Demo view showing multi-language content generation
struct MultiLanguageContentDemo: View {
    @StateObject private var multiLanguageService = MultiLanguageService.shared
    @State private var selectedLanguage: Language = .spanish
    @State private var selectedLevel: CEFRLevel = .a1
    @State private var selectedContentType: ContentGenerationType = .conversation
    @State private var generatedContent: GeneratedContent?
    @State private var isGenerating = false
    @State private var showCostEstimate = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Selection Controls
                VStack(alignment: .leading, spacing: 16) {
                    Text("Content Generator")
                        .font(.title)
                        .fontWeight(.bold)

                    // Language Selector
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Language")
                            .font(.headline)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Language.allCases.prefix(5), id: \.self) { language in
                                    LanguageButton(
                                        language: language,
                                        isSelected: selectedLanguage == language
                                    ) {
                                        selectedLanguage = language
                                    }
                                }
                            }
                        }
                    }

                    // Level Selector
                    VStack(alignment: .leading, spacing: 8) {
                        Text("CEFR Level")
                            .font(.headline)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(CEFRLevel.allCases, id: \.self) { level in
                                    LevelButton(
                                        level: level,
                                        isSelected: selectedLevel == level
                                    ) {
                                        selectedLevel = level
                                    }
                                }
                            }
                        }
                    }

                    // Content Type Selector
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Content Type")
                            .font(.headline)

                        VStack(spacing: 8) {
                            ContentTypeButton(
                                type: .conversation,
                                icon: "bubble.left.and.bubble.right",
                                isSelected: selectedContentType == .conversation
                            ) {
                                selectedContentType = .conversation
                            }

                            ContentTypeButton(
                                type: .grammarLesson,
                                icon: "book",
                                isSelected: selectedContentType == .grammarLesson
                            ) {
                                selectedContentType = .grammarLesson
                            }

                            ContentTypeButton(
                                type: .pronunciationExercise,
                                icon: "waveform",
                                isSelected: selectedContentType == .pronunciationExercise
                            ) {
                                selectedContentType = .pronunciationExercise
                            }

                            ContentTypeButton(
                                type: .culturalLesson,
                                icon: "globe",
                                isSelected: selectedContentType == .culturalLesson
                            ) {
                                selectedContentType = .culturalLesson
                            }

                            ContentTypeButton(
                                type: .story,
                                icon: "text.book.closed",
                                isSelected: selectedContentType == .story
                            ) {
                                selectedContentType = .story
                            }

                            ContentTypeButton(
                                type: .vocabulary,
                                icon: "text.badge.checkmark",
                                isSelected: selectedContentType == .vocabulary
                            ) {
                                selectedContentType = .vocabulary
                            }
                        }
                    }

                    // Generate Button
                    Button(action: generateContent) {
                        HStack {
                            if isGenerating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "sparkles")
                            }

                            Text(isGenerating ? "Generating..." : "Generate Content")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(isGenerating)
                }
                .padding()

                // Language-Specific Features
                LanguageFeaturesPreview(language: selectedLanguage, level: selectedLevel)

                // Generated Content Display
                if let content = generatedContent {
                    GeneratedContentCard(content: content)
                }

                // Cost Estimate
                CostEstimateSection()
            }
        }
        .navigationTitle("Multi-Language Demo")
    }

    private func generateContent() {
        isGenerating = true

        Task {
            do {
                let content = await multiLanguageService.generateContent(
                    language: selectedLanguage,
                    type: selectedContentType,
                    level: selectedLevel,
                    useCache: true
                )
                await MainActor.run {
                    generatedContent = content
                    isGenerating = false
                }
            } catch {
                await MainActor.run {
                    isGenerating = false
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct LanguageButton: View {
    let language: Language
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(language.flag)
                    .font(.title2)

                Text(language.rawValue)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue : Color(.systemGray6))
            )
        }
    }
}

struct LevelButton: View {
    let level: CEFRLevel
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(level.rawValue)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .primary)

                Text(level.description)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue : Color(.systemGray6))
            )
        }
    }
}

struct ContentTypeButton: View {
    let type: ContentGenerationType
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? .white : .blue)

                Text(typeName)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .primary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue : Color(.systemGray6))
            )
        }
    }

    private var typeName: String {
        switch type {
        case .conversation: return "Conversation"
        case .grammarLesson: return "Grammar Lesson"
        case .pronunciationExercise: return "Pronunciation"
        case .culturalLesson: return "Cultural Lesson"
        case .story: return "Story Reading"
        case .vocabulary: return "Vocabulary"
        }
    }
}

struct LanguageFeaturesPreview: View {
    let language: Language
    let level: CEFRLevel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(language.rawValue) - \(level.rawValue) Focus")
                .font(.headline)

            let grammarRules = MultiLanguageService.shared.getGrammarRules(for: language, level: level)

            if !grammarRules.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Grammar for this level:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    ForEach(grammarRules.prefix(3), id: \.self) { rule in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)

                            Text(rule)
                                .font(.subheadline)
                        }
                    }
                }
            }

            let scenarios = MultiLanguageService.shared.getCulturalScenarios(for: language, level: level)

            if !scenarios.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Cultural scenarios:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    ForEach(scenarios.prefix(2)) { scenario in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "globe")
                                .font(.caption)
                                .foregroundColor(.blue)

                            Text(scenario.title)
                                .font(.subheadline)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct GeneratedContentCard: View {
    let content: GeneratedContent

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.yellow)

                Text("Generated Content")
                    .font(.headline)

                Spacer()

                Text(content.level.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(4)
            }

            Text(content.title)
                .font(.title3)
                .fontWeight(.semibold)

            Text(content.content)
                .font(.body)
                .foregroundColor(.secondary)

            if !content.metadata.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Details:")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    ForEach(Array(content.metadata.keys.sorted()), id: \.self) { key in
                        if let value = content.metadata[key] {
                            HStack {
                                Text(key.replacingOccurrences(of: "_", with: " ").capitalized)
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                Text(value)
                                    .font(.caption)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
            }

            HStack {
                Image(systemName: "clock")
                    .font(.caption)

                Text(content.createdAt, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)

                Text("Cached")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
        )
        .padding(.horizontal)
    }
}

struct CostEstimateSection: View {
    @State private var activeUsers = 1000
    @State private var avgTimePerMonth: Double = 5.0 // hours

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Cost Estimation")
                .font(.title2)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Active Users:")
                        .font(.subheadline)

                    Spacer()

                    Text("\(activeUsers)")
                        .font(.headline)
                }

                Slider(value: Binding(
                    get: { Double(activeUsers) },
                    set: { activeUsers = Int($0) }
                ), in: 100...10000, step: 100)

                HStack {
                    Text("Avg. Hours/Month:")
                        .font(.subheadline)

                    Spacer()

                    Text(String(format: "%.1f hrs", avgTimePerMonth))
                        .font(.headline)
                }

                Slider(value: $avgTimePerMonth, in: 1...20, step: 0.5)

                Divider()

                let costPerUser = ContentCostOptimization.estimateCostPerUser(
                    language: .spanish,
                    monthlyActiveTime: avgTimePerMonth * 3600
                )
                let monthlyBudget = ContentCostOptimization.estimateMonthlyBudget(
                    activeUsers: activeUsers,
                    avgTimePerUser: avgTimePerMonth * 3600
                )

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Cost per User/Month:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Spacer()

                        Text(String(format: "$%.2f", costPerUser))
                            .font(.headline)
                            .foregroundColor(.green)
                    }

                    HStack {
                        Text("Total Monthly Budget:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Spacer()

                        Text(String(format: "$%.2f", monthlyBudget))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                }

                Text("* Includes 70% cache efficiency")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .padding()
    }
}

// MARK: - Preview

struct MultiLanguageContentDemo_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MultiLanguageContentDemo()
        }
    }
}
