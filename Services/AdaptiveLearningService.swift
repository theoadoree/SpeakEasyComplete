import Foundation
import Combine

// MARK: - Adaptive Learning Service
class AdaptiveLearningService: ObservableObject {
    static let shared = AdaptiveLearningService()

    @Published var currentDifficulty: DifficultyLevel = .intermediate
    @Published var userPerformanceMetrics: UserPerformanceMetrics
    @Published var recommendedLessons: [Lesson] = []
    @Published var adaptiveSettings: AdaptiveSettings

    private var cancellables = Set<AnyCancellable>()
    private let performanceThresholds = PerformanceThresholds()

    init() {
        self.userPerformanceMetrics = UserPerformanceMetrics()
        self.adaptiveSettings = AdaptiveSettings()
        setupPerformanceMonitoring()
    }

    // MARK: - Performance Monitoring

    private func setupPerformanceMonitoring() {
        // Monitor fluency metrics would be setup here
        // In production, would subscribe to metrics updates from AutoVoiceService
    }

    func updatePerformanceMetrics(with fluencyMetrics: FluencyMetrics) {
        // Calculate overall score from various metrics
        let overallScore = (fluencyMetrics.naturalness + fluencyMetrics.confidenceScore +
                           fluencyMetrics.pronunciationAccuracy) / 3.0
        userPerformanceMetrics.recentFluencyScores.append(overallScore)
        if userPerformanceMetrics.recentFluencyScores.count > 20 {
            userPerformanceMetrics.recentFluencyScores.removeFirst()
        }

        userPerformanceMetrics.averageWPM = fluencyMetrics.wordsPerMinute
        userPerformanceMetrics.vocabularyGrowthRate = calculateVocabularyGrowth(fluencyMetrics.vocabularyDiversity)
        userPerformanceMetrics.pronunciationAccuracy = fluencyMetrics.confidenceScore

        adjustDifficulty()
        generatePersonalizedRecommendations()
    }

    // MARK: - Difficulty Adjustment

    private func adjustDifficulty() {
        let avgScore = userPerformanceMetrics.recentFluencyScores.reduce(0, +) / Double(userPerformanceMetrics.recentFluencyScores.count)

        if avgScore > performanceThresholds.excellentThreshold {
            if currentDifficulty != .advanced {
                increaseDifficulty()
            }
        } else if avgScore < performanceThresholds.strugglingThreshold {
            if currentDifficulty != .beginner {
                decreaseDifficulty()
            }
        }

        // Adjust specific parameters based on weak areas
        adaptToWeakAreas()
    }

    private func increaseDifficulty() {
        switch currentDifficulty {
        case .beginner:
            currentDifficulty = .elementary
        case .elementary:
            currentDifficulty = .intermediate
        case .intermediate:
            currentDifficulty = .upperIntermediate
        case .upperIntermediate:
            currentDifficulty = .advanced
        case .advanced:
            break // Already at max
        }

        updateAdaptiveSettings(forDifficulty: currentDifficulty)
    }

    private func decreaseDifficulty() {
        switch currentDifficulty {
        case .beginner:
            break // Already at minimum
        case .elementary:
            currentDifficulty = .beginner
        case .intermediate:
            currentDifficulty = .elementary
        case .upperIntermediate:
            currentDifficulty = .intermediate
        case .advanced:
            currentDifficulty = .upperIntermediate
        }

        updateAdaptiveSettings(forDifficulty: currentDifficulty)
    }

    // MARK: - Adaptive Settings

    private func updateAdaptiveSettings(forDifficulty difficulty: DifficultyLevel) {
        switch difficulty {
        case .beginner:
            adaptiveSettings.speechRate = 0.7
            adaptiveSettings.vocabularyComplexity = 0.3
            adaptiveSettings.sentenceLength = .short
            adaptiveSettings.grammarComplexity = .basic
            adaptiveSettings.responseTimeAllowance = 5.0

        case .elementary:
            adaptiveSettings.speechRate = 0.8
            adaptiveSettings.vocabularyComplexity = 0.4
            adaptiveSettings.sentenceLength = .short
            adaptiveSettings.grammarComplexity = .basic
            adaptiveSettings.responseTimeAllowance = 4.0

        case .intermediate:
            adaptiveSettings.speechRate = 0.9
            adaptiveSettings.vocabularyComplexity = 0.6
            adaptiveSettings.sentenceLength = .medium
            adaptiveSettings.grammarComplexity = .intermediate
            adaptiveSettings.responseTimeAllowance = 3.0

        case .upperIntermediate:
            adaptiveSettings.speechRate = 1.0
            adaptiveSettings.vocabularyComplexity = 0.75
            adaptiveSettings.sentenceLength = .medium
            adaptiveSettings.grammarComplexity = .intermediate
            adaptiveSettings.responseTimeAllowance = 2.5

        case .advanced:
            adaptiveSettings.speechRate = 1.1
            adaptiveSettings.vocabularyComplexity = 0.9
            adaptiveSettings.sentenceLength = .long
            adaptiveSettings.grammarComplexity = .advanced
            adaptiveSettings.responseTimeAllowance = 2.0
        }
    }

    // MARK: - Weak Area Detection

    private func adaptToWeakAreas() {
        let metrics = userPerformanceMetrics

        // Identify primary weakness
        var weakAreas: [WeakArea] = []

        if metrics.averageWPM < 80 {
            weakAreas.append(.speakingSpeed)
        }

        if metrics.pronunciationAccuracy < 0.7 {
            weakAreas.append(.pronunciation)
        }

        if metrics.vocabularyGrowthRate < 0.1 {
            weakAreas.append(.vocabulary)
        }

        if metrics.grammarErrorRate > 0.3 {
            weakAreas.append(.grammar)
        }

        if metrics.pauseFrequency > 0.4 {
            weakAreas.append(.fluency)
        }

        // Apply targeted adaptations
        for weakArea in weakAreas {
            applyTargetedAdaptation(for: weakArea)
        }
    }

    private func applyTargetedAdaptation(for weakArea: WeakArea) {
        switch weakArea {
        case .speakingSpeed:
            adaptiveSettings.enableSpeedDrills = true
            adaptiveSettings.targetWPM = userPerformanceMetrics.averageWPM + 10

        case .pronunciation:
            adaptiveSettings.enablePronunciationFocus = true
            adaptiveSettings.slowDownDifficultWords = true

        case .vocabulary:
            adaptiveSettings.vocabularyRepetition = 3
            adaptiveSettings.enableContextClues = true

        case .grammar:
            adaptiveSettings.grammarCorrection = .immediate
            adaptiveSettings.enableGrammarDrills = true

        case .fluency:
            adaptiveSettings.enableChunking = true
            adaptiveSettings.pauseReduction = true
        }
    }

    // MARK: - Personalized Recommendations

    func generatePersonalizedRecommendations() {
        recommendedLessons = []

        let allLessons = Lesson.getAllLessons()
        var scoredLessons: [(lesson: Lesson, score: Double)] = []

        for lesson in allLessons {
            let score = calculateLessonRelevanceScore(lesson)
            scoredLessons.append((lesson, score))
        }

        // Sort by relevance score and take top 5
        scoredLessons.sort { $0.score > $1.score }
        recommendedLessons = Array(scoredLessons.prefix(5).map { $0.lesson })
    }

    private func calculateLessonRelevanceScore(_ lesson: Lesson) -> Double {
        var score = 0.0

        // Match difficulty level - compare raw values
        if lesson.level.rawValue == currentDifficulty.rawValue {
            score += 50
        }

        // Consider user's topic preferences
        if userPrefersTopic(lesson.category.rawValue) {
            score += 15
        }

        // Prioritize unfinished lessons
        if !isLessonCompleted(lesson) {
            score += 25
        }

        // Add variety bonus for different categories
        if !recentlyPracticedCategory(lesson.category.rawValue) {
            score += 10
        }

        return score
    }

    private func techniqueTargetsWeakArea(_ technique: FluencyTechnique) -> Bool {
        let weakAreas = identifyWeakAreas()

        switch technique {
        case .shadowSpeaking:
            return weakAreas.contains(.pronunciation)
        case .tongueTwitters:
            return weakAreas.contains(.pronunciation) || weakAreas.contains(.fluency)
        case .rapidResponse:
            return weakAreas.contains(.speakingSpeed)
        case .storytelling:
            return weakAreas.contains(.vocabulary) || weakAreas.contains(.fluency)
        case .paraphrasing:
            return weakAreas.contains(.vocabulary)
        case .debating:
            return weakAreas.contains(.fluency) || weakAreas.contains(.grammar)
        }
    }

    private func identifyWeakAreas() -> [WeakArea] {
        var areas: [WeakArea] = []

        if userPerformanceMetrics.averageWPM < 80 {
            areas.append(.speakingSpeed)
        }
        if userPerformanceMetrics.pronunciationAccuracy < 0.7 {
            areas.append(.pronunciation)
        }
        if userPerformanceMetrics.vocabularyGrowthRate < 0.1 {
            areas.append(.vocabulary)
        }
        if userPerformanceMetrics.grammarErrorRate > 0.3 {
            areas.append(.grammar)
        }
        if userPerformanceMetrics.pauseFrequency > 0.4 {
            areas.append(.fluency)
        }

        return areas
    }

    // MARK: - Helper Methods

    private func calculateVocabularyGrowth(_ diversity: Double) -> Double {
        // Calculate growth rate based on vocabulary diversity trends
        return diversity * 0.15 // Simplified calculation
    }

    private func userPrefersTopic(_ category: String) -> Bool {
        // Check user's preferred topics from history
        return true // Placeholder
    }

    private func isLessonCompleted(_ lesson: Lesson) -> Bool {
        // Check if lesson is completed
        return false // Placeholder
    }

    private func recentlyPracticedCategory(_ category: String) -> Bool {
        // Check if category was recently practiced
        return false // Placeholder
    }
}

// MARK: - Supporting Types

enum DifficultyLevel: String, Codable, CaseIterable {
    case beginner = "Beginner"
    case elementary = "Elementary"
    case intermediate = "Intermediate"
    case upperIntermediate = "Upper-Intermediate"
    case advanced = "Advanced"
}

extension String {
    var difficultyValue: Int {
        switch self {
        case "Beginner": return 1
        case "Elementary": return 2
        case "Intermediate": return 3
        case "Upper-Intermediate": return 4
        case "Advanced": return 5
        default: return 3
        }
    }
}

struct UserPerformanceMetrics {
    var recentFluencyScores: [Double] = []
    var averageWPM: Double = 0
    var pronunciationAccuracy: Double = 0
    var vocabularyGrowthRate: Double = 0
    var grammarErrorRate: Double = 0
    var pauseFrequency: Double = 0
    var sessionCount: Int = 0
    var totalPracticeTime: TimeInterval = 0
    var streakDays: Int = 0
}

struct AdaptiveSettings {
    // Core settings
    var speechRate: Double = 1.0
    var vocabularyComplexity: Double = 0.5
    var sentenceLength: SentenceLength = .medium
    var grammarComplexity: GrammarComplexity = .intermediate
    var responseTimeAllowance: TimeInterval = 3.0

    // Targeted adaptations
    var enableSpeedDrills: Bool = false
    var targetWPM: Double = 120
    var enablePronunciationFocus: Bool = false
    var slowDownDifficultWords: Bool = false
    var vocabularyRepetition: Int = 1
    var enableContextClues: Bool = false
    var grammarCorrection: CorrectionStyle = .gentle
    var enableGrammarDrills: Bool = false
    var enableChunking: Bool = false
    var pauseReduction: Bool = false

    enum SentenceLength {
        case short, medium, long
    }

    enum GrammarComplexity {
        case basic, intermediate, advanced
    }

    enum CorrectionStyle {
        case none, gentle, immediate, strict
    }
}

struct PerformanceThresholds {
    let excellentThreshold: Double = 8.5
    let goodThreshold: Double = 7.0
    let averageThreshold: Double = 5.5
    let strugglingThreshold: Double = 4.0
}

enum WeakArea {
    case speakingSpeed
    case pronunciation
    case vocabulary
    case grammar
    case fluency
}