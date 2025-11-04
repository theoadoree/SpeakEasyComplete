import Foundation
import Combine
import SwiftUI

// MARK: - Spaced Repetition Service
@MainActor
class SpacedRepetitionService: ObservableObject {
    static let shared = SpacedRepetitionService()

    @Published var vocabularyCards: [VocabularyCard] = []
    @Published var dueCards: [VocabularyCard] = []
    @Published var todaysDueCount: Int = 0
    @Published var streakDays: Int = 0
    @Published var totalCardsLearned: Int = 0

    private var cancellables = Set<AnyCancellable>()
    private let algorithm = SM2Algorithm()
    private let notificationService = NotificationService.shared

    init() {
        loadVocabularyCards()
        updateDueCards()
        loadUserProgress()
        scheduleNotificationsIfNeeded()
    }

    // MARK: - Card Management

    func loadVocabularyCards() {
        // Load from storage or generate initial cards
        vocabularyCards = generateInitialVocabulary()
    }

    func addVocabularyCard(_ card: VocabularyCard) {
        vocabularyCards.append(card)
        saveVocabularyCards()
        updateDueCards()
    }

    func updateDueCards() {
        let now = Date()
        dueCards = vocabularyCards.filter { card in
            card.nextReviewDate <= now && !card.isRetired
        }.sorted { $0.priority > $1.priority }

        todaysDueCount = dueCards.count

        // Schedule notification if cards are due
        if todaysDueCount > 0 {
            Task {
                await notificationService.scheduleVocabularyReview(wordCount: todaysDueCount, interval: 3600)
            }
        }
    }

    // MARK: - Review Process

    func reviewCard(_ card: VocabularyCard, quality: ReviewQuality) -> VocabularyCard {
        var updatedCard = card

        // Apply SM-2 algorithm
        let result = algorithm.calculateNextReview(
            card: card,
            quality: quality,
            reviewDate: Date()
        )

        updatedCard.repetitions = result.repetitions
        updatedCard.interval = result.interval
        updatedCard.easeFactor = result.easeFactor
        updatedCard.nextReviewDate = result.nextReviewDate
        updatedCard.lastReviewDate = Date()

        // Update statistics
        updatedCard.totalReviews += 1
        if quality == .perfect || quality == .good {
            updatedCard.successfulReviews += 1
        }
        updatedCard.accuracy = Double(updatedCard.successfulReviews) / Double(updatedCard.totalReviews)

        // Check for retirement (mastered)
        if updatedCard.repetitions >= 10 && updatedCard.accuracy > 0.95 {
            updatedCard.isRetired = true
            updatedCard.masteredDate = Date()
        }

        // Update card in collection
        if let index = vocabularyCards.firstIndex(where: { $0.id == card.id }) {
            vocabularyCards[index] = updatedCard
        }

        saveVocabularyCards()
        updateDueCards()

        return updatedCard
    }

    // MARK: - Statistics

    func getStatistics() -> LearningStatistics {
        let activeCards = vocabularyCards.filter { !$0.isRetired }
        let masteredCards = vocabularyCards.filter { $0.isRetired }

        let averageAccuracy = vocabularyCards.isEmpty ? 0 :
            vocabularyCards.reduce(0) { $0 + $1.accuracy } / Double(vocabularyCards.count)

        let learningVelocity = calculateLearningVelocity()

        return LearningStatistics(
            totalCards: vocabularyCards.count,
            activeCards: activeCards.count,
            masteredCards: masteredCards.count,
            dueToday: todaysDueCount,
            averageAccuracy: averageAccuracy,
            streakDays: streakDays,
            learningVelocity: learningVelocity,
            weakestTopics: identifyWeakestTopics(),
            strongestTopics: identifyStrongestTopics()
        )
    }

    private func calculateLearningVelocity() -> Double {
        // Cards learned per day over last 7 days
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let recentlyLearned = vocabularyCards.filter { card in
            guard let masteredDate = card.masteredDate else { return false }
            return masteredDate >= sevenDaysAgo
        }
        return Double(recentlyLearned.count) / 7.0
    }

    private func identifyWeakestTopics() -> [String] {
        let grouped = Dictionary(grouping: vocabularyCards) { $0.category }
        let averages = grouped.mapValues { cards in
            cards.reduce(0) { $0 + $1.accuracy } / Double(cards.count)
        }
        return averages.sorted { $0.value < $1.value }
            .prefix(3)
            .map { $0.key }
    }

    private func identifyStrongestTopics() -> [String] {
        let grouped = Dictionary(grouping: vocabularyCards) { $0.category }
        let averages = grouped.mapValues { cards in
            cards.reduce(0) { $0 + $1.accuracy } / Double(cards.count)
        }
        return averages.sorted { $0.value > $1.value }
            .prefix(3)
            .map { $0.key }
    }

    // MARK: - Adaptive Learning

    func generateAdaptiveCards(for weakAreas: [String]) -> [VocabularyCard] {
        var newCards: [VocabularyCard] = []

        for area in weakAreas {
            // Generate cards focusing on weak areas
            let cards = generateCardsForTopic(area, count: 5)
            newCards.append(contentsOf: cards)
        }

        return newCards
    }

    private func generateCardsForTopic(_ topic: String, count: Int) -> [VocabularyCard] {
        // Generate vocabulary cards for specific topic
        // This would connect to your content database
        var cards: [VocabularyCard] = []

        for i in 0..<count {
            let card = VocabularyCard(
                word: "\(topic) Word \(i + 1)",
                translation: "Translation \(i + 1)",
                pronunciation: "Pronunciation \(i + 1)",
                exampleSentence: "Example sentence using the word",
                category: topic,
                difficulty: .intermediate,
                audioURL: nil,
                imageURL: nil
            )
            cards.append(card)
        }

        return cards
    }

    // MARK: - Initial Vocabulary

    private func generateInitialVocabulary() -> [VocabularyCard] {
        // Basic Spanish vocabulary for demo
        return [
            VocabularyCard(
                word: "hola",
                translation: "hello",
                pronunciation: "OH-lah",
                exampleSentence: "Hola, ¿cómo estás?",
                category: "greeting",
                difficulty: .beginner,
                audioURL: nil,
                imageURL: nil
            ),
            VocabularyCard(
                word: "adiós",
                translation: "goodbye",
                pronunciation: "ah-DYOHS",
                exampleSentence: "Adiós, hasta mañana",
                category: "greeting",
                difficulty: .beginner,
                audioURL: nil,
                imageURL: nil
            ),
            VocabularyCard(
                word: "gracias",
                translation: "thank you",
                pronunciation: "GRAH-syahs",
                exampleSentence: "Gracias por tu ayuda",
                category: "courtesy",
                difficulty: .beginner,
                audioURL: nil,
                imageURL: nil
            ),
            VocabularyCard(
                word: "por favor",
                translation: "please",
                pronunciation: "por fah-BOR",
                exampleSentence: "Por favor, ayúdame",
                category: "courtesy",
                difficulty: .beginner,
                audioURL: nil,
                imageURL: nil
            ),
            VocabularyCard(
                word: "sí",
                translation: "yes",
                pronunciation: "SEE",
                exampleSentence: "Sí, estoy de acuerdo",
                category: "basic",
                difficulty: .beginner,
                audioURL: nil,
                imageURL: nil
            )
        ]
    }

    // MARK: - Notifications

    private func scheduleNotificationsIfNeeded() {
        Task {
            await notificationService.scheduleDefaultNotifications()
        }
    }

    func checkAndUpdateStreak() {
        // Check if user practiced today
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let practicedToday = vocabularyCards.contains { card in
            guard let lastReview = card.lastReviewDate else { return false }
            return calendar.isDate(lastReview, inSameDayAs: today)
        }

        if practicedToday {
            streakDays += 1
            // Send achievement notification for milestones
            if streakDays % 7 == 0 {
                Task {
                    await notificationService.sendAchievementNotification(
                        title: "\(streakDays) Day Streak!",
                        description: "You've practiced for \(streakDays) days in a row! 🔥"
                    )
                }
            }
        } else {
            // Check if streak was broken
            let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
            let practicedYesterday = vocabularyCards.contains { card in
                guard let lastReview = card.lastReviewDate else { return false }
                return calendar.isDate(lastReview, inSameDayAs: yesterday)
            }

            if !practicedYesterday && streakDays > 0 {
                streakDays = 0
            }
        }
    }

    // MARK: - Persistence

    private func saveVocabularyCards() {
        // Save to UserDefaults or Core Data
        // Implementation depends on your storage choice
    }

    private func loadUserProgress() {
        // Load user's progress from storage
        // Update streak, total learned, etc.
    }
}

// MARK: - SM-2 Algorithm
struct SM2Algorithm {
    func calculateNextReview(
        card: VocabularyCard,
        quality: ReviewQuality,
        reviewDate: Date
    ) -> ReviewResult {
        var repetitions = card.repetitions
        var interval = card.interval
        var easeFactor = card.easeFactor

        let qualityValue = quality.rawValue

        if qualityValue >= 3 {
            // Correct response
            if repetitions == 0 {
                interval = 1
            } else if repetitions == 1 {
                interval = 6
            } else {
                interval = Int(Double(interval) * easeFactor)
            }
            repetitions += 1
        } else {
            // Incorrect response
            repetitions = 0
            interval = 1
        }

        // Update ease factor
        easeFactor = max(1.3, easeFactor + (0.1 - Double(5 - qualityValue) * (0.08 + Double(5 - qualityValue) * 0.02)))

        // Calculate next review date
        let nextReviewDate = Calendar.current.date(
            byAdding: .day,
            value: interval,
            to: reviewDate
        ) ?? reviewDate

        return ReviewResult(
            repetitions: repetitions,
            interval: interval,
            easeFactor: easeFactor,
            nextReviewDate: nextReviewDate
        )
    }
}

// MARK: - Models

struct VocabularyCard: Identifiable, Codable {
    var id = UUID()
    let word: String
    let translation: String
    let pronunciation: String
    let exampleSentence: String
    let category: String
    let difficulty: Difficulty
    let audioURL: URL?
    let imageURL: URL?

    // Spaced repetition properties
    var repetitions: Int = 0
    var interval: Int = 1
    var easeFactor: Double = 2.5
    var nextReviewDate: Date = Date()
    var lastReviewDate: Date?

    // Statistics
    var totalReviews: Int = 0
    var successfulReviews: Int = 0
    var accuracy: Double = 0
    var isRetired: Bool = false
    var masteredDate: Date?

    // Computed properties
    var priority: Double {
        // Higher priority for overdue cards
        let overdueDays = Calendar.current.dateComponents(
            [.day],
            from: nextReviewDate,
            to: Date()
        ).day ?? 0

        return Double(max(0, overdueDays)) * (3.0 - easeFactor)
    }

    enum Difficulty: String, Codable, CaseIterable {
        case beginner
        case elementary
        case intermediate
        case advanced

        var color: Color {
            switch self {
            case .beginner: return .green
            case .elementary: return .blue
            case .intermediate: return .orange
            case .advanced: return .red
            }
        }
    }
}

enum ReviewQuality: Int {
    case completeBlackout = 0
    case incorrectButRemembered = 1
    case correctWithDifficulty = 2
    case correctWithHesitation = 3
    case good = 4
    case perfect = 5

    var title: String {
        switch self {
        case .completeBlackout: return "Forgot"
        case .incorrectButRemembered: return "Wrong"
        case .correctWithDifficulty: return "Hard"
        case .correctWithHesitation: return "Medium"
        case .good: return "Good"
        case .perfect: return "Easy"
        }
    }

    var color: Color {
        switch self {
        case .completeBlackout, .incorrectButRemembered:
            return .red
        case .correctWithDifficulty:
            return .orange
        case .correctWithHesitation:
            return .yellow
        case .good:
            return .green
        case .perfect:
            return .blue
        }
    }

    var emoji: String {
        switch self {
        case .completeBlackout: return "😵"
        case .incorrectButRemembered: return "😔"
        case .correctWithDifficulty: return "😰"
        case .correctWithHesitation: return "🤔"
        case .good: return "😊"
        case .perfect: return "🎯"
        }
    }
}

struct ReviewResult {
    let repetitions: Int
    let interval: Int
    let easeFactor: Double
    let nextReviewDate: Date
}

struct LearningStatistics {
    let totalCards: Int
    let activeCards: Int
    let masteredCards: Int
    let dueToday: Int
    let averageAccuracy: Double
    let streakDays: Int
    let learningVelocity: Double
    let weakestTopics: [String]
    let strongestTopics: [String]
}

// MARK: - Learning Curve Optimizer
class LearningCurveOptimizer: ObservableObject {
    @Published var optimalReviewTimes: [Date] = []
    @Published var forgettingCurve: [DataPoint] = []

    struct DataPoint: Identifiable {
        let id = UUID()
        let time: TimeInterval
        let retentionProbability: Double
    }

    func calculateOptimalReviewSchedule(for card: VocabularyCard) -> [Date] {
        // Based on Ebbinghaus forgetting curve
        let _ = 1.0  // initialRetention - for future retention curve calculations
        let _ = 0.5  // decayRate - for future decay modeling

        var reviewDates: [Date] = []
        var currentDate = Date()

        // Calculate review points where retention would drop below 80%
        let _ = 0.8  // retentionThreshold - for future threshold checks

        for i in 1...5 {
            let daysUntilReview = pow(2.0, Double(i - 1)) * card.easeFactor
            currentDate = Calendar.current.date(
                byAdding: .day,
                value: Int(daysUntilReview),
                to: currentDate
            ) ?? currentDate
            reviewDates.append(currentDate)
        }

        return reviewDates
    }

    func generateForgettingCurve(easeFactor: Double) -> [DataPoint] {
        var curve: [DataPoint] = []

        for hour in stride(from: 0, to: 168, by: 4) { // 1 week in 4-hour intervals
            let retention = exp(-Double(hour) / (24.0 * easeFactor))
            curve.append(DataPoint(
                time: Double(hour),
                retentionProbability: retention
            ))
        }

        return curve
    }
}
