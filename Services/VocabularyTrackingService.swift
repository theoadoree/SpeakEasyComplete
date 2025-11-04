import Foundation

/// Simplified vocabulary tracking replacement for the full backend service.
final class VocabularyTrackingService {
    static let shared = VocabularyTrackingService()

    private enum Keys {
        static let totalWords = "vocab.totalWords"
        static let masteredWords = "vocab.masteredWords"
        static let learningWords = "vocab.learningWords"
        static let todayWords = "vocab.todayWords"
        static let lastUpdate = "vocab.lastUpdate"
    }

    private let userDefaults: UserDefaults

    private(set) var totalWords: Int
    private(set) var masteredWords: Int
    private(set) var learningWords: Int
    private(set) var todayWordsAdded: Int
    private var lastUpdateDate: Date?

    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.totalWords = userDefaults.integer(forKey: Keys.totalWords)
        self.masteredWords = userDefaults.integer(forKey: Keys.masteredWords)
        self.learningWords = userDefaults.integer(forKey: Keys.learningWords)
        self.todayWordsAdded = userDefaults.integer(forKey: Keys.todayWords)
        self.lastUpdateDate = userDefaults.object(forKey: Keys.lastUpdate) as? Date

        resetTodayIfNeeded(for: Date())
    }

    func addWord(masteryLevel: Int) {
        resetTodayIfNeeded(for: Date())

        totalWords += 1
        todayWordsAdded += 1

        if masteryLevel >= 2 {
            masteredWords += 1
        } else {
            learningWords += 1
        }

        persist()
    }

    private func resetTodayIfNeeded(for date: Date) {
        guard let last = lastUpdateDate else {
            lastUpdateDate = date
            persist()
            return
        }

        if !Calendar.current.isDate(last, inSameDayAs: date) {
            todayWordsAdded = 0
            lastUpdateDate = date
            userDefaults.set(todayWordsAdded, forKey: Keys.todayWords)
            userDefaults.set(lastUpdateDate, forKey: Keys.lastUpdate)
        }
    }

    private func persist() {
        userDefaults.set(totalWords, forKey: Keys.totalWords)
        userDefaults.set(masteredWords, forKey: Keys.masteredWords)
        userDefaults.set(learningWords, forKey: Keys.learningWords)
        userDefaults.set(todayWordsAdded, forKey: Keys.todayWords)
        userDefaults.set(Date(), forKey: Keys.lastUpdate)
    }
}
