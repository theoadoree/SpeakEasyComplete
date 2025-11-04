import SwiftUI
import Combine

class AppState: ObservableObject {
    // MARK: - User Info
    @Published var userName: String = "User"
    @Published var userLevel: LanguageLevel = .intermediate
    @Published var userInterests: [String] = []
    @Published var learningFocus: [String] = ["Conversation"]

    // MARK: - Daily Progress
    @Published var todayMinutes: Int = 0
    @Published var dailyGoal: Int = 15
    @Published var streak: Int = 0
    @Published var todayWords: Int = 0
    @Published var lastActivityDate: Date = Date()

    // MARK: - SRS & Review
    @Published var pendingReviewCount: Int = 0
    @Published var totalWords: Int = 0
    @Published var masteredWords: Int = 0
    @Published var learningWords: Int = 0

    // MARK: - Notifications & Badges
    @Published var unreadNotifications: Int = 0
    @Published var challengesBadgeCount: Int = 0
    @Published var lessonsBadgeCount: Int = 0

    // MARK: - Settings
    @Published var notificationsEnabled: Bool = true
    @Published var voiceSpeed: Double = 1.0
    @Published var autoPlayAudio: Bool = true
    @Published var pronunciationMode: Bool = false

    // MARK: - Music Integration
    @Published var spotifyConnected: Bool = false
    @Published var appleMusicConnected: Bool = false

    // MARK: - Theme
    @AppStorage("appTheme") var appTheme: String = "system"

    // MARK: - Learning Preferences
    @Published var preferredDifficulty: String = "adaptive"
    @Published var enabledFeatures: Set<String> = ["pronunciation", "grammar", "vocabulary"]
    @Published var targetLanguage: String = "es" // Default to Spanish

    private var cancellables = Set<AnyCancellable>()
    private var dailyResetTimer: Timer?

    init() {
        loadUserData()
        setupDailyReset()
        checkStreak()
        // Sync with backend services for accurate real-time data
        syncWithProgressService()
    }

    /// Synchronize with the backend progress service for accurate real-time data
    func syncWithProgressService() {
        let progressService = UserProgressService.shared
        let vocabService = VocabularyTrackingService.shared

        // Get accurate streak from service (only override if service has data)
        if progressService.currentStreak >= 0 {
            self.streak = progressService.currentStreak
        }

        // Get accurate minutes from service
        self.todayMinutes = progressService.todayMinutes

        // Get accurate vocabulary stats
        self.totalWords = vocabService.totalWords
        self.masteredWords = vocabService.masteredWords
        self.todayWords = vocabService.todayWordsAdded
        self.learningWords = vocabService.learningWords

        // Save synced data
        saveUserData()
    }

    deinit {
        dailyResetTimer?.invalidate()
    }

    // MARK: - Data Loading
    func loadUserData() {
        // Load from UserDefaults
        if let name = UserDefaults.standard.string(forKey: "userName") {
            userName = name
        }

        todayMinutes = UserDefaults.standard.integer(forKey: "todayMinutes")
        dailyGoal = UserDefaults.standard.integer(forKey: "dailyGoal")
        if dailyGoal == 0 { dailyGoal = 15 } // Default

        streak = UserDefaults.standard.integer(forKey: "streak")

        // Set some default demo data if nothing is saved
        if streak == 0 && !UserDefaults.standard.bool(forKey: "hasLoadedBefore") {
            // First time load - set demo data
            todayMinutes = 8
            todayWords = 12
            streak = 3
            totalWords = 245
            masteredWords = 127
            learningWords = 118
            pendingReviewCount = 23
            UserDefaults.standard.set(true, forKey: "hasLoadedBefore")
            saveUserData()
        } else {
            todayWords = UserDefaults.standard.integer(forKey: "todayWords")
            pendingReviewCount = UserDefaults.standard.integer(forKey: "pendingReviewCount")
            totalWords = UserDefaults.standard.integer(forKey: "totalWords")
            masteredWords = UserDefaults.standard.integer(forKey: "masteredWords")
            learningWords = UserDefaults.standard.integer(forKey: "learningWords")
        }

        // Badge counts
        unreadNotifications = UserDefaults.standard.integer(forKey: "unreadNotifications")
        challengesBadgeCount = UserDefaults.standard.integer(forKey: "challengesBadgeCount")
        lessonsBadgeCount = UserDefaults.standard.integer(forKey: "lessonsBadgeCount")

        notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        voiceSpeed = UserDefaults.standard.double(forKey: "voiceSpeed")
        if voiceSpeed == 0 { voiceSpeed = 1.0 } // Default

        autoPlayAudio = UserDefaults.standard.bool(forKey: "autoPlayAudio")
        pronunciationMode = UserDefaults.standard.bool(forKey: "pronunciationMode")
        spotifyConnected = UserDefaults.standard.bool(forKey: "spotifyConnected")
        appleMusicConnected = UserDefaults.standard.bool(forKey: "appleMusicConnected")

        if let levelStr = UserDefaults.standard.string(forKey: "userLevel"),
           let level = LanguageLevel(rawValue: levelStr) {
            userLevel = level
        }

        if let interests = UserDefaults.standard.array(forKey: "userInterests") as? [String] {
            userInterests = interests
        }

        if let focus = UserDefaults.standard.array(forKey: "learningFocus") as? [String] {
            learningFocus = focus
        }

        if let lastDate = UserDefaults.standard.object(forKey: "lastActivityDate") as? Date {
            lastActivityDate = lastDate
        }

        if let language = UserDefaults.standard.string(forKey: "targetLanguage") {
            targetLanguage = language
        }
    }

    // MARK: - Data Saving
    func saveUserData() {
        UserDefaults.standard.set(userName, forKey: "userName")
        UserDefaults.standard.set(todayMinutes, forKey: "todayMinutes")
        UserDefaults.standard.set(dailyGoal, forKey: "dailyGoal")
        UserDefaults.standard.set(streak, forKey: "streak")
        UserDefaults.standard.set(todayWords, forKey: "todayWords")
        UserDefaults.standard.set(pendingReviewCount, forKey: "pendingReviewCount")
        UserDefaults.standard.set(totalWords, forKey: "totalWords")
        UserDefaults.standard.set(masteredWords, forKey: "masteredWords")
        UserDefaults.standard.set(learningWords, forKey: "learningWords")
        UserDefaults.standard.set(unreadNotifications, forKey: "unreadNotifications")
        UserDefaults.standard.set(challengesBadgeCount, forKey: "challengesBadgeCount")
        UserDefaults.standard.set(lessonsBadgeCount, forKey: "lessonsBadgeCount")
        UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
        UserDefaults.standard.set(voiceSpeed, forKey: "voiceSpeed")
        UserDefaults.standard.set(autoPlayAudio, forKey: "autoPlayAudio")
        UserDefaults.standard.set(pronunciationMode, forKey: "pronunciationMode")
        UserDefaults.standard.set(spotifyConnected, forKey: "spotifyConnected")
        UserDefaults.standard.set(appleMusicConnected, forKey: "appleMusicConnected")
        UserDefaults.standard.set(userLevel.rawValue, forKey: "userLevel")
        UserDefaults.standard.set(userInterests, forKey: "userInterests")
        UserDefaults.standard.set(learningFocus, forKey: "learningFocus")
        UserDefaults.standard.set(lastActivityDate, forKey: "lastActivityDate")
        UserDefaults.standard.set(targetLanguage, forKey: "targetLanguage")
    }

    func updateFromProfile(_ profile: UserProfile) {
        userName = profile.name
        userLevel = LanguageLevel(cefrLevel: profile.level)
        userInterests = profile.interests
        saveUserData()
    }

    // MARK: - Progress Updates
    func incrementMinutes(_ minutes: Int, activityType: String = "Practice") {
        // Record to backend service for accurate tracking
        UserProgressService.shared.recordStudySession(minutes: minutes)
        RealTimeAnalyticsManager.shared.recordActivity(type: activityType, minutes: minutes)

        // Sync back to local state
        syncWithProgressService()

        lastActivityDate = Date()
        checkDailyGoalAchieved()
        saveUserData()
    }

    func incrementWords(_ count: Int, masteryLevel: Int = 0) {
        // Record to backend vocabulary service
        for _ in 0..<count {
            VocabularyTrackingService.shared.addWord(masteryLevel: masteryLevel)
        }

        // Sync back to local state
        syncWithProgressService()
        saveUserData()
    }

    func addMasteredWord() {
        masteredWords += 1
        if learningWords > 0 {
            learningWords -= 1
        }
        saveUserData()
    }

    func updatePendingReviews(_ count: Int) {
        pendingReviewCount = count
        saveUserData()
    }

    // MARK: - Badge Management
    func setBadgeCount(for tab: AppTab, count: Int) {
        switch tab {
        case .progress:
            pendingReviewCount = count
        case .learn:
            lessonsBadgeCount = count
        case .practice:
            challengesBadgeCount = count
        default:
            break
        }
        saveUserData()
    }

    func clearBadge(for tab: AppTab) {
        setBadgeCount(for: tab, count: 0)
    }

    func incrementBadge(for tab: AppTab) {
        switch tab {
        case .progress:
            pendingReviewCount += 1
        case .learn:
            lessonsBadgeCount += 1
        case .practice:
            challengesBadgeCount += 1
        default:
            break
        }
        saveUserData()
    }

    func addNotification() {
        unreadNotifications += 1
        saveUserData()
    }

    func clearNotifications() {
        unreadNotifications = 0
        saveUserData()
    }

    // MARK: - Streak Management
    private func setupDailyReset() {
        // Schedule daily reset at midnight
        let now = Date()
        let calendar = Calendar.current
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: now),
           let midnight = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: tomorrow) {
            let timeInterval = midnight.timeIntervalSince(now)

            dailyResetTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] _ in
                self?.performDailyReset()
            }
        }
    }

    private func performDailyReset() {
        // Reset daily counters
        todayMinutes = 0
        todayWords = 0

        // Check if streak should be maintained
        checkStreak()

        saveUserData()

        // Schedule next reset
        setupDailyReset()
    }

    private func checkStreak() {
        let calendar = Calendar.current
        let now = Date()

        // Check if last activity was yesterday
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: now) {
            if calendar.isDate(lastActivityDate, inSameDayAs: yesterday) ||
               calendar.isDate(lastActivityDate, inSameDayAs: now) {
                // Streak is maintained
                if !calendar.isDate(lastActivityDate, inSameDayAs: now) && todayMinutes >= dailyGoal {
                    streak += 1
                }
            } else {
                // Streak broken
                streak = 0
            }
        }

        saveUserData()
    }

    private func checkDailyGoalAchieved() {
        if todayMinutes >= dailyGoal {
            let calendar = Calendar.current
            if !calendar.isDate(lastActivityDate, inSameDayAs: Date()) {
                streak += 1
            }
        }
    }

    // MARK: - Settings Updates
    func updateDailyGoal(_ minutes: Int) {
        dailyGoal = minutes
        saveUserData()
    }

    func toggleNotifications(_ enabled: Bool) {
        notificationsEnabled = enabled
        saveUserData()
    }

    func updateVoiceSpeed(_ speed: Double) {
        voiceSpeed = speed
        saveUserData()
    }

    // MARK: - Computed Properties
    var progressPercentage: Double {
        guard dailyGoal > 0 else { return 0 }
        return min(Double(todayMinutes) / Double(dailyGoal), 1.0)
    }

    var totalBadgeCount: Int {
        pendingReviewCount + lessonsBadgeCount + challengesBadgeCount + unreadNotifications
    }

    var vocabularyProgress: Double {
        guard totalWords > 0 else { return 0 }
        return Double(masteredWords) / Double(totalWords)
    }
}
