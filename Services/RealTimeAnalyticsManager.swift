import Foundation

/// Placeholder analytics pipeline. In production this would push events
/// to a backend, but for now it simply logs and keeps minimal counters.
final class RealTimeAnalyticsManager {
    static let shared = RealTimeAnalyticsManager()

    private enum Keys {
        static let lastEventDate = "analytics.lastEventDate"
        static let totalMinutes = "analytics.totalMinutes"
    }

    private let logger = Logger()
    private let userDefaults: UserDefaults

    private(set) var totalLoggedMinutes: Int
    private(set) var lastActivityDate: Date?

    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.totalLoggedMinutes = userDefaults.integer(forKey: Keys.totalMinutes)
        self.lastActivityDate = userDefaults.object(forKey: Keys.lastEventDate) as? Date
    }

    func recordActivity(type: String, minutes: Int) {
        totalLoggedMinutes += max(0, minutes)
        lastActivityDate = Date()

        userDefaults.set(totalLoggedMinutes, forKey: Keys.totalMinutes)
        userDefaults.set(lastActivityDate, forKey: Keys.lastEventDate)

        logger.log("Recorded activity", metadata: [
            "type": type,
            "minutes": minutes,
            "total": totalLoggedMinutes
        ])
    }
}

private final class Logger {
    func log(_ message: String, metadata: [String: CustomStringConvertible] = [:]) {
        #if DEBUG
        if metadata.isEmpty {
            print("[Analytics] \(message)")
        } else {
            let metaString = metadata.map { "\($0)=\($1)" }.joined(separator: " ")
            print("[Analytics] \(message) => \(metaString)")
        }
        #endif
    }
}
