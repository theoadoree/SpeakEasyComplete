import SwiftUI

/// Demonstration view showing language-specific content generation
struct LanguageContentDemoView: View {
    @StateObject private var multiLanguageService = MultiLanguageService.shared
    @State private var selectedLanguage: Language = .spanish
    @State private var selectedLevel: CEFRLevel = .a1
    @State private var selectedContentType: ContentGenerationType = .conversation
    @State private var generatedContent: GeneratedContent?
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection

                    // Language Selection
                    languageSelector

                    // Level Selection
                    levelSelector

                    // Content Type Selection
                    contentTypeSelector

                    // Language Features Display
                    languageFeaturesCard

                    // Generate Button
                    generateButton

                    // Generated Content Display
                    if let content = generatedContent {
                        generatedContentCard(content)
                    }

                    // Cost & Reuse Info
                    costInfoCard

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Language Content Demo")
        }
    }

    // MARK: - View Components

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Multi-Language Content System")
                .font(.title)
                .fontWeight(.bold)

            Text("Demonstrating language-specific content generation with smart reuse")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }

    private var languageSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Language")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(multiLanguageService.availableLanguages, id: \.self) { language in
                        LanguageCard(
                            language: language,
                            isSelected: selectedLanguage == language
                        ) {
                            selectedLanguage = language
                            multiLanguageService.switchLanguage(to: language)
                        }
                    }
                }
            }
        }
    }

    private var levelSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CEFR Level")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(CEFRLevel.allCases, id: \.self) { level in
                        Button {
                            selectedLevel = level
                        } label: {
                            VStack(spacing: 4) {
                                Text(level.rawValue)
                                    .font(.system(.body, design: .monospaced))
                                    .fontWeight(.bold)
                                Text(level.description)
                                    .font(.caption)
                            }
                            .frame(width: 100, height: 60)
                            .background(
                                selectedLevel == level ?
                                Color.blue : Color.gray.opacity(0.2)
                            )
                            .foregroundColor(
                                selectedLevel == level ? .white : .primary
                            )
                            .cornerRadius(8)
                        }
                    }
                }
            }
        }
    }

    private var contentTypeSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Content Type")
                .font(.headline)

            let contentTypes: [ContentGenerationType] = [
                .conversation, .grammarLesson, .pronunciationExercise,
                .culturalLesson, .story, .vocabulary
            ]

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(contentTypes, id: \.self) { type in
                    ContentTypeButton(
                        type: type,
                        isSelected: selectedContentType == type
                    ) {
                        selectedContentType = type
                    }
                }
            }
        }
    }

    private var languageFeaturesCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\(selectedLanguage.rawValue) Features")
                .font(.headline)

            let features = multiLanguageService.getFeatures(for: selectedLanguage)

            FeatureSection(title: "Grammar Focus", items: Array(features.grammar.prefix(3)))
            FeatureSection(title: "Pronunciation", items: Array(features.pronunciation.prefix(3)))
            FeatureSection(title: "Cultural Context", items: Array(features.culture.prefix(3)))
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(12)
    }

    private var generateButton: some View {
        Button {
            Task {
                await generateContent()
            }
        } label: {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "sparkles")
                    Text("Generate \(contentTypeName(selectedContentType))")
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(isLoading)
    }

    private func generatedContentCard(_ content: GeneratedContent) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .foregroundColor(.blue)
                Text(content.title)
                    .font(.headline)
                Spacer()
                Text(content.level.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(4)
            }

            Divider()

            Text(content.content)
                .font(.body)
                .foregroundColor(.primary)

            if !content.metadata.isEmpty {
                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Metadata")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    ForEach(Array(content.metadata.keys), id: \.self) { key in
                        HStack {
                            Text(key.capitalized)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(content.metadata[key] ?? "")
                                .font(.caption)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
    }

    private var costInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Content Strategy Info")
                .font(.headline)

            // Content reuse if switching from Spanish
            if selectedLanguage != .spanish {
                let reusePercentage = multiLanguageService.calculateReusePercentage(
                    from: .spanish,
                    to: selectedLanguage
                )

                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .foregroundColor(.green)
                    Text("Content Reuse from Spanish:")
                    Spacer()
                    Text("\(Int(reusePercentage * 100))%")
                        .fontWeight(.bold)
                }
            }

            // Estimated cost
            let cost = ContentScalingStrategy.estimatedCost(language: selectedLanguage)
            HStack {
                Image(systemName: "dollarsign.circle")
                    .foregroundColor(.blue)
                Text("Setup Cost:")
                Spacer()
                Text(cost)
                    .fontWeight(.bold)
            }

            // Launch timeline
            let timeline = ContentScalingStrategy.estimatedTimeToLaunch(language: selectedLanguage)
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.purple)
                Text("Timeline:")
                Spacer()
                Text(timeline)
                    .fontWeight(.bold)
            }
        }
        .padding()
        .background(Color.purple.opacity(0.1))
        .cornerRadius(12)
    }

    // MARK: - Helper Methods

    private func generateContent() async {
        isLoading = true
        generatedContent = nil

        // Simulate content generation
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        let content = await multiLanguageService.generateContent(
            language: selectedLanguage,
            type: selectedContentType,
            level: selectedLevel
        )

        generatedContent = content
        isLoading = false
    }

    private func contentTypeName(_ type: ContentGenerationType) -> String {
        switch type {
        case .conversation: return "Conversation"
        case .grammarLesson: return "Grammar Lesson"
        case .pronunciationExercise: return "Pronunciation"
        case .culturalLesson: return "Cultural Lesson"
        case .story: return "Story"
        case .vocabulary: return "Vocabulary"
        }
    }
}

// MARK: - Supporting Views

struct LanguageCard: View {
    let language: Language
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(language.flag)
                    .font(.system(size: 40))

                Text(language.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(width: 100, height: 100)
            .background(isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ContentTypeButton: View {
    let type: ContentGenerationType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: iconForType(type))
                Text(nameForType(type))
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(8)
        }
    }

    private func iconForType(_ type: ContentGenerationType) -> String {
        switch type {
        case .conversation: return "bubble.left.and.bubble.right"
        case .grammarLesson: return "book"
        case .pronunciationExercise: return "waveform"
        case .culturalLesson: return "globe"
        case .story: return "text.book.closed"
        case .vocabulary: return "list.bullet"
        }
    }

    private func nameForType(_ type: ContentGenerationType) -> String {
        switch type {
        case .conversation: return "Conversation"
        case .grammarLesson: return "Grammar"
        case .pronunciationExercise: return "Pronunciation"
        case .culturalLesson: return "Culture"
        case .story: return "Story"
        case .vocabulary: return "Vocabulary"
        }
    }
}

struct FeatureSection: View {
    let title: String
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)

            ForEach(items, id: \.self) { item in
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                    Text(item)
                        .font(.caption)
                }
            }
        }
    }
}

// MARK: - Preview
struct LanguageContentDemoView_Previews: PreviewProvider {
    static var previews: some View {
        LanguageContentDemoView()
    }
}
