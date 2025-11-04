import Foundation
import UserNotifications
import UIKit

@MainActor
class NotificationService: ObservableObject {
    static let shared = NotificationService()

    @Published var notificationsEnabled = false
    @Published var dailyReminderTime: Date = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
    @Published var streakReminderEnabled = true
    @Published var vocabularyReviewEnabled = true
    @Published var achievementNotificationsEnabled = true

    private let center = UNUserNotificationCenter.current()

    // Notification identifiers
    private enum NotificationID {
        static let dailyPractice = "daily_practice_reminder"
        static let streakWarning = "streak_warning"
        static let vocabularyReview = "vocabulary_review"
        static let quizCompletion = "quiz_completion"
        static let achievement = "achievement_unlock"
    }

    private init() {
        checkNotificationStatus()
    }

    // MARK: - Permission Management

    func requestPermission() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            await MainActor.run {
                self.notificationsEnabled = granted
            }
            if granted {
                await scheduleDefaultNotifications()
            }
            return granted
        } catch {
            print("Error requesting notification permission: \(error)")
            return false
        }
    }

    func checkNotificationStatus() {
        Task {
            let settings = await center.notificationSettings()
            await MainActor.run {
                self.notificationsEnabled = settings.authorizationStatus == .authorized
            }
        }
    }

    // MARK: - Daily Practice Reminder

    func scheduleDailyPracticeReminder() async {
        guard notificationsEnabled else { return }

        // Cancel existing daily reminder
        center.removePendingNotificationRequests(withIdentifiers: [NotificationID.dailyPractice])

        let content = UNMutableNotificationContent()
        content.title = "Time to Practice! 🎓"
        content.body = "Keep your streak going! Practice your target language for just 5 minutes today."
        content.sound = .default
        content.badge = 1

        // Schedule for daily reminder time
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: dailyReminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(
            identifier: NotificationID.dailyPractice,
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
            print("Daily practice reminder scheduled for \(components.hour ?? 0):\(components.minute ?? 0)")
        } catch {
            print("Error scheduling daily reminder: \(error)")
        }
    }

    // MARK: - Streak Warning

    func scheduleStreakWarning() async {
        guard notificationsEnabled && streakReminderEnabled else { return }

        center.removePendingNotificationRequests(withIdentifiers: [NotificationID.streakWarning])

        let content = UNMutableNotificationContent()
        content.title = "Don't Break Your Streak! 🔥"
        content.body = "You haven't practiced today. Complete a quick lesson to maintain your streak!"
        content.sound = .default
        content.badge = 1

        // Schedule for 8 PM if user hasn't practiced today
        var components = DateComponents()
        components.hour = 20
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(
            identifier: NotificationID.streakWarning,
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
        } catch {
            print("Error scheduling streak warning: \(error)")
        }
    }

    // MARK: - Vocabulary Review

    func scheduleVocabularyReview(wordCount: Int, interval: TimeInterval = 3600) async {
        guard notificationsEnabled && vocabularyReviewEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = "Time to Review! 📚"
        content.body = "You have \(wordCount) words ready for review. Strengthen your vocabulary now!"
        content.sound = .default
        content.badge = wordCount as NSNumber

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)

        let request = UNNotificationRequest(
            identifier: "\(NotificationID.vocabularyReview)_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
        } catch {
            print("Error scheduling vocabulary review: \(error)")
        }
    }

    // MARK: - Quiz Completion

    func sendQuizCompletionNotification(score: Int, passed: Bool) async {
        guard notificationsEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = passed ? "Quiz Passed! 🎉" : "Quiz Complete 📝"
        content.body = passed ?
            "Congratulations! You scored \(score)% on your quiz!" :
            "You scored \(score)%. Keep practicing to improve!"
        content.sound = .default

        // Immediate notification (1 second delay)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let request = UNNotificationRequest(
            identifier: "\(NotificationID.quizCompletion)_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
        } catch {
            print("Error sending quiz completion notification: \(error)")
        }
    }

    // MARK: - Achievement Unlocked

    func sendAchievementNotification(title: String, description: String) async {
        guard notificationsEnabled && achievementNotificationsEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = "Achievement Unlocked! 🏆"
        content.body = "\(title): \(description)"
        content.sound = .default

        // Immediate notification
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let request = UNNotificationRequest(
            identifier: "\(NotificationID.achievement)_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
        } catch {
            print("Error sending achievement notification: \(error)")
        }
    }

    // MARK: - Batch Operations

    func scheduleDefaultNotifications() async {
        await scheduleDailyPracticeReminder()
        await scheduleStreakWarning()
    }

    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
        // Reset badge
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func cancelNotification(withIdentifier identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    // MARK: - Settings Update

    func updateDailyReminderTime(_ newTime: Date) async {
        dailyReminderTime = newTime
        await scheduleDailyPracticeReminder()
    }

    func toggleStreakReminder(_ enabled: Bool) async {
        streakReminderEnabled = enabled
        if enabled {
            await scheduleStreakWarning()
        } else {
            cancelNotification(withIdentifier: NotificationID.streakWarning)
        }
    }

    func toggleVocabularyReview(_ enabled: Bool) {
        vocabularyReviewEnabled = enabled
    }

    func toggleAchievementNotifications(_ enabled: Bool) {
        achievementNotificationsEnabled = enabled
    }
}
