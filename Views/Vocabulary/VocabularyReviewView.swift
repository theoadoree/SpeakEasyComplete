import SwiftUI

struct VocabularyReviewView: View {
    @EnvironmentObject var spacedRepetition: SpacedRepetitionService
    @State private var currentCard: VocabularyCard?
    @State private var showAnswer = false
    @State private var cardRotation = 0.0
    @State private var offset: CGSize = .zero
    @State private var reviewQuality: ReviewQuality?
    @State private var sessionStats = SessionStats()

    var body: some View {
        VStack(spacing: 20) {
            // Header with stats
            ReviewHeaderView(
                dueCount: spacedRepetition.dueCards.count,
                stats: sessionStats
            )
            .padding(.horizontal)

            if let card = currentCard {
                // Flashcard
                FlashcardView(
                    card: card,
                    showAnswer: $showAnswer,
                    rotation: cardRotation,
                    offset: offset
                )
                .gesture(dragGesture)
                .onTapGesture {
                    withAnimation(.spring()) {
                        showAnswer.toggle()
                        cardRotation += 180
                    }
                }

                // Quality buttons (show after revealing answer)
                if showAnswer {
                    QualityButtonsView(onQualitySelected: handleQualitySelection)
                        .transition(.scale.combined(with: .opacity))
                        .padding(.horizontal)
                }
            } else {
                // No cards due
                NoCardsView(
                    onAddCards: generateNewCards,
                    onReviewAll: reviewAllCards
                )
            }

            Spacer()
        }
        .background(Color(.systemGray6))
        .onAppear {
            loadNextCard()
        }
    }

    // MARK: - Gesture
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = value.translation
            }
            .onEnded { value in
                if abs(value.translation.width) > 150 {
                    // Swiped far enough
                    if value.translation.width > 0 {
                        // Swiped right - mark as easy
                        handleQualitySelection(.perfect)
                    } else {
                        // Swiped left - mark as hard
                        handleQualitySelection(.correctWithDifficulty)
                    }
                } else {
                    // Return to center
                    withAnimation(.spring()) {
                        offset = .zero
                    }
                }
            }
    }

    // MARK: - Actions
    private func loadNextCard() {
        if let nextCard = spacedRepetition.dueCards.first {
            currentCard = nextCard
            showAnswer = false
            cardRotation = 0
            offset = .zero
        } else {
            currentCard = nil
        }
    }

    private func handleQualitySelection(_ quality: ReviewQuality) {
        guard let card = currentCard else { return }

        // Update statistics
        sessionStats.cardsReviewed += 1
        if quality == .perfect || quality == .good {
            sessionStats.correct += 1
        }

        // Process review
        let _ = spacedRepetition.reviewCard(card, quality: quality)

        // Animate card off screen
        withAnimation(.easeOut(duration: 0.3)) {
            if quality == .perfect || quality == .good {
                offset = CGSize(width: 500, height: 0)
            } else {
                offset = CGSize(width: -500, height: 0)
            }
        }

        // Load next card
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            loadNextCard()
        }
    }

    private func generateNewCards() {
        // Generate adaptive cards based on weak areas
        let weakAreas = spacedRepetition.getStatistics().weakestTopics
        let newCards = spacedRepetition.generateAdaptiveCards(for: weakAreas)
        newCards.forEach { spacedRepetition.addVocabularyCard($0) }
        loadNextCard()
    }

    private func reviewAllCards() {
        // Reset all cards for review
        spacedRepetition.updateDueCards()
        loadNextCard()
    }
}

// MARK: - Review Header
struct ReviewHeaderView: View {
    let dueCount: Int
    let stats: SessionStats

    var accuracy: Int {
        stats.cardsReviewed > 0 ? Int((Double(stats.correct) / Double(stats.cardsReviewed)) * 100) : 0
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Due Today")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                Text("\(dueCount) cards")
                    .font(.system(size: 24, weight: .bold))
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text("Session")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                HStack(spacing: 4) {
                    Text("\(stats.cardsReviewed)")
                        .font(.system(size: 18, weight: .semibold))
                    Text("(\(accuracy)%)")
                        .font(.system(size: 14))
                        .foregroundColor(accuracyColor(accuracy))
                }
            }
        }
    }

    private func accuracyColor(_ accuracy: Int) -> Color {
        if accuracy >= 90 { return .green }
        else if accuracy >= 75 { return .orange }
        else { return .red }
    }
}

// MARK: - Flashcard View
struct FlashcardView: View {
    let card: VocabularyCard
    @Binding var showAnswer: Bool
    let rotation: Double
    let offset: CGSize

    var body: some View {
        ZStack {
            // Back of card (answer)
            CardSide(
                isAnswer: true,
                word: card.translation,
                pronunciation: card.pronunciation,
                example: card.exampleSentence,
                difficulty: card.difficulty
            )
            .rotation3DEffect(
                Angle(degrees: rotation + 180),
                axis: (x: 0, y: 1, z: 0)
            )
            .opacity(showAnswer ? 1 : 0)

            // Front of card (question)
            CardSide(
                isAnswer: false,
                word: card.word,
                pronunciation: nil,
                example: nil,
                difficulty: card.difficulty
            )
            .rotation3DEffect(
                Angle(degrees: rotation),
                axis: (x: 0, y: 1, z: 0)
            )
            .opacity(showAnswer ? 0 : 1)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 400)
        .offset(offset)
    }
}

// MARK: - Card Side
struct CardSide: View {
    let isAnswer: Bool
    let word: String
    let pronunciation: String?
    let example: String?
    let difficulty: VocabularyCard.Difficulty

    var body: some View {
        VStack(spacing: 20) {
            // Category indicator
            HStack {
                Circle()
                    .fill(difficulty.color)
                    .frame(width: 12, height: 12)

                Text(difficulty.rawValue.capitalized)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)

                Spacer()

                if !isAnswer {
                    Image(systemName: "arrow.right.circle")
                        .foregroundColor(.gray)
                        .font(.system(size: 16))
                }
            }
            .padding(.horizontal)

            Spacer()

            // Main word
            Text(word)
                .font(.system(size: isAnswer ? 32 : 36, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // Pronunciation (answer side only)
            if let pronunciation = pronunciation, isAnswer {
                Text("[\(pronunciation)]")
                    .font(.system(size: 18))
                    .foregroundColor(.gray)
                    .italic()
            }

            // Example sentence (answer side only)
            if let example = example, isAnswer {
                Text(example)
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.top, 10)
            }

            Spacer()

            // Tap instruction
            Text(isAnswer ? "Rate your recall" : "Tap to reveal")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .padding(.bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
        )
        .padding(.horizontal)
    }
}

// MARK: - Quality Buttons
struct QualityButtonsView: View {
    let onQualitySelected: (ReviewQuality) -> Void

    var body: some View {
        HStack(spacing: 12) {
            ForEach([ReviewQuality.completeBlackout, .correctWithDifficulty, .good, .perfect], id: \.self) { quality in
                QualityButton(
                    quality: quality,
                    action: { onQualitySelected(quality) }
                )
            }
        }
    }
}

struct QualityButton: View {
    let quality: ReviewQuality
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(quality.emoji)
                    .font(.system(size: 24))

                Text(quality.title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(quality.color)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(quality.color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(quality.color, lineWidth: 2)
                    )
            )
        }
    }
}

// MARK: - No Cards View
struct NoCardsView: View {
    let onAddCards: () -> Void
    let onReviewAll: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)

            VStack(spacing: 8) {
                Text("All caught up!")
                    .font(.system(size: 28, weight: .bold))

                Text("No cards due for review right now")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }

            VStack(spacing: 12) {
                Button(action: onAddCards) {
                    Text("Add New Cards")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.blue)
                        .cornerRadius(12)
                }

                Button(action: onReviewAll) {
                    Text("Review All Cards")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color.blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                }
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }
}

// MARK: - Session Stats
struct SessionStats {
    var cardsReviewed: Int = 0
    var correct: Int = 0
    var startTime = Date()
}

#Preview {
    VocabularyReviewView()
        .environmentObject(SpacedRepetitionService.shared)
}