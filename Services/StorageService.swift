import Foundation

class StorageService {
    static let shared = StorageService()

    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // Storage Keys
    private enum Keys {
        static let userProfile = "speakeasy.userProfile"
        static let conversationHistory = "speakeasy.conversationHistory"
        static let onboardingComplete = "speakeasy.onboardingComplete"
        static let assessmentResult = "speakeasy.assessmentResult"
        static let contentLibrary = "speakeasy.contentLibrary"
        static let practiceStats = "speakeasy.practiceStats"
    }

    private init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    // MARK: - User Profile
    func saveUserProfile(_ profile: UserProfile) throws {
        let data = try encoder.encode(profile)
        userDefaults.set(data, forKey: Keys.userProfile)
    }

    func getUserProfile() -> UserProfile? {
        guard let data = userDefaults.data(forKey: Keys.userProfile) else {
            return nil
        }
        return try? decoder.decode(UserProfile.self, from: data)
    }

    func deleteUserProfile() {
        userDefaults.removeObject(forKey: Keys.userProfile)
    }

    // MARK: - Conversation History
    func saveConversationHistory(_ conversations: [Conversation]) throws {
        let data = try encoder.encode(conversations)
        userDefaults.set(data, forKey: Keys.conversationHistory)
    }

    func getConversationHistory() -> [Conversation] {
        guard let data = userDefaults.data(forKey: Keys.conversationHistory) else {
            return []
        }
        return (try? decoder.decode([Conversation].self, from: data)) ?? []
    }

    func addConversation(_ conversation: Conversation) throws {
        var conversations = getConversationHistory()
        conversations.append(conversation)
        try saveConversationHistory(conversations)
    }

    func deleteConversation(id: UUID) throws {
        var conversations = getConversationHistory()
        conversations.removeAll { $0.id == id }
        try saveConversationHistory(conversations)
    }

    func clearConversationHistory() {
        userDefaults.removeObject(forKey: Keys.conversationHistory)
    }

    // MARK: - Onboarding
    func setOnboardingComplete(_ complete: Bool) {
        userDefaults.set(complete, forKey: Keys.onboardingComplete)
    }

    func isOnboardingComplete() -> Bool {
        return userDefaults.bool(forKey: Keys.onboardingComplete)
    }

    // MARK: - Assessment Result
    func saveAssessmentResult(_ result: AssessmentResult) throws {
        let data = try encoder.encode(result)
        userDefaults.set(data, forKey: Keys.assessmentResult)
    }

    func getAssessmentResult() -> AssessmentResult? {
        guard let data = userDefaults.data(forKey: Keys.assessmentResult) else {
            return nil
        }
        return try? decoder.decode(AssessmentResult.self, from: data)
    }

    func deleteAssessmentResult() {
        userDefaults.removeObject(forKey: Keys.assessmentResult)
    }

    // MARK: - Content Library
    func saveContentLibrary(_ content: [ContentItem]) throws {
        let data = try encoder.encode(content)
        userDefaults.set(data, forKey: Keys.contentLibrary)
    }

    func getContentLibrary() -> [ContentItem] {
        guard let data = userDefaults.data(forKey: Keys.contentLibrary) else {
            return []
        }
        return (try? decoder.decode([ContentItem].self, from: data)) ?? []
    }

    func addContent(_ item: ContentItem) throws {
        var content = getContentLibrary()
        content.append(item)
        try saveContentLibrary(content)
    }

    func deleteContent(id: UUID) throws {
        var content = getContentLibrary()
        content.removeAll { $0.id == id }
        try saveContentLibrary(content)
    }

    func clearContentLibrary() {
        userDefaults.removeObject(forKey: Keys.contentLibrary)
    }

    // MARK: - Practice Statistics
    func savePracticeStats(_ stats: PracticeStats) throws {
        let data = try encoder.encode(stats)
        userDefaults.set(data, forKey: Keys.practiceStats)
    }

    func getPracticeStats() -> PracticeStats {
        guard let data = userDefaults.data(forKey: Keys.practiceStats) else {
            return PracticeStats()
        }
        return (try? decoder.decode(PracticeStats.self, from: data)) ?? PracticeStats()
    }

    // MARK: - Clear All Data
    func clearAllData() {
        deleteUserProfile()
        clearConversationHistory()
        setOnboardingComplete(false)
        deleteAssessmentResult()
        clearContentLibrary()
        userDefaults.removeObject(forKey: Keys.practiceStats)
    }
}

// MARK: - Content Item Model
struct ContentItem: Identifiable, Codable {
    let id: UUID
    let title: String
    let content: String
    let language: String
    let level: String
    let vocabulary: [String]
    let createdAt: Date

    init(id: UUID = UUID(), title: String, content: String, language: String, level: String, vocabulary: [String], createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.content = content
        self.language = language
        self.level = level
        self.vocabulary = vocabulary
        self.createdAt = createdAt
    }
}

// MARK: - Practice Statistics Model
struct PracticeStats: Codable {
    var totalSessions: Int
    var totalMessages: Int
    var totalMinutes: Int
    var streak: Int
    var lastPracticeDate: Date?

    init(totalSessions: Int = 0, totalMessages: Int = 0, totalMinutes: Int = 0, streak: Int = 0, lastPracticeDate: Date? = nil) {
        self.totalSessions = totalSessions
        self.totalMessages = totalMessages
        self.totalMinutes = totalMinutes
        self.streak = streak
        self.lastPracticeDate = lastPracticeDate
    }
}
