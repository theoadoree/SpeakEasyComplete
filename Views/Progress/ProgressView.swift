//
//  ProgressView.swift
//  SpeakEasy
//
//  Created by Claude on 2025-11-01.
//

import SwiftUI
import Charts

struct ProgressView: View {
    @State private var selectedSection: ProgressSection = .overview
    @EnvironmentObject var appState: AppState
    @StateObject private var analyticsManager = AnalyticsManager()
    @StateObject private var multiLanguageService = MultiLanguageService.shared

    enum ProgressSection: String, CaseIterable {
        case overview = "Overview"
        case review = "Review"
        case vocabulary = "Vocabulary"
        case skills = "Skills"
        case achievements = "Achievements"
        case languages = "Languages"

        var icon: String {
            switch self {
            case .overview: return "chart.bar.fill"
            case .review: return "arrow.triangle.2.circlepath"
            case .vocabulary: return "book.fill"
            case .skills: return "star.fill"
            case .achievements: return "trophy.fill"
            case .languages: return "globe"
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Section Tabs
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(ProgressSection.allCases, id: \.self) { section in
                            ProgressTabButton(
                                title: section.rawValue,
                                icon: section.icon,
                                isSelected: selectedSection == section,
                                badge: section == .review ? appState.pendingReviewCount : nil,
                                action: {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedSection = section
                                    }
                                }
                            )
                        }
                    }
                    .padding()
                }
                .background(Color(.systemGroupedBackground))

                Divider()

                // Content
                ScrollView {
                    Group {
                        switch selectedSection {
                        case .overview:
                            OverviewDashboard()
                                .environmentObject(analyticsManager)
                        case .review:
                            ReviewSection()
                        case .vocabulary:
                            VocabularyProgressView()
                        case .skills:
                            SkillsBreakdownView()
                        case .achievements:
                            AchievementsView()
                        case .languages:
                            LanguageProgressSection()
                                .environmentObject(multiLanguageService)
                        }
                    }
                    .padding()
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
                }
            }
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            analyticsManager.loadData()
        }
    }
}

struct ProgressTabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let badge: Int?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: icon)
                        .font(.title3)

                    if let badge = badge, badge > 0 {
                        Text("\(min(badge, 99))")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(4)
                            .background(Circle().fill(Color.red))
                            .offset(x: 8, y: -8)
                    }
                }

                Text(title)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .frame(minWidth: 70)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue : Color(.secondarySystemBackground))
                    .shadow(color: isSelected ? Color.blue.opacity(0.3) : Color.clear, radius: 6, x: 0, y: 3)
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Language Progress Section

struct LanguageProgressSection: View {
    @EnvironmentObject var multiLanguageService: MultiLanguageService

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Current Language Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Current Language")
                    .font(.headline)
                    .foregroundColor(.secondary)

                HStack(spacing: 12) {
                    Text(multiLanguageService.currentLanguage.flag)
                        .font(.system(size: 40))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(multiLanguageService.currentLanguage.rawValue)
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("\(multiLanguageService.currentLanguage.languageFamily.contentReusePercentage)% content optimization")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.blue.opacity(0.1))
                )
            }

            // Available Languages
            VStack(alignment: .leading, spacing: 12) {
                Text("Available Languages")
                    .font(.headline)

                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(multiLanguageService.availableLanguages, id: \.self) { language in
                        LanguageProgressCard(language: language)
                    }
                }
            }

            // Coming Soon Languages
            let comingSoon = Language.allCases.filter { !multiLanguageService.availableLanguages.contains($0) }

            if !comingSoon.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Coming Soon")
                        .font(.headline)

                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(comingSoon, id: \.self) { language in
                            ComingSoonLanguageCard(language: language)
                        }
                    }
                }
            }

            // Language Family Benefits
            VStack(alignment: .leading, spacing: 12) {
                Text("Learning Strategy")
                    .font(.headline)

                LanguageFamilyBenefitsCard(currentLanguage: multiLanguageService.currentLanguage)
            }
        }
    }
}

struct LanguageProgressCard: View {
    let language: Language
    @State private var progress: Double = 0.0

    var body: some View {
        VStack(spacing: 12) {
            Text(language.flag)
                .font(.system(size: 40))

            Text(language.rawValue)
                .font(.headline)

            // Mock progress
            VStack(spacing: 4) {
                ProgressView(value: progress, total: 1.0)
                    .tint(.blue)

                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .onAppear {
            // Simulate progress
            progress = Double.random(in: 0.1...0.8)
        }
    }
}

struct ComingSoonLanguageCard: View {
    let language: Language

    var body: some View {
        VStack(spacing: 12) {
            Text(language.flag)
                .font(.system(size: 40))
                .opacity(0.5)

            Text(language.rawValue)
                .font(.headline)
                .foregroundColor(.secondary)

            Text(ContentScalingStrategy.estimatedTimeToLaunch(language: language))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

struct LanguageFamilyBenefitsCard: View {
    let currentLanguage: Language

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)

                Text("Smart Learning Path")
                    .font(.headline)
            }

            Text("Based on \(currentLanguage.rawValue), these languages will be easier to learn:")
                .font(.subheadline)
                .foregroundColor(.secondary)

            let relatedLanguages = getRelatedLanguages()

            ForEach(relatedLanguages, id: \.language) { item in
                HStack {
                    Text(item.language.flag)
                        .font(.title3)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.language.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Text("\(item.reusePercentage)% content reuse")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray6))
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.green.opacity(0.1))
        )
    }

    private func getRelatedLanguages() -> [(language: Language, reusePercentage: Int)] {
        Language.allCases
            .filter { $0 != currentLanguage }
            .map { language in
                (
                    language: language,
                    reusePercentage: ContentReuseMatrix.reusePercentage(
                        from: currentLanguage,
                        to: language
                    )
                )
            }
            .sorted { $0.reusePercentage > $1.reusePercentage }
            .prefix(3)
            .map { $0 }
    }
}

#Preview {
    ProgressView()
        .environmentObject(AppState())
}
