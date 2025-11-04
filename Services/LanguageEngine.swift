import Foundation

// MARK: - Language Systems

/// Grammar system for language-specific grammar rules and patterns
class GrammarSystem {
    let language: Language
    let rules: [String]
    let progressionByLevel: [CEFRLevel: [String]]

    init(language: Language, features: LanguageFeatures) {
        self.language = language
        self.rules = features.grammar
        self.progressionByLevel = Self.buildProgression(for: language, features: features)
    }

    private static func buildProgression(for language: Language, features: LanguageFeatures) -> [CEFRLevel: [String]] {
        let allRules = features.grammar

        switch language {
        case .spanish:
            return [
                .a1: ["Present tense (regular)", "Gender agreement (basic)", "Ser vs Estar (intro)"],
                .a2: ["Preterite (regular)", "Reflexive verbs", "Direct object pronouns"],
                .b1: ["Subjunctive (present)", "Imperfect tense", "Por vs Para"],
                .b2: ["Subjunctive (all tenses)", "Conditional", "Passive voice"],
                .c1: ["Advanced subjunctive uses", "Idiomatic expressions", "Complex sentence structure"],
                .c2: ["Literary tenses", "Regional variations", "Complete mastery"]
            ]
        case .french:
            return [
                .a1: ["Present tense", "Gender basics", "Basic negation"],
                .a2: ["Passé composé", "Imparfait", "Partitive articles"],
                .b1: ["Subjunctive (present)", "Pronouns Y/EN", "Future tense"],
                .b2: ["All subjunctive tenses", "Conditional past", "Passive voice"],
                .c1: ["Literary tenses", "Complex relative clauses", "Advanced negation"],
                .c2: ["Complete mastery", "Regional variations", "Literary French"]
            ]
        case .mandarin:
            return [
                .a1: ["Basic word order", "Simple measure words", "是 sentences"],
                .a2: ["Aspect markers (了)", "Common particles", "Time expressions"],
                .b1: ["了/过/着 mastery", "Complex sentences", "Comparison structures"],
                .b2: ["Idiomatic expressions", "Advanced particles", "Formal register"],
                .c1: ["Literary patterns", "Classical influence", "Regional variations"],
                .c2: ["Complete mastery", "Literary Chinese", "Ancient patterns"]
            ]
        case .japanese:
            return [
                .a1: ["Basic particles (は、が、を)", "Polite form (-ます)", "Basic verbs"],
                .a2: ["Past tense", "Te-form", "Adjectives"],
                .b1: ["Casual form", "Transitive/intransitive", "Conditionals"],
                .b2: ["Keigo basics", "Potential form", "Causative"],
                .c1: ["Advanced keigo", "Literary forms", "Classical grammar"],
                .c2: ["Complete mastery", "Ancient Japanese", "All registers"]
            ]
        default:
            // Basic progression for other languages
            let rulesPerLevel = max(1, allRules.count / 6)
            return [
                .a1: Array(allRules.prefix(rulesPerLevel)),
                .a2: Array(allRules.dropFirst(rulesPerLevel).prefix(rulesPerLevel)),
                .b1: Array(allRules.dropFirst(rulesPerLevel * 2).prefix(rulesPerLevel)),
                .b2: Array(allRules.dropFirst(rulesPerLevel * 3).prefix(rulesPerLevel)),
                .c1: Array(allRules.dropFirst(rulesPerLevel * 4).prefix(rulesPerLevel)),
                .c2: Array(allRules.dropFirst(rulesPerLevel * 5))
            ]
        }
    }

    func rulesForLevel(_ level: CEFRLevel) -> [String] {
        return progressionByLevel[level] ?? []
    }
}

/// Pronunciation system for language-specific phonetics and sound training
class PronunciationSystem {
    let language: Language
    let sounds: [String]
    let challenges: [String]

    init(language: Language, features: LanguageFeatures) {
        self.language = language
        self.sounds = features.pronunciation
        self.challenges = features.uniqueChallenges
    }

    func getDrillsForLevel(_ level: CEFRLevel) -> [PronunciationDrill] {
        var drills: [PronunciationDrill] = []

        for sound in sounds {
            let difficulty: DrillDifficulty
            switch level {
            case .a1, .a2: difficulty = .basic
            case .b1, .b2: difficulty = .intermediate
            case .c1, .c2: difficulty = .advanced
            }

            drills.append(PronunciationDrill(
                sound: sound,
                difficulty: difficulty,
                exercises: generateExercises(for: sound, level: level)
            ))
        }

        return drills
    }

    private func generateExercises(for sound: String, level: CEFRLevel) -> [String] {
        // This would be expanded with real exercises
        switch language {
        case .spanish where sound.contains("Rolling R"):
            return ["perro", "carro", "ferrocarril", "desarrollo"]
        case .french where sound.contains("Nasal"):
            return ["bon", "pain", "vin", "un"]
        case .mandarin where sound.contains("tone"):
            return ["mā", "má", "mǎ", "mà"]
        case .japanese where sound.contains("Pitch"):
            return ["はし (bridge)", "はし (chopsticks)", "あめ (rain)", "あめ (candy)"]
        default:
            return ["example1", "example2", "example3"]
        }
    }
}

struct PronunciationDrill {
    let sound: String
    let difficulty: DrillDifficulty
    let exercises: [String]
}

enum DrillDifficulty {
    case basic
    case intermediate
    case advanced
}

/// Cultural system for language-specific cultural context and norms
class CulturalSystem {
    let language: Language
    let contexts: [String]
    let scenarios: [CulturalScenario]

    init(language: Language, features: LanguageFeatures) {
        self.language = language
        self.contexts = features.culture
        self.scenarios = Self.buildScenarios(for: language, features: features)
    }

    private static func buildScenarios(for language: Language, features: LanguageFeatures) -> [CulturalScenario] {
        var scenarios: [CulturalScenario] = []

        switch language {
        case .spanish:
            scenarios = [
                CulturalScenario(
                    title: "Ordering Tapas",
                    description: "Learn how to order and share tapas in Spain",
                    culturalNotes: ["Tapas are shared", "Order multiple small dishes", "Common to stand at bar"],
                    vocabulary: ["tapa", "ración", "caña", "vino tinto"],
                    level: .a2
                ),
                CulturalScenario(
                    title: "Family Gathering",
                    description: "Navigate a traditional Spanish family meal",
                    culturalNotes: ["Late meal times", "Multiple courses", "Family is central"],
                    vocabulary: ["sobremesa", "familia", "abuelos", "comida"],
                    level: .b1
                )
            ]
        case .french:
            scenarios = [
                CulturalScenario(
                    title: "Café Culture",
                    description: "Order and enjoy coffee at a French café",
                    culturalNotes: ["Sitting costs more than standing", "Waiter won't rush you", "People-watching is normal"],
                    vocabulary: ["café", "terrasse", "garçon", "l'addition"],
                    level: .a2
                ),
                CulturalScenario(
                    title: "La Bise Greeting",
                    description: "Master the French cheek kiss greeting",
                    culturalNotes: ["Number varies by region", "2-4 kisses", "Not for formal situations"],
                    vocabulary: ["bise", "embrasser", "saluer", "bonjour"],
                    level: .a1
                )
            ]
        case .mandarin:
            scenarios = [
                CulturalScenario(
                    title: "Gift Giving",
                    description: "Navigate Chinese gift-giving etiquette",
                    culturalNotes: ["Refuse twice before accepting", "No clocks or sharp objects", "Red envelopes for money"],
                    vocabulary: ["礼物", "红包", "送礼", "谢谢"],
                    level: .b1
                ),
                CulturalScenario(
                    title: "Tea Culture",
                    description: "Participate in Chinese tea ceremony",
                    culturalNotes: ["Tap table to thank", "Oldest served first", "Many varieties"],
                    vocabulary: ["茶", "茶道", "功夫茶", "茶杯"],
                    level: .b2
                )
            ]
        case .japanese:
            scenarios = [
                CulturalScenario(
                    title: "Bowing Etiquette",
                    description: "Learn appropriate bowing for different situations",
                    culturalNotes: ["Deeper = more respect", "Business vs casual", "Never bow and shake hands"],
                    vocabulary: ["お辞儀", "会釈", "敬礼", "最敬礼"],
                    level: .a2
                ),
                CulturalScenario(
                    title: "Reading the Air (空気を読む)",
                    description: "Understand indirect communication",
                    culturalNotes: ["Avoid direct refusals", "Read context", "Harmony important"],
                    vocabulary: ["空気を読む", "遠慮", "気を使う", "察する"],
                    level: .c1
                )
            ]
        default:
            // Default scenarios for other languages
            scenarios = [
                CulturalScenario(
                    title: "Basic Greetings",
                    description: "Learn culturally appropriate greetings",
                    culturalNotes: features.culture.prefix(3).map { String($0) },
                    vocabulary: ["hello", "goodbye", "please", "thank you"],
                    level: .a1
                )
            ]
        }

        return scenarios
    }

    func scenariosForLevel(_ level: CEFRLevel) -> [CulturalScenario] {
        return scenarios.filter { $0.level == level }
    }
}

struct CulturalScenario: Identifiable, Codable {
    var id = UUID()
    let title: String
    let description: String
    let culturalNotes: [String]
    let vocabulary: [String]
    let level: CEFRLevel
}

// MARK: - Language Engine

/// Main language engine that coordinates all language-specific systems
class LanguageEngine {
    let language: Language
    let grammar: GrammarSystem
    let pronunciation: PronunciationSystem
    let culture: CulturalSystem
    let features: LanguageFeatures

    init(language: Language) {
        self.language = language
        let features = LanguageFeaturesFactory.features(for: language)
        self.features = features
        self.grammar = GrammarSystem(language: language, features: features)
        self.pronunciation = PronunciationSystem(language: language, features: features)
        self.culture = CulturalSystem(language: language, features: features)
    }

    /// Generate content based on type and level
    func generateContent(type: ContentGenerationType, level: CEFRLevel) async -> GeneratedContent {
        switch type {
        case .conversation:
            return await generateConversation(level: level)
        case .grammarLesson:
            return await generateGrammarLesson(level: level)
        case .pronunciationExercise:
            return await generatePronunciationExercise(level: level)
        case .culturalLesson:
            return await generateCulturalLesson(level: level)
        case .story:
            return await generateStory(level: level)
        case .vocabulary:
            return await generateVocabulary(level: level)
        }
    }

    private func generateConversation(level: CEFRLevel) async -> GeneratedContent {
        let culturalContext = culture.contexts.prefix(2).joined(separator: ", ")
        let grammarFocus = grammar.rulesForLevel(level).prefix(2).joined(separator: ", ")

        return GeneratedContent(
            type: .conversation,
            level: level,
            title: "Conversation Practice",
            content: "Conversation with focus on: \(grammarFocus)",
            metadata: [
                "cultural_context": culturalContext,
                "grammar_focus": grammarFocus
            ]
        )
    }

    private func generateGrammarLesson(level: CEFRLevel) async -> GeneratedContent {
        let rules = grammar.rulesForLevel(level)

        return GeneratedContent(
            type: .grammarLesson,
            level: level,
            title: "Grammar: \(rules.first ?? "Lesson")",
            content: "Grammar lesson focusing on: \(rules.joined(separator: ", "))",
            metadata: ["rules": rules.joined(separator: "|")]
        )
    }

    private func generatePronunciationExercise(level: CEFRLevel) async -> GeneratedContent {
        let drills = pronunciation.getDrillsForLevel(level)
        let firstDrill = drills.first

        return GeneratedContent(
            type: .pronunciationExercise,
            level: level,
            title: "Pronunciation: \(firstDrill?.sound ?? "Practice")",
            content: "Practice: \(firstDrill?.exercises.joined(separator: ", ") ?? "")",
            metadata: ["sound": firstDrill?.sound ?? ""]
        )
    }

    private func generateCulturalLesson(level: CEFRLevel) async -> GeneratedContent {
        let scenarios = culture.scenariosForLevel(level)
        let scenario = scenarios.first

        return GeneratedContent(
            type: .culturalLesson,
            level: level,
            title: scenario?.title ?? "Cultural Lesson",
            content: scenario?.description ?? "Cultural context for \(language.rawValue)",
            metadata: [
                "cultural_notes": scenario?.culturalNotes.joined(separator: "|") ?? "",
                "vocabulary": scenario?.vocabulary.joined(separator: "|") ?? ""
            ]
        )
    }

    private func generateStory(level: CEFRLevel) async -> GeneratedContent {
        return GeneratedContent(
            type: .story,
            level: level,
            title: "Story Reading",
            content: "A \(level.rawValue) level story in \(language.rawValue)",
            metadata: ["word_count": "200-300"]
        )
    }

    private func generateVocabulary(level: CEFRLevel) async -> GeneratedContent {
        return GeneratedContent(
            type: .vocabulary,
            level: level,
            title: "Vocabulary Set",
            content: "Vocabulary for \(level.rawValue) level",
            metadata: ["count": "20"]
        )
    }
}

enum ContentGenerationType {
    case conversation
    case grammarLesson
    case pronunciationExercise
    case culturalLesson
    case story
    case vocabulary
}

struct GeneratedContent: Identifiable, Codable {
    let id = UUID()
    let type: ContentGenerationType
    let level: CEFRLevel
    let title: String
    let content: String
    let metadata: [String: String]
    let createdAt = Date()

    enum CodingKeys: String, CodingKey {
        case id, level, title, content, metadata, createdAt
        case type
    }

    init(type: ContentGenerationType, level: CEFRLevel, title: String, content: String, metadata: [String: String]) {
        self.type = type
        self.level = level
        self.title = title
        self.content = content
        self.metadata = metadata
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let typeString = try container.decode(String.self, forKey: .type)

        switch typeString {
        case "conversation": type = .conversation
        case "grammarLesson": type = .grammarLesson
        case "pronunciationExercise": type = .pronunciationExercise
        case "culturalLesson": type = .culturalLesson
        case "story": type = .story
        case "vocabulary": type = .vocabulary
        default: type = .conversation
        }

        level = try container.decode(CEFRLevel.self, forKey: .level)
        title = try container.decode(String.self, forKey: .title)
        content = try container.decode(String.self, forKey: .content)
        metadata = try container.decode([String: String].self, forKey: .metadata)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        let typeString: String
        switch type {
        case .conversation: typeString = "conversation"
        case .grammarLesson: typeString = "grammarLesson"
        case .pronunciationExercise: typeString = "pronunciationExercise"
        case .culturalLesson: typeString = "culturalLesson"
        case .story: typeString = "story"
        case .vocabulary: typeString = "vocabulary"
        }

        try container.encode(typeString, forKey: .type)
        try container.encode(level, forKey: .level)
        try container.encode(title, forKey: .title)
        try container.encode(content, forKey: .content)
        try container.encode(metadata, forKey: .metadata)
    }
}
