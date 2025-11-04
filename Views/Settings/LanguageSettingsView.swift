import SwiftUI

/// Settings view for managing language selection and preferences
struct LanguageSettingsView: View {
    @StateObject private var multiLanguageService = MultiLanguageService.shared
    @State private var selectedLanguage: Language = .spanish
    @State private var showLanguageDetails = false
    @State private var generatingContent = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Language Selection")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Choose your target language")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)

                // Language Grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(Language.allCases, id: \.self) { language in
                        LanguageCard(
                            language: language,
                            isSelected: selectedLanguage == language,
                            isAvailable: multiLanguageService.availableLanguages.contains(language)
                        )
                        .onTapGesture {
                            selectedLanguage = language
                            multiLanguageService.switchLanguage(to: language)
                        }
                    }
                }
                .padding(.horizontal)

                // Selected Language Details
                if showLanguageDetails {
                    LanguageDetailsSection(language: selectedLanguage)
                        .transition(.opacity)
                }

                // Content Reuse Information
                ContentReuseSection(selectedLanguage: selectedLanguage)

                // Scaling Timeline
                ScalingTimelineSection()
            }
            .padding(.vertical)
        }
        .navigationTitle("Languages")
    }
}

// MARK: - Language Card

struct LanguageCard: View {
    let language: Language
    let isSelected: Bool
    let isAvailable: Bool

    var body: some View {
        VStack(spacing: 12) {
            Text(language.flag)
                .font(.system(size: 48))

            Text(language.rawValue)
                .font(.headline)
                .foregroundColor(isSelected ? .white : .primary)

            if !isAvailable {
                Text("Coming Soon")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isSelected ? Color.blue : Color(.systemGray6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
        .opacity(isAvailable ? 1.0 : 0.5)
    }
}

// MARK: - Language Details Section

struct LanguageDetailsSection: View {
    let language: Language
    @State private var features: LanguageFeatures?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\(language.rawValue) Features")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)

            if let features = features {
                VStack(spacing: 12) {
                    FeatureSection(title: "Grammar Focus", items: features.grammar)
                    FeatureSection(title: "Pronunciation", items: features.pronunciation)
                    FeatureSection(title: "Cultural Context", items: features.culture)

                    if let writing = features.writing {
                        FeatureSection(title: "Writing System", items: writing)
                    }

                    FeatureSection(title: "Key Challenges", items: features.uniqueChallenges)
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal)
        .onAppear {
            features = LanguageFeaturesFactory.features(for: language)
        }
    }
}

struct FeatureSection: View {
    let title: String
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)

            VStack(alignment: .leading, spacing: 4) {
                ForEach(items.prefix(3), id: \.self) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .foregroundColor(.blue)
                        Text(item)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                if items.count > 3 {
                    Text("+\(items.count - 3) more")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.leading, 16)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Content Reuse Section

struct ContentReuseSection: View {
    let selectedLanguage: Language

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Content Strategy")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)

            VStack(spacing: 12) {
                ContentTypeRow(
                    title: "Universal Content",
                    percentage: 20,
                    items: ContentReuseMatrix.sharedContent,
                    color: .green
                )

                ContentTypeRow(
                    title: "Template-Based",
                    percentage: 50,
                    items: ContentReuseMatrix.adaptableContent,
                    color: .orange
                )

                ContentTypeRow(
                    title: "Language-Specific",
                    percentage: 30,
                    items: ContentReuseMatrix.uniqueContent,
                    color: .red
                )
            }
            .padding(.horizontal)

            // Reuse from Spanish
            if selectedLanguage != .spanish {
                let reusePercentage = ContentReuseMatrix.reusePercentage(from: .spanish, to: selectedLanguage)
                ReuseBanner(
                    fromLanguage: .spanish,
                    toLanguage: selectedLanguage,
                    percentage: reusePercentage
                )
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
}

struct ContentTypeRow: View {
    let title: String
    let percentage: Int
    let items: [String]
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)

                Spacer()

                Text("\(percentage)%")
                    .font(.headline)
                    .foregroundColor(color)
            }

            ProgressView(value: Double(percentage), total: 100)
                .tint(color)

            Text(items.joined(separator: ", "))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ReuseBanner: View {
    let fromLanguage: Language
    let toLanguage: Language
    let percentage: Int

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.title2)
                .foregroundColor(.blue)

            VStack(alignment: .leading, spacing: 4) {
                Text("Content Reuse from \(fromLanguage.rawValue)")
                    .font(.headline)

                Text("\(percentage)% of content can be adapted")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Scaling Timeline Section

struct ScalingTimelineSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Launch Timeline")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)

            VStack(spacing: 12) {
                ForEach(ContentScalingStrategy.phases.indices, id: \.self) { index in
                    let phase = ContentScalingStrategy.phases[index]
                    PhaseCard(phase: phase, phaseNumber: index + 1)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
}

struct PhaseCard: View {
    let phase: ContentScalingStrategy.Phase
    let phaseNumber: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Phase \(phaseNumber)")
                    .font(.headline)
                    .foregroundColor(.blue)

                Spacer()

                Text(phase.weeks)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Text(phase.name)
                .font(.title3)
                .fontWeight(.semibold)

            HStack(spacing: 8) {
                ForEach(phase.languages, id: \.self) { language in
                    Text(language.flag)
                        .font(.title3)
                }
            }

            Text(phase.focus)
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack {
                Image(systemName: "dollarsign.circle")
                    .foregroundColor(.green)

                Text(phase.estimatedCost)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Preview

struct LanguageSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LanguageSettingsView()
        }
    }
}
