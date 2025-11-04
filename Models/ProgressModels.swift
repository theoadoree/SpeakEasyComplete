//
//  ProgressModels.swift
//  SpeakEasy
//
//  Created by Claude on 2025-11-01.
//

import SwiftUI
import Foundation

// MARK: - Analytics Models

struct DailyActivityData: Identifiable {
    let id = UUID()
    let date: Date
    let minutes: Int
    let streak: Int
}

struct VocabularyGrowthData: Identifiable {
    let id = UUID()
    let date: Date
    let cumulativeWords: Int
    let newWords: Int
    let learningWords: Int
    let knownWords: Int
    let masteredWords: Int
    let isMilestone: Bool
}

struct TimeDistributionData: Identifiable {
    let id = UUID()
    let activity: String
    let minutes: Int

    var percentage: Int {
        // This will be calculated based on total
        return 0
    }
}

struct AccuracyData: Identifiable {
    let id = UUID()
    let date: Date
    let accuracy: Int
}

struct WeeklyStats {
    let totalMinutes: Int
    let wordsLearned: Int
    let lessonsCompleted: Int
    let reviewsCompleted: Int
}

// MARK: - Vocabulary Models

struct VocabularyStats {
    let totalWords: Int
    let masteredWords: Int
    let learningWords: Int
    let newWords: Int

    var masteryPercentage: Int {
        guard totalWords > 0 else { return 0 }
        return (masteredWords * 100) / totalWords
    }

    var masteredPercentage: Int {
        guard totalWords > 0 else { return 0 }
        return (masteredWords * 100) / totalWords
    }

    var learningPercentage: Int {
        guard totalWords > 0 else { return 0 }
        return (learningWords * 100) / totalWords
    }

    var newPercentage: Int {
        guard totalWords > 0 else { return 0 }
        return (newWords * 100) / totalWords
    }
}

struct VocabularyWord: Identifiable {
    let id = UUID()
    let spanish: String
    let english: String
    let masteryLevel: Int
    let source: VocabularySource
    let addedDate: Date
    let lastReviewed: Date?

    enum VocabularySource: String {
        case lesson = "Lesson"
        case song = "Music"
        case conversation = "Practice"
        case story = "Story"
    }

    var statusColor: Color {
        switch masteryLevel {
        case 0..<25: return .red
        case 25..<50: return .orange
        case 50..<75: return .blue
        default: return .green
        }
    }

    var sourceIcon: String {
        switch source {
        case .lesson: return "📚"
        case .song: return "🎵"
        case .conversation: return "💬"
        case .story: return "📖"
        }
    }
}

struct LearningRateData: Identifiable {
    let id = UUID()
    let weekLabel: String
    let wordsLearned: Int
}

struct CategoryDistribution: Identifiable {
    let id = UUID()
    let name: String
    let count: Int
    let percentage: Int
    let color: Color
}

// MARK: - Skills Models

struct SkillLevel: Identifiable {
    let id = UUID()
    let name: String
    let level: Int
    let icon: String
    let color: Color
    let description: String
}

struct SkillProgressData: Identifiable {
    let id = UUID()
    let date: Date
    let averageLevel: Int
}

struct SkillRecommendation: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let priority: Priority

    enum Priority {
        case high
        case medium
        case low
    }
}

// MARK: - SRS Models

struct VocabularyCard: Identifiable {
    let id = UUID()
    let front: String
    let back: String
    let exampleSentence: String?
    let cardNumber: Int
    let totalCards: Int
}

struct ReviewPerformanceData: Identifiable {
    let id = UUID()
    let day: String
    let correctReviews: Int
    let incorrectReviews: Int
}

// MARK: - Achievement Models

struct Achievement: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let color: Color
    let points: Int
    let rarity: Rarity
    let category: Category
    let isUnlocked: Bool
    let unlockedDate: Date?
    let currentProgress: Int
    let targetProgress: Int
    let unlockTip: String

    enum Rarity: String {
        case common = "Common"
        case rare = "Rare"
        case epic = "Epic"
        case legendary = "Legendary"

        var color: Color {
            switch self {
            case .common: return .gray
            case .rare: return .blue
            case .epic: return .purple
            case .legendary: return .orange
            }
        }
    }

    enum Category: String {
        case learning = "Learning"
        case streaks = "Streaks"
        case vocabulary = "Vocabulary"
        case practice = "Practice"
        case social = "Social"
    }
}

// MARK: - Music Models

struct Song: Identifiable {
    let id = UUID()
    let title: String
    let artist: String
    let album: String?
    let genre: String
    let difficultyLevel: String
    let vocabularyCount: Int
    let duration: TimeInterval
    let lyrics: [LyricLine]?
    let spotifyID: String?
    let appleMusicID: String?
}

struct LyricLine: Identifiable {
    let id = UUID()
    let timestamp: TimeInterval
    let spanish: String
    let english: String?
    let vocabulary: [VocabularyWord]
}

struct MusicPlaylist: Identifiable {
    let id = UUID()
    let name: String
    let songCount: Int
    let color: Color
    let serviceSource: MusicService
}

struct MusicArtist: Identifiable {
    let id = UUID()
    let name: String
    let songCount: Int
    let color: Color
    let genre: String
}

enum MusicService {
    case spotify
    case appleMusic
}

// MARK: - Analytics Manager (Real Data Integration)

class AnalyticsManager: ObservableObject {
    @Published var dailyActivityData: [DailyActivityData] = []
    @Published var vocabularyGrowthData: [VocabularyGrowthData] = []
    @Published var timeDistributionData: [TimeDistributionData] = []
    @Published var accuracyData: [AccuracyData] = []
    @Published var weeklyStats: WeeklyStats = WeeklyStats(totalMinutes: 0, wordsLearned: 0, lessonsCompleted: 0, reviewsCompleted: 0)

    private let progressService = UserProgressService.shared
    private let vocabService = VocabularyTrackingService.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupObservers()
    }

    private func setupObservers() {
        // Auto-reload when data changes
        NotificationCenter.default.publisher(for: .studySessionRecorded)
            .sink { [weak self] _ in
                self?.loadData()
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: .vocabularyWordAdded)
            .sink { [weak self] _ in
                self?.loadData()
            }
            .store(in: &cancellables)
    }

    func loadData() {
        loadDailyActivity()
        loadVocabularyGrowth()
        loadTimeDistribution()
        loadAccuracyData()
        loadWeeklyStats()
    }

    func getDailyActivity(for timeRange: OverviewDashboard.TimeRange) -> [DailyActivityData] {
        let days = timeRange.days
        let data = progressService.getDailyActivityData(for: days)
        return Array(data.suffix(days))
    }

    func getVocabularyGrowth(for timeRange: OverviewDashboard.TimeRange) -> [VocabularyGrowthData] {
        let days = timeRange.days
        let data = vocabService.getGrowthData(for: days)
        return Array(data.suffix(days))
    }

    func getTimeDistribution(for timeRange: OverviewDashboard.TimeRange) -> [TimeDistributionData] {
        return timeDistributionData
    }

    func getAccuracyTrends(for timeRange: OverviewDashboard.TimeRange) -> [AccuracyData] {
        let days = timeRange.days
        return Array(accuracyData.suffix(days))
    }

    func getWeeklyStats() -> WeeklyStats {
        return weeklyStats
    }

    private func loadDailyActivity() {
        dailyActivityData = progressService.getDailyActivityData(for: 30)
    }

    private func loadVocabularyGrowth() {
        vocabularyGrowthData = vocabService.getGrowthData(for: 30)
    }

    private func loadTimeDistribution() {
        let defaults = UserDefaults.standard
        timeDistributionData = [
            TimeDistributionData(activity: "Conversation", minutes: defaults.integer(forKey: "time_conversation")),
            TimeDistributionData(activity: "Lessons", minutes: defaults.integer(forKey: "time_lessons")),
            TimeDistributionData(activity: "Music", minutes: defaults.integer(forKey: "time_music")),
            TimeDistributionData(activity: "Practice", minutes: defaults.integer(forKey: "time_practice")),
            TimeDistributionData(activity: "Review", minutes: defaults.integer(forKey: "time_review"))
        ]

        // If all zeros, show placeholder data
        if timeDistributionData.allSatisfy({ $0.minutes == 0 }) {
            timeDistributionData = [
                TimeDistributionData(activity: "Conversation", minutes: 0),
                TimeDistributionData(activity: "Lessons", minutes: 0),
                TimeDistributionData(activity: "Music", minutes: 0),
                TimeDistributionData(activity: "Practice", minutes: 0),
                TimeDistributionData(activity: "Review", minutes: 0)
            ]
        }
    }

    private func loadAccuracyData() {
        // Load from UserDefaults or use empty data
        let calendar = Calendar.current
        let today = Date()

        accuracyData = (0..<14).map { offset in
            let date = calendar.date(byAdding: .day, value: -offset, to: today)!
            // Would load real accuracy data here
            let accuracy = UserDefaults.standard.integer(forKey: "accuracy_\(date.timeIntervalSince1970)")
            return AccuracyData(
                date: date,
                accuracy: accuracy > 0 ? accuracy : 0
            )
        }.reversed()
    }

    private func loadWeeklyStats() {
        let lastWeek = progressService.getStudyHistory(for: 7)
        let totalMinutes = lastWeek.reduce(0) { $0 + $1.minutes }

        weeklyStats = WeeklyStats(
            totalMinutes: totalMinutes,
            wordsLearned: vocabService.todayWordsAdded * 7, // Estimate
            lessonsCompleted: UserDefaults.standard.integer(forKey: "weekly_lessons_completed"),
            reviewsCompleted: UserDefaults.standard.integer(forKey: "weekly_reviews_completed")
        )
    }
}

// MARK: - SRS Manager

class SRSManager: ObservableObject {
    @Published var dueNowCount: Int = 0
    @Published var dueTodayCount: Int = 0
    @Published var totalWords: Int = 0
    @Published var masteredWords: Int = 0
    @Published var learningWords: Int = 0
    @Published var todayReviewedCount: Int = 0
    @Published var todayCorrectCount: Int = 0
    @Published var performanceData: [ReviewPerformanceData] = []

    private var currentCardIndex = 0
    private var reviewCards: [VocabularyCard] = []

    func loadDecks() {
        // Load sample data
        dueNowCount = Int.random(in: 10...30)
        dueTodayCount = Int.random(in: 30...60)
        totalWords = Int.random(in: 200...500)
        masteredWords = Int.random(in: 50...150)
        learningWords = Int.random(in: 100...250)
        generatePerformanceData()
    }

    func getCount(for deck: ReviewSection.VocabularyDeck) -> Int {
        switch deck {
        case .all: return totalWords
        case .daily: return Int.random(in: 20...40)
        case .fromSongs: return Int.random(in: 30...60)
        case .fromLessons: return Int.random(in: 50...100)
        case .difficult: return Int.random(in: 15...30)
        }
    }

    func getDueCount(for deck: ReviewSection.VocabularyDeck) -> Int {
        switch deck {
        case .all: return dueNowCount
        case .daily: return Int.random(in: 5...10)
        case .fromSongs: return Int.random(in: 3...8)
        case .fromLessons: return Int.random(in: 5...12)
        case .difficult: return Int.random(in: 8...15)
        }
    }

    func getCurrentCard() -> VocabularyCard? {
        guard reviewCards.isEmpty else {
            return reviewCards[min(currentCardIndex, reviewCards.count - 1)]
        }

        // Generate sample card
        return VocabularyCard(
            front: "hola",
            back: "hello",
            exampleSentence: "¡Hola! ¿Cómo estás?",
            cardNumber: 1,
            totalCards: dueNowCount
        )
    }

    func submitResponse(_ quality: Int) {
        todayReviewedCount += 1
        if quality >= 3 {
            todayCorrectCount += 1
        }
    }

    func hasMoreCards() -> Bool {
        return currentCardIndex < dueNowCount - 1
    }

    private func generatePerformanceData() {
        performanceData = (0..<7).map { offset in
            ReviewPerformanceData(
                day: "Day \(offset + 1)",
                correctReviews: Int.random(in: 10...25),
                incorrectReviews: Int.random(in: 2...8)
            )
        }
    }
}

// MARK: - Vocabulary Manager

class VocabularyManager: ObservableObject {
    @Published var overallStats: VocabularyStats = VocabularyStats(totalWords: 0, masteredWords: 0, learningWords: 0, newWords: 0)
    @Published var allWords: [VocabularyWord] = []
    @Published var learningRateData: [LearningRateData] = []
    @Published var categoryDistribution: [CategoryDistribution] = []

    func loadVocabulary() {
        generateSampleVocabulary()
        generateLearningRateData()
        generateCategoryDistribution()
    }

    func getCount(for category: VocabularyProgressView.VocabCategory) -> Int {
        switch category {
        case .all: return allWords.count
        case .learned: return allWords.filter { $0.masteryLevel >= 75 }.count
        case .learning: return allWords.filter { $0.masteryLevel >= 25 && $0.masteryLevel < 75 }.count
        case .new: return allWords.filter { $0.masteryLevel < 25 }.count
        }
    }

    func getWords(for category: VocabularyProgressView.VocabCategory) -> [VocabularyWord] {
        switch category {
        case .all: return allWords
        case .learned: return allWords.filter { $0.masteryLevel >= 75 }
        case .learning: return allWords.filter { $0.masteryLevel >= 25 && $0.masteryLevel < 75 }
        case .new: return allWords.filter { $0.masteryLevel < 25 }
        }
    }

    private func generateSampleVocabulary() {
        let sampleWords = [
            ("hola", "hello"), ("adiós", "goodbye"), ("gracias", "thank you"),
            ("por favor", "please"), ("sí", "yes"), ("no", "no"),
            ("agua", "water"), ("comida", "food"), ("casa", "house"),
            ("amigo", "friend"), ("familia", "family"), ("trabajo", "work")
        ]

        allWords = sampleWords.map { spanish, english in
            VocabularyWord(
                spanish: spanish,
                english: english,
                masteryLevel: Int.random(in: 0...100),
                source: VocabularyWord.VocabularySource.allCases.randomElement()!,
                addedDate: Date(),
                lastReviewed: Date()
            )
        }

        let totalWords = allWords.count
        overallStats = VocabularyStats(
            totalWords: totalWords,
            masteredWords: allWords.filter { $0.masteryLevel >= 75 }.count,
            learningWords: allWords.filter { $0.masteryLevel >= 25 && $0.masteryLevel < 75 }.count,
            newWords: allWords.filter { $0.masteryLevel < 25 }.count
        )
    }

    private func generateLearningRateData() {
        learningRateData = (1...4).map { week in
            LearningRateData(
                weekLabel: "Week \(week)",
                wordsLearned: Int.random(in: 15...35)
            )
        }
    }

    private func generateCategoryDistribution() {
        let categories = [
            ("Greetings", Color.blue),
            ("Food", Color.orange),
            ("Travel", Color.green),
            ("Family", Color.purple),
            ("Work", Color.red)
        ]

        let total = 100
        categoryDistribution = categories.map { name, color in
            let count = Int.random(in: 10...30)
            return CategoryDistribution(
                name: name,
                count: count,
                percentage: (count * 100) / total,
                color: color
            )
        }
    }
}

extension VocabularyWord.VocabularySource: CaseIterable {
    static var allCases: [VocabularyWord.VocabularySource] {
        return [.lesson, .song, .conversation, .story]
    }
}

// MARK: - Skills Manager

class SkillsManager: ObservableObject {
    @Published var skillLevels: [SkillLevel] = []
    @Published var progressData: [SkillProgressData] = []
    @Published var recommendations: [SkillRecommendation] = []

    func loadSkills() {
        generateSkillLevels()
        generateProgressData()
        generateRecommendations()
    }

    private func generateSkillLevels() {
        skillLevels = [
            SkillLevel(name: "Speaking", level: 75, icon: "mic.fill", color: .blue, description: "Conversational fluency"),
            SkillLevel(name: "Listening", level: 82, icon: "ear.fill", color: .green, description: "Comprehension skills"),
            SkillLevel(name: "Reading", level: 68, icon: "book.fill", color: .orange, description: "Text understanding"),
            SkillLevel(name: "Writing", level: 60, icon: "pencil", color: .purple, description: "Written expression"),
            SkillLevel(name: "Grammar", level: 70, icon: "textformat", color: .red, description: "Language structure"),
            SkillLevel(name: "Pronunciation", level: 65, icon: "waveform", color: .pink, description: "Accent accuracy")
        ]
    }

    private func generateProgressData() {
        let calendar = Calendar.current
        let today = Date()

        progressData = (0..<6).map { offset in
            let date = calendar.date(byAdding: .month, value: -offset, to: today)!
            return SkillProgressData(
                date: date,
                averageLevel: Int.random(in: 60...75)
            )
        }.reversed()
    }

    private func generateRecommendations() {
        recommendations = [
            SkillRecommendation(
                title: "Practice Writing",
                description: "Your writing skill is lower than others. Try completing daily writing exercises.",
                icon: "pencil.circle.fill",
                priority: .high
            ),
            SkillRecommendation(
                title: "Improve Pronunciation",
                description: "Focus on difficult sounds with our pronunciation coach.",
                icon: "waveform.circle.fill",
                priority: .medium
            )
        ]
    }
}

// MARK: - Achievements Manager

class AchievementsManager: ObservableObject {
    @Published var achievements: [Achievement] = []
    @Published var totalAchievements: Int = 0
    @Published var unlockedCount: Int = 0
    @Published var totalPoints: Int = 0

    func loadAchievements() {
        generateAchievements()
        totalAchievements = achievements.count
        unlockedCount = achievements.filter { $0.isUnlocked }.count
        totalPoints = achievements.filter { $0.isUnlocked }.reduce(0) { $0 + $1.points }
    }

    func getCount(for category: AchievementsView.AchievementCategory) -> Int {
        if category == .all {
            return achievements.count
        }
        return achievements.filter { $0.category.rawValue.lowercased() == category.rawValue.lowercased() }.count
    }

    func getAchievements(for category: AchievementsView.AchievementCategory) -> [Achievement] {
        if category == .all {
            return achievements
        }
        return achievements.filter { $0.category.rawValue.lowercased() == category.rawValue.lowercased() }
    }

    private func generateAchievements() {
        achievements = [
            Achievement(
                title: "First Steps",
                description: "Complete your first lesson",
                icon: "checkmark.circle.fill",
                color: .green,
                points: 10,
                rarity: .common,
                category: .learning,
                isUnlocked: true,
                unlockedDate: Date(),
                currentProgress: 1,
                targetProgress: 1,
                unlockTip: "Complete any lesson to unlock"
            ),
            Achievement(
                title: "Week Warrior",
                description: "Maintain a 7-day streak",
                icon: "flame.fill",
                color: .orange,
                points: 50,
                rarity: .rare,
                category: .streaks,
                isUnlocked: true,
                unlockedDate: Date(),
                currentProgress: 7,
                targetProgress: 7,
                unlockTip: "Practice every day for 7 days"
            ),
            Achievement(
                title: "Word Master",
                description: "Learn 100 vocabulary words",
                icon: "book.closed.fill",
                color: .blue,
                points: 75,
                rarity: .epic,
                category: .vocabulary,
                isUnlocked: false,
                unlockedDate: nil,
                currentProgress: 65,
                targetProgress: 100,
                unlockTip: "Keep learning new vocabulary through lessons and practice"
            ),
            Achievement(
                title: "Conversation Expert",
                description: "Complete 50 conversation sessions",
                icon: "bubble.left.and.bubble.right.fill",
                color: .purple,
                points: 100,
                rarity: .legendary,
                category: .practice,
                isUnlocked: false,
                unlockedDate: nil,
                currentProgress: 32,
                targetProgress: 50,
                unlockTip: "Practice conversations regularly to unlock"
            )
        ]
    }
}

// MARK: - Music Manager

class MusicManager: ObservableObject {
    @Published var isConnected: Bool = false
    @Published var userPlaylists: [MusicPlaylist] = []
    @Published var recommendedSongs: [Song] = []
    @Published var trendingSongs: [Song] = []
    @Published var popularArtists: [MusicArtist] = []
    @Published var searchResults: [Song] = []

    func loadRecommendations() {
        generateSampleSongs()
        generateTrendingSongs()
        generatePopularArtists()
        // Check if connected
        isConnected = UserDefaults.standard.bool(forKey: "spotifyConnected") || UserDefaults.standard.bool(forKey: "appleMusicConnected")
    }

    func searchSongs(query: String) {
        // Simulate search
        searchResults = recommendedSongs.filter { $0.title.localizedCaseInsensitiveContains(query) || $0.artist.localizedCaseInsensitiveContains(query) }
    }

    func disconnect(_ service: MusicService) {
        switch service {
        case .spotify:
            UserDefaults.standard.set(false, forKey: "spotifyConnected")
        case .appleMusic:
            UserDefaults.standard.set(false, forKey: "appleMusicConnected")
        }
        isConnected = UserDefaults.standard.bool(forKey: "spotifyConnected") || UserDefaults.standard.bool(forKey: "appleMusicConnected")
    }

    func loadPlaylist(_ playlist: MusicPlaylist) {
        // Load playlist songs
    }

    private func generateSampleSongs() {
        recommendedSongs = [
            Song(title: "Bailando", artist: "Enrique Iglesias", album: "Sex and Love", genre: "Pop", difficultyLevel: "Beginner", vocabularyCount: 45, duration: 240, lyrics: nil, spotifyID: nil, appleMusicID: nil),
            Song(title: "Despacito", artist: "Luis Fonsi", album: "Vida", genre: "Reggaeton", difficultyLevel: "Intermediate", vocabularyCount: 62, duration: 228, lyrics: nil, spotifyID: nil, appleMusicID: nil),
            Song(title: "Vivir Mi Vida", artist: "Marc Anthony", album: "3.0", genre: "Salsa", difficultyLevel: "Intermediate", vocabularyCount: 58, duration: 245, lyrics: nil, spotifyID: nil, appleMusicID: nil)
        ]
    }

    private func generateTrendingSongs() {
        trendingSongs = [
            Song(title: "La Bicicleta", artist: "Carlos Vives", album: "Vives", genre: "Vallenato", difficultyLevel: "Beginner", vocabularyCount: 40, duration: 199, lyrics: nil, spotifyID: nil, appleMusicID: nil),
            Song(title: "Me Gustas Tu", artist: "Manu Chao", album: "Próxima Estación: Esperanza", genre: "Latin", difficultyLevel: "Beginner", vocabularyCount: 35, duration: 240, lyrics: nil, spotifyID: nil, appleMusicID: nil)
        ]
    }

    private func generatePopularArtists() {
        popularArtists = [
            MusicArtist(name: "Shakira", songCount: 24, color: .orange, genre: "Pop"),
            MusicArtist(name: "J Balvin", songCount: 18, color: .purple, genre: "Reggaeton"),
            MusicArtist(name: "Rosalía", songCount: 15, color: .pink, genre: "Flamenco")
        ]
    }
}
