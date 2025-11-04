//
//  VocabularyProgressView.swift
//  SpeakEasy
//
//  Created by Claude on 2025-11-01.
//

import SwiftUI
import Charts

struct VocabularyProgressView: View {
    @StateObject private var vocabManager = VocabularyManager()
    @State private var selectedCategory: VocabCategory = .all

    enum VocabCategory: String, CaseIterable {
        case all = "All Words"
        case learned = "Learned"
        case learning = "Learning"
        case new = "New"

        var icon: String {
            switch self {
            case .all: return "square.stack.3d.up.fill"
            case .learned: return "checkmark.seal.fill"
            case .learning: return "arrow.triangle.2.circlepath"
            case .new: return "sparkles"
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Overall Stats
            VocabularyStatsOverview(stats: vocabManager.overallStats)

            // Category Selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(VocabCategory.allCases, id: \.self) { category in
                        CategoryButton(
                            category: category,
                            isSelected: selectedCategory == category,
                            count: vocabManager.getCount(for: category),
                            action: { selectedCategory = category }
                        )
                    }
                }
            }

            // Word List
            VocabularyWordList(
                words: vocabManager.getWords(for: selectedCategory),
                category: selectedCategory
            )

            // Learning Rate Chart
            LearningRateChart(data: vocabManager.learningRateData)

            // Category Distribution
            CategoryDistributionView(distribution: vocabManager.categoryDistribution)
        }
        .onAppear {
            vocabManager.loadVocabulary()
        }
    }
}

struct VocabularyStatsOverview: View {
    let stats: VocabularyStats

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Vocabulary Overview")
                .font(.title2)
                .fontWeight(.bold)

            HStack(spacing: 12) {
                // Total words with circular progress
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                        .frame(width: 100, height: 100)

                    Circle()
                        .trim(from: 0, to: CGFloat(stats.masteryPercentage) / 100)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 100, height: 100)
                        .rotationEffect(Angle(degrees: -90))

                    VStack(spacing: 4) {
                        Text("\(stats.totalWords)")
                            .font(.title)
                            .fontWeight(.bold)

                        Text("words")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                // Breakdown
                VStack(alignment: .leading, spacing: 12) {
                    StatRow(
                        label: "Mastered",
                        value: "\(stats.masteredWords)",
                        percentage: stats.masteredPercentage,
                        color: .green
                    )

                    StatRow(
                        label: "Learning",
                        value: "\(stats.learningWords)",
                        percentage: stats.learningPercentage,
                        color: .orange
                    )

                    StatRow(
                        label: "New",
                        value: "\(stats.newWords)",
                        percentage: stats.newPercentage,
                        color: .blue
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct StatRow: View {
    let label: String
    let value: String
    let percentage: Int
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .leading)

            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)

            Text("(\(percentage)%)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct CategoryButton: View {
    let category: VocabularyProgressView.VocabCategory
    let isSelected: Bool
    let count: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.title3)

                Text(category.rawValue)
                    .font(.caption)

                Text("\(count)")
                    .font(.caption)
                    .fontWeight(.bold)
            }
            .frame(width: 90, height: 80)
            .background(isSelected ? Color.blue : Color(.secondarySystemBackground))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(12)
        }
    }
}

struct VocabularyWordList: View {
    let words: [VocabularyWord]
    let category: VocabularyProgressView.VocabCategory

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Words (\(words.count))")
                .font(.headline)

            if words.isEmpty {
                Text("No words in this category")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(words.prefix(20)) { word in
                        VocabularyWordRow(word: word)
                    }

                    if words.count > 20 {
                        NavigationLink(destination: FullVocabularyList(words: words, category: category)) {
                            Text("View all \(words.count) words →")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                                .padding()
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct VocabularyWordRow: View {
    let word: VocabularyWord

    var body: some View {
        HStack(spacing: 12) {
            // Status indicator
            Circle()
                .fill(word.statusColor)
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 4) {
                Text(word.spanish)
                    .font(.headline)

                Text(word.english)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Mastery level
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(word.masteryLevel)%")
                    .font(.caption)
                    .fontWeight(.semibold)

                ProgressView(value: Double(word.masteryLevel) / 100)
                    .frame(width: 50)
            }

            // Source tag
            Text(word.sourceIcon)
                .font(.caption)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(4)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct LearningRateChart: View {
    let data: [LearningRateData]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Learning Rate (Last 30 Days)")
                .font(.headline)

            if #available(iOS 16.0, *) {
                Chart(data) { item in
                    BarMark(
                        x: .value("Week", item.weekLabel),
                        y: .value("Words", item.wordsLearned)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .purple]),
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .cornerRadius(4)
                }
                .frame(height: 150)
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                    }
                }
            } else {
                Text("Chart requires iOS 16+")
                    .foregroundColor(.secondary)
                    .frame(height: 150)
            }

            Text("Average: \(data.map { $0.wordsLearned }.reduce(0, +) / max(data.count, 1)) words/week")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct CategoryDistributionView: View {
    let distribution: [CategoryDistribution]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Words by Topic")
                .font(.headline)

            ForEach(distribution) { category in
                HStack {
                    Text(category.name)
                        .font(.subheadline)
                        .frame(width: 100, alignment: .leading)

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 20)

                            Rectangle()
                                .fill(category.color)
                                .frame(width: geometry.size.width * CGFloat(category.percentage) / 100, height: 20)
                        }
                        .cornerRadius(4)
                    }
                    .frame(height: 20)

                    Text("\(category.count)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(width: 40, alignment: .trailing)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct FullVocabularyList: View {
    let words: [VocabularyWord]
    let category: VocabularyProgressView.VocabCategory

    var body: some View {
        List(words) { word in
            VocabularyWordRow(word: word)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
        }
        .listStyle(PlainListStyle())
        .navigationTitle(category.rawValue)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    VocabularyProgressView()
}
