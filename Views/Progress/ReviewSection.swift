//
//  ReviewSection.swift
//  SpeakEasy
//
//  Created by Claude on 2025-11-01.
//

import SwiftUI

struct ReviewSection: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var srsManager = SRSManager()
    @State private var showingReview = false
    @State private var selectedDeck: VocabularyDeck = .all

    enum VocabularyDeck: String, CaseIterable {
        case all = "All Words"
        case daily = "Daily Words"
        case fromSongs = "From Songs"
        case fromLessons = "From Lessons"
        case difficult = "Difficult"

        var icon: String {
            switch self {
            case .all: return "square.stack.3d.up.fill"
            case .daily: return "calendar"
            case .fromSongs: return "music.note"
            case .fromLessons: return "book.fill"
            case .difficult: return "exclamationmark.triangle.fill"
            }
        }

        var color: Color {
            switch self {
            case .all: return .blue
            case .daily: return .green
            case .fromSongs: return .purple
            case .fromLessons: return .orange
            case .difficult: return .red
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Review Queue Status
            ReviewQueueCard(
                dueNow: srsManager.dueNowCount,
                dueToday: srsManager.dueTodayCount,
                action: {
                    selectedDeck = .all
                    showingReview = true
                }
            )

            // Deck Selector
            VStack(alignment: .leading, spacing: 16) {
                Text("Vocabulary Decks")
                    .font(.title2)
                    .fontWeight(.bold)

                ForEach(VocabularyDeck.allCases, id: \.self) { deck in
                    DeckRow(
                        deck: deck,
                        count: srsManager.getCount(for: deck),
                        dueCount: srsManager.getDueCount(for: deck),
                        action: {
                            selectedDeck = deck
                            showingReview = true
                        }
                    )
                }
            }

            // Quick Stats
            VStack(alignment: .leading, spacing: 12) {
                Text("Learning Statistics")
                    .font(.title2)
                    .fontWeight(.bold)

                HStack(spacing: 12) {
                    QuickStat(
                        title: "Total Words",
                        value: "\(srsManager.totalWords)",
                        icon: "book.fill",
                        color: .blue
                    )

                    QuickStat(
                        title: "Mastered",
                        value: "\(srsManager.masteredWords)",
                        icon: "checkmark.seal.fill",
                        color: .green
                    )

                    QuickStat(
                        title: "Learning",
                        value: "\(srsManager.learningWords)",
                        icon: "arrow.triangle.2.circlepath",
                        color: .orange
                    )
                }
            }

            // Review Performance Chart
            ReviewPerformanceChart(data: srsManager.performanceData)
        }
        .fullScreenCover(isPresented: $showingReview) {
            SRSReviewSession(deck: selectedDeck)
                .environmentObject(srsManager)
        }
        .onAppear {
            srsManager.loadDecks()
        }
    }
}

struct ReviewQueueCard: View {
    let dueNow: Int
    let dueToday: Int
    let action: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Review Queue")
                        .font(.title2)
                        .fontWeight(.bold)

                    HStack(spacing: 20) {
                        VStack(alignment: .leading) {
                            Text("Due Now")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(dueNow)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                        }

                        VStack(alignment: .leading) {
                            Text("Due Today")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(dueToday)")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                        }
                    }
                }

                Spacer()

                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 50))
                    .foregroundColor(.blue.opacity(0.3))
            }

            if dueNow > 0 {
                Button(action: action) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Start Review (\(dueNow) cards)")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct DeckRow: View {
    let deck: ReviewSection.VocabularyDeck
    let count: Int
    let dueCount: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: deck.icon)
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(deck.color)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(deck.rawValue)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text("\(count) words")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if dueCount > 0 {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(dueCount)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(deck.color)

                        Text("due")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct QuickStat: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
    }
}

struct ReviewPerformanceChart: View {
    let data: [ReviewPerformanceData]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Review Performance (Last 7 Days)")
                .font(.headline)

            if #available(iOS 16.0, *) {
                Chart(data) { item in
                    BarMark(
                        x: .value("Day", item.day),
                        y: .value("Reviews", item.correctReviews)
                    )
                    .foregroundStyle(.green)

                    BarMark(
                        x: .value("Day", item.day),
                        y: .value("Reviews", item.incorrectReviews)
                    )
                    .foregroundStyle(.red)
                }
                .frame(height: 150)
                .chartLegend(.visible)
            } else {
                Text("Chart requires iOS 16+")
                    .foregroundColor(.secondary)
                    .frame(height: 150)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct SRSReviewSession: View {
    let deck: ReviewSection.VocabularyDeck
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var srsManager: SRSManager
    @State private var currentCardIndex = 0
    @State private var showingAnswer = false
    @State private var reviewComplete = false

    var body: some View {
        NavigationView {
            VStack {
                if reviewComplete {
                    ReviewCompleteView(
                        reviewedCount: srsManager.todayReviewedCount,
                        correctCount: srsManager.todayCorrectCount,
                        dismiss: { dismiss() }
                    )
                } else if let card = srsManager.getCurrentCard() {
                    ReviewCardView(
                        card: card,
                        showingAnswer: $showingAnswer,
                        onResponse: { quality in
                            srsManager.submitResponse(quality)
                            if srsManager.hasMoreCards() {
                                currentCardIndex += 1
                                showingAnswer = false
                            } else {
                                reviewComplete = true
                            }
                        }
                    )
                } else {
                    Text("No cards to review")
                }
            }
            .navigationTitle("Review Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ReviewCardView: View {
    let card: VocabularyCard
    @Binding var showingAnswer: Bool
    let onResponse: (Int) -> Void

    var body: some View {
        VStack(spacing: 30) {
            // Progress
            Text("Card \(card.cardNumber) of \(card.totalCards)")
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()

            // Question
            VStack(spacing: 16) {
                Text(card.front)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                if showingAnswer {
                    Divider()

                    Text(card.back)
                        .font(.title2)
                        .foregroundColor(.blue)
                        .multilineTextAlignment(.center)

                    if let context = card.exampleSentence {
                        Text(context)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .italic()
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)

            Spacer()

            // Actions
            if !showingAnswer {
                Button(action: { showingAnswer = true }) {
                    Text("Show Answer")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            } else {
                VStack(spacing: 12) {
                    Text("How well did you know this?")
                        .font(.headline)

                    HStack(spacing: 12) {
                        ResponseButton(title: "Again", color: .red, quality: 1, action: onResponse)
                        ResponseButton(title: "Hard", color: .orange, quality: 3, action: onResponse)
                        ResponseButton(title: "Good", color: .blue, quality: 4, action: onResponse)
                        ResponseButton(title: "Easy", color: .green, quality: 5, action: onResponse)
                    }
                }
            }
        }
        .padding()
    }
}

struct ResponseButton: View {
    let title: String
    let color: Color
    let quality: Int
    let action: (Int) -> Void

    var body: some View {
        Button(action: { action(quality) }) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}

struct ReviewCompleteView: View {
    let reviewedCount: Int
    let correctCount: Int
    let dismiss: () -> Void

    var accuracy: Int {
        guard reviewedCount > 0 else { return 0 }
        return (correctCount * 100) / reviewedCount
    }

    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)

            VStack(spacing: 12) {
                Text("Review Complete!")
                    .font(.title)
                    .fontWeight(.bold)

                Text("You reviewed \(reviewedCount) cards")
                    .font(.headline)
                    .foregroundColor(.secondary)

                Text("\(accuracy)% accuracy")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }

            Button(action: dismiss) {
                Text("Done")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    ReviewSection()
        .environmentObject(AppState())
}
