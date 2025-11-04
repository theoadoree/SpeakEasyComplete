import Foundation

// MARK: - Multi-Language Service

/// Main service that manages multiple language engines and content generation
@MainActor
class MultiLanguageService: ObservableObject {
    static let shared = MultiLanguageService()

    @Published var currentLanguage: Language = .spanish
    @Published var availableLanguages: [Language] = [.spanish, .french, .mandarin, .japanese]

    private var languageEngines: [Language: LanguageEngine] = [:]
    private var contentCache: ContentCache = ContentCache()

    private init() {
        // Initialize with Spanish by default
        initializeLanguage(.spanish)
    }

    /// Initialize a language engine for a specific language
    func initializeLanguage(_ language: Language) {
        if languageEngines[language] == nil {
            languageEngines[language] = LanguageEngine(language: language)
            print("✅ Initialized language engine for \(language.rawValue)")
        }
    }

    /// Get the language engine for a specific language
    func getEngine(for language: Language) -> LanguageEngine {
        if let engine = languageEngines[language] {
            return engine
        }

        // Initialize if not yet created
        initializeLanguage(language)
        return languageEngines[language]!
    }

    /// Switch the current language
    func switchLanguage(to language: Language) {
        currentLanguage = language
        initializeLanguage(language)
    }

    /// Generate content with caching
    func generateContent(
        language: Language,
        type: ContentGenerationType,
        level: CEFRLevel,
        useCache: Bool = true
    ) async -> GeneratedContent {
        // Check cache first
        if useCache, let cached = contentCache.get(language: language, type: type, level: level) {
            print("📦 Using cached content for \(language.rawValue) \(type)")
            return cached
        }

        // Generate new content
        let engine = getEngine(for: language)
        let content = await engine.generateContent(type: type, level: level)

        // Cache it
        contentCache.store(content, language: language, type: type, level: level)

        return content
    }

    /// Get language features
    func getFeatures(for language: Language) -> LanguageFeatures {
        return getEngine(for: language).features
    }

    /// Get grammar rules for a specific level
    func getGrammarRules(for language: Language, level: CEFRLevel) -> [String] {
        return getEngine(for: language).grammar.rulesForLevel(level)
    }

    /// Get cultural scenarios for a specific level
    func getCulturalScenarios(for language: Language, level: CEFRLevel) -> [CulturalScenario] {
        return getEngine(for: language).culture.scenariosForLevel(level)
    }

    /// Get pronunciation drills for a specific level
    func getPronunciationDrills(for language: Language, level: CEFRLevel) -> [PronunciationDrill] {
        return getEngine(for: language).pronunciation.getDrillsForLevel(level)
    }

    /// Calculate content reuse percentage between languages
    func calculateReusePercentage(from sourceLanguage: Language, to targetLanguage: Language) -> Double {
        if sourceLanguage.languageFamily == targetLanguage.languageFamily {
            return sourceLanguage.languageFamily.contentReusePercentage
        }
        return 0.20 // Base universal content (20%)
    }
}

// MARK: - Content Cache

/// Cache system for generated content to reduce API costs
class ContentCache {
    private var cache: [String: CachedContent] = [:]
    private let maxCacheSize = 1000
    private let cacheExpirationHours = 24

    struct CachedContent {
        let content: GeneratedContent
        let timestamp: Date
    }

    func get(language: Language, type: ContentGenerationType, level: CEFRLevel) -> GeneratedContent? {
        let key = makeKey(language: language, type: type, level: level)

        guard let cached = cache[key] else { return nil }

        // Check if expired
        let hoursSinceCached = Date().timeIntervalSince(cached.timestamp) / 3600
        if hoursSinceCached > Double(cacheExpirationHours) {
            cache.removeValue(forKey: key)
            return nil
        }

        return cached.content
    }

    func store(_ content: GeneratedContent, language: Language, type: ContentGenerationType, level: CEFRLevel) {
        let key = makeKey(language: language, type: type, level: level)

        // Implement simple LRU if cache is full
        if cache.count >= maxCacheSize {
            removeOldestEntry()
        }

        cache[key] = CachedContent(content: content, timestamp: Date())
    }

    private func makeKey(language: Language, type: ContentGenerationType, level: CEFRLevel) -> String {
        let typeString: String
        switch type {
        case .conversation: typeString = "conv"
        case .grammarLesson: typeString = "gram"
        case .pronunciationExercise: typeString = "pron"
        case .culturalLesson: typeString = "cult"
        case .story: typeString = "stor"
        case .vocabulary: typeString = "vocab"
        }
        return "\(language.rawValue)_\(typeString)_\(level.rawValue)"
    }

    private func removeOldestEntry() {
        var oldestKey: String?
        var oldestTime: Date?

        for (key, cached) in cache {
            if oldestTime == nil || cached.timestamp < oldestTime! {
                oldestTime = cached.timestamp
                oldestKey = key
            }
        }

        if let key = oldestKey {
            cache.removeValue(forKey: key)
        }
    }

    func clear() {
        cache.removeAll()
    }

    func size() -> Int {
        return cache.count
    }
}

// MARK: - AI Content Generator with Language-Specific Prompts

/// Handles AI-powered content generation with language-specific prompting
class AIContentGenerator {
    private let apiKey: String

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    /// Generate content using language-specific prompts
    func generateContent(
        language: Language,
        type: ContentGenerationType,
        level: CEFRLevel,
        features: LanguageFeatures
    ) async throws -> String {
        let prompt = buildPrompt(
            language: language,
            type: type,
            level: level,
            features: features
        )

        // This would call your AI API (OpenAI, Anthropic, etc.)
        return try await callAIAPI(prompt: prompt)
    }

    private func buildPrompt(
        language: Language,
        type: ContentGenerationType,
        level: CEFRLevel,
        features: LanguageFeatures
    ) -> String {
        let basePrompt = getBasePrompt(for: type)
        let languageRules = getLanguageRules(language: language, features: features)
        let culturalContext = getCulturalContext(language: language, features: features)
        let commonMistakes = getCommonMistakes(language: language, features: features)

        return """
        \(basePrompt)

        Target Language: \(language.rawValue)
        CEFR Level: \(level.rawValue) (\(level.description))

        Language-Specific Requirements:
        \(languageRules)

        Cultural Context to Include:
        \(culturalContext)

        Common Mistakes to Avoid:
        \(commonMistakes)

        Grammar Focus for \(level.rawValue):
        \(features.grammar.prefix(3).joined(separator: ", "))

        Generate content that:
        1. Matches the \(level.rawValue) level precisely
        2. Incorporates authentic cultural elements
        3. Focuses on the key grammar points for this level
        4. Uses natural, native-speaker language
        5. Includes practical, real-world scenarios
        """
    }

    private func getBasePrompt(for type: ContentGenerationType) -> String {
        switch type {
        case .conversation:
            return """
            Generate a natural dialogue between native speakers.
            The conversation should be realistic, culturally appropriate,
            and demonstrate practical language use.
            """

        case .grammarLesson:
            return """
            Create a clear, comprehensive grammar lesson with:
            - Simple explanation
            - Multiple examples
            - Common usage patterns
            - Practice exercises
            """

        case .pronunciationExercise:
            return """
            Design pronunciation exercises focusing on:
            - Minimal pairs
            - Challenging sounds for English speakers
            - Rhythm and intonation patterns
            - Real words and phrases
            """

        case .culturalLesson:
            return """
            Create an engaging cultural lesson that:
            - Explains cultural context
            - Provides practical guidance
            - Includes do's and don'ts
            - Uses authentic examples
            """

        case .story:
            return """
            Write an engaging story that:
            - Uses appropriate vocabulary for the level
            - Incorporates target grammar structures
            - Reflects authentic cultural context
            - Is interesting and motivating
            - Length: 200-300 words
            """

        case .vocabulary:
            return """
            Generate a thematic vocabulary set with:
            - 15-20 words
            - Example sentences
            - Related phrases
            - Memory aids
            """
        }
    }

    private func getLanguageRules(language: Language, features: LanguageFeatures) -> String {
        var rules: [String] = []

        // Add grammar-specific rules
        rules.append("Grammar: " + features.grammar.prefix(3).joined(separator: ", "))

        // Add pronunciation notes
        rules.append("Pronunciation: " + features.pronunciation.prefix(2).joined(separator: ", "))

        // Add writing system if applicable
        if let writing = features.writing {
            rules.append("Writing: " + writing.prefix(2).joined(separator: ", "))
        }

        return rules.joined(separator: "\n")
    }

    private func getCulturalContext(language: Language, features: LanguageFeatures) -> String {
        return features.culture.prefix(3).joined(separator: "\n")
    }

    private func getCommonMistakes(language: Language, features: LanguageFeatures) -> String {
        // Use unique challenges as common mistakes to avoid
        return features.uniqueChallenges.prefix(3).map { "- Avoid: \($0)" }.joined(separator: "\n")
    }

    private func callAIAPI(prompt: String) async throws -> String {
        // Placeholder for actual API call
        // In production, this would call OpenAI, Anthropic, or your chosen AI API
        return "Generated content for: \(prompt.prefix(50))..."
    }
}

// MARK: - Content Scaling Strategy

/// Manages the rollout and scaling of languages
struct ContentScalingStrategy {
    struct Phase {
        let name: String
        let weeks: String
        let languages: [Language]
        let focus: String
        let estimatedCost: String
    }

    static let phases: [Phase] = [
        Phase(
            name: "Phase 1: Spanish Launch",
            weeks: "1-8",
            languages: [.spanish],
            focus: "Complete feature set, all levels A1-C2",
            estimatedCost: "$10,000"
        ),
        Phase(
            name: "Phase 2: Romance Languages",
            weeks: "9-16",
            languages: [.french, .italian, .portuguese],
            focus: "60% content reuse from Spanish",
            estimatedCost: "$12,000 ($4k each)"
        ),
        Phase(
            name: "Phase 3: Germanic Languages",
            weeks: "17-24",
            languages: [.german],
            focus: "Case system, word order variations",
            estimatedCost: "$5,000"
        ),
        Phase(
            name: "Phase 4: Asian Languages",
            weeks: "25-40",
            languages: [.mandarin, .japanese],
            focus: "Character systems, tones, new paradigms",
            estimatedCost: "$30,000 ($15k each)"
        )
    ]

    static func estimatedTimeToLaunch(language: Language) -> String {
        for phase in phases {
            if phase.languages.contains(language) {
                return phase.weeks + " weeks"
            }
        }
        return "Not scheduled"
    }

    static func estimatedCost(language: Language) -> String {
        switch language {
        case .spanish: return "$10,000"
        case .french, .italian, .portuguese: return "$4,000"
        case .german, .dutch: return "$5,000"
        case .mandarin, .japanese: return "$15,000"
        }
    }
}

// MARK: - Cost Optimization

/// Tracks and optimizes content generation costs
class ContentCostOptimization {
    enum CostTier {
        case expensive      // Generate once, cache forever
        case moderate       // Template-based, regenerate occasionally
        case cheap          // Universal, minimal generation needed
    }

    static func getCostTier(for type: ContentGenerationType) -> CostTier {
        switch type {
        case .grammarLesson, .culturalLesson:
            return .expensive
        case .conversation, .story, .pronunciationExercise:
            return .moderate
        case .vocabulary:
            return .cheap
        }
    }

    static func estimateCostPerUser(language: Language, monthlyActiveTime: TimeInterval) -> Double {
        // Assumptions:
        // - 1 hour = 4 conversations, 2 grammar lessons, 3 pronunciation exercises
        // - Each conversation costs ~$0.01, grammar lesson ~$0.02, pronunciation ~$0.005

        let hoursPerMonth = monthlyActiveTime / 3600
        let conversationCost = hoursPerMonth * 4 * 0.01
        let grammarCost = hoursPerMonth * 2 * 0.02
        let pronunciationCost = hoursPerMonth * 3 * 0.005

        let totalCost = conversationCost + grammarCost + pronunciationCost

        // Cache effectiveness reduces costs by ~70%
        return totalCost * 0.3
    }

    static func estimateMonthlyBudget(activeUsers: Int, avgTimePerUser: TimeInterval) -> Double {
        let costPerUser = estimateCostPerUser(language: .spanish, monthlyActiveTime: avgTimePerUser)
        return Double(activeUsers) * costPerUser
    }
}

// MARK: - Content Reuse Matrix

/// Manages content reuse between languages
struct ContentReuseMatrix {
    // High reuse (80%+)
    static let sharedContent = [
        "SRS algorithm",
        "Progress tracking",
        "Basic scenarios (greetings, numbers)",
        "UI/UX structure",
        "Gamification system"
    ]

    // Moderate reuse (40-60%)
    static let adaptableContent = [
        "Story templates",
        "Conversation flows",
        "Grammar exercise formats",
        "Quiz structures"
    ]

    // No reuse (0%)
    static let uniqueContent = [
        "Pronunciation training",
        "Writing systems",
        "Cultural contexts",
        "Language-specific grammar"
    ]

    static func reusePercentage(from source: Language, to target: Language) -> Double {
        if source == target { return 1.0 }

        if source.languageFamily == target.languageFamily {
            return source.languageFamily.contentReusePercentage
        }

        return 0.20 // Universal content only (20%)
    }

    static func estimateUniqueWork(for language: Language, afterLaunching first: Language) -> Double {
        let reuse = reusePercentage(from: first, to: language)
        return 100.0 - (reuse * 100.0)
    }
}
