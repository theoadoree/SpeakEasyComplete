import Foundation

/// Gamification elements to maintain motivation
/// Used sparingly - focus is on learning, not just points
@MainActor
class GamificationService: ObservableObject {
    static let shared = GamificationService()

    @Published var achievements: [Achievement] = []
    @Published var currentStreak: Int = 0
    @Published var totalXP: Int = 0
    @Published var level: Int = 1
    @Published var badges: [Badge] = []

    private let notificationService = NotificationService.shared

    // MARK: - Achievement System

    func checkForAchievements(
        after activity: LearningActivity
    ) async {
        let newAchievements = evaluateAchievements(activity: activity)

        for achievement in newAchievements {
            if !achievements.contains(where: { $0.id == achievement.id }) {
                achievements.append(achievement)
                await notificationService.sendAchievementNotification(
                    title: achievement.title,
                    description: achievement.description
                )
            }
        }
    }

    private func evaluateAchievements(activity: LearningActivity) -> [Achievement] {
        var newAchievements: [Achievement] = []

        // Streak achievements
        if currentStreak == 7 {
            newAchievements.append(Achievement(
                id: "streak_7",
                title: "Week Warrior",
                description: "7-day streak",
                icon: "flame.fill",
                xpReward: 100,
                unlockedDate: Date()
            ))
        } else if currentStreak == 30 {
            newAchievements.append(Achievement(
                id: "streak_30",
                title: "Monthly Master",
                description: "30-day streak",
                icon: "flame.fill",
                xpReward: 500,
                unlockedDate: Date()
            ))
        }

        // Conversation achievements
        if activity.type == .conversation {
            newAchievements.append(Achievement(
                id: "first_conversation",
                title: "Breaking the Ice",
                description: "Completed first conversation",
                icon: "bubble.left.and.bubble.right.fill",
                xpReward: 50,
                unlockedDate: Date()
            ))
        }

        // Quiz achievements
        if activity.type == .quiz, let score = activity.score, score >= 90 {
            newAchievements.append(Achievement(
                id: "quiz_ace",
                title: "Quiz Ace",
                description: "Scored 90%+ on a quiz",
                icon: "star.fill",
                xpReward: 75,
                unlockedDate: Date()
            ))
        }

        return newAchievements
    }

    // MARK: - Streak Management

    func updateStreak(practicedToday: Bool) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        if practicedToday {
            currentStreak += 1
        } else {
            // Check if practiced yesterday
            // If not, reset streak
            currentStreak = 0
        }
    }

    func getStreakMotivation() -> String {
        switch currentStreak {
        case 0:
            return "Start your learning streak today!"
        case 1...6:
            return "Keep going! \(7 - currentStreak) more days to weekly streak."
        case 7...13:
            return "Amazing! You're on a \(currentStreak)-day streak!"
        case 14...29:
            return "Incredible! \(30 - currentStreak) more days to monthly milestone."
        case 30...:
            return "Outstanding! \(currentStreak)-day streak. You're unstoppable!"
        default:
            return "Keep learning!"
        }
    }

    // MARK: - XP and Leveling

    func awardXP(for activity: LearningActivity) {
        let xp = calculateXP(for: activity)
        totalXP += xp

        checkForLevelUp()
    }

    private func calculateXP(for activity: LearningActivity) -> Int {
        let baseXP: Int
        switch activity.type {
        case .lesson:
            baseXP = 20
        case .conversation:
            baseXP = 30
        case .quiz:
            baseXP = 25
        case .vocabulary:
            baseXP = 15
        case .reading:
            baseXP = 10
        }

        // Bonus for performance
        let performanceMultiplier = activity.score ?? 1.0
        return Int(Double(baseXP) * performanceMultiplier)
    }

    private func checkForLevelUp() {
        let requiredXP = level * 100 // Simple formula
        if totalXP >= requiredXP {
            level += 1
            Task {
                await notificationService.sendAchievementNotification(
                    title: "Level Up!",
                    description: "You've reached level \(level)! 🎉"
                )
            }
        }
    }

    func getProgressToNextLevel() -> Double {
        let requiredXP = level * 100
        let progressXP = totalXP % requiredXP
        return Double(progressXP) / Double(requiredXP)
    }

    // MARK: - Badge System

    func awardBadge(_ badge: Badge) {
        if !badges.contains(where: { $0.id == badge.id }) {
            badges.append(badge)
        }
    }

    func getAllAvailableBadges() -> [Badge] {
        return Badge.allBadges
    }

    func getBadgeProgress(for badge: Badge) -> Double {
        // Calculate progress toward earning badge
        return 0.5 // Simplified
    }

    // MARK: - Leaderboard (Optional)

    func getLeaderboardPosition() -> Int {
        // If implementing social features
        return 0
    }

    // MARK: - Daily Goals

    func getDailyGoal() -> DailyGoal {
        return DailyGoal(
            target: 15, // 15 minutes
            current: 0,
            completed: false
        )
    }

    func updateDailyGoalProgress(minutes: Int) {
        // Update progress
    }

    // MARK: - Progress Visualization

    func getWeeklyProgress() -> [DayProgress] {
        var progress: [DayProgress] = []
        let calendar = Calendar.current
        let today = Date()

        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -6 + i, to: today) {
                progress.append(DayProgress(
                    date: date,
                    minutesPracticed: Int.random(in: 0...30), // Replace with real data
                    completed: Bool.random()
                ))
            }
        }

        return progress
    }
}

// MARK: - Supporting Models

struct Achievement: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let xpReward: Int
    let unlockedDate: Date
}

struct Badge: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let rarity: BadgeRarity
    let requirement: String

    enum BadgeRarity {
        case common
        case rare
        case epic
        case legendary
    }

    static let allBadges: [Badge] = [
        Badge(
            id: "first_steps",
            name: "First Steps",
            description: "Complete your first lesson",
            icon: "figure.walk",
            rarity: .common,
            requirement: "Complete 1 lesson"
        ),
        Badge(
            id: "chatterbox",
            name: "Chatterbox",
            description: "Have 50 conversations",
            icon: "bubble.left.and.bubble.right.fill",
            rarity: .rare,
            requirement: "Complete 50 conversations"
        ),
        Badge(
            id: "word_wizard",
            name: "Word Wizard",
            description: "Master 1000 vocabulary words",
            icon: "text.book.closed.fill",
            rarity: .epic,
            requirement: "Master 1000 words"
        ),
        Badge(
            id: "polyglot",
            name: "Polyglot",
            description: "Reach advanced level",
            icon: "globe",
            rarity: .legendary,
            requirement: "Reach advanced level"
        )
    ]
}

struct LearningActivity {
    let type: ActivityType
    let duration: TimeInterval
    let score: Double?
    let timestamp: Date

    enum ActivityType {
        case lesson
        case conversation
        case quiz
        case vocabulary
        case reading
    }
}

struct DailyGoal {
    let target: Int // minutes
    var current: Int
    var completed: Bool

    var progress: Double {
        return min(1.0, Double(current) / Double(target))
    }
}

struct DayProgress {
    let date: Date
    let minutesPracticed: Int
    let completed: Bool
}
