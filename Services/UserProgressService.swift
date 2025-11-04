import Foundation

/// Lightweight local progress tracker so the UI can compile and run
/// even before the real analytics backend is wired up.
final class UserProgressService {
    static let shared = UserProgressService()

    private enum Keys {
        static let streak = "progress.currentStreak"
        static let todayMinutes = "progress.todayMinutes"
        static let lastStudyDate = "progress.lastStudyDate"
    }

    private let userDefaults: UserDefaults

    private(set) var currentStreak: Int
    private(set) var todayMinutes: Int
    private var lastStudyDate: Date?

    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.currentStreak = userDefaults.integer(forKey: Keys.streak)
        self.todayMinutes = userDefaults.integer(forKey: Keys.todayMinutes)
        self.lastStudyDate = userDefaults.object(forKey: Keys.lastStudyDate) as? Date

        resetIfNeeded(for: Date())
    }

    func recordStudySession(minutes: Int, date: Date = Date()) {
        resetIfNeeded(for: date)

        todayMinutes += max(0, minutes)
        lastStudyDate = date

        userDefaults.set(todayMinutes, forKey: Keys.todayMinutes)
        userDefaults.set(lastStudyDate, forKey: Keys.lastStudyDate)

        if todayMinutes > 0 {
            // Basic streak handling: bump when we study after a break of <=1 day
            updateStreak(for: date)
        }
    }

    private func resetIfNeeded(for date: Date) {
        guard let lastDate = lastStudyDate else { return }
        if !Calendar.current.isDate(lastDate, inSameDayAs: date) {
            todayMinutes = 0
            userDefaults.set(todayMinutes, forKey: Keys.todayMinutes)
        }
    }

    private func updateStreak(for date: Date) {
        guard let lastDate = lastStudyDate else {
            currentStreak = max(currentStreak, 1)
            userDefaults.set(currentStreak, forKey: Keys.streak)
            return
        }

        let calendar = Calendar.current
        if calendar.isDate(lastDate, inSameDayAs: date) {
            // already counted today
            return
        }

        let daysBetween = calendar.dateComponents([.day], from: lastDate, to: date).day
        if let days = daysBetween, days == 1 {
            currentStreak += 1
        } else if let days = daysBetween, days > 1 {
            currentStreak = 1
        } else if currentStreak == 0 {
            currentStreak = 1
        }

        userDefaults.set(currentStreak, forKey: Keys.streak)
    }
}
