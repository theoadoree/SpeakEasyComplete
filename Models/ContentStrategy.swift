import Foundation

// MARK: - Content Type Definitions
enum ContentType {
    case universal          // 20% - Same structure, any language
    case templateBased      // 50% - Adaptable templates
    case languageSpecific   // 30% - Unique to each language
}

enum CEFRLevel: String, Codable, CaseIterable {
    case a1 = "A1"
    case a2 = "A2"
    case b1 = "B1"
    case b2 = "B2"
    case c1 = "C1"
    case c2 = "C2"

    var description: String {
        switch self {
        case .a1: return "Beginner"
        case .a2: return "Elementary"
        case .b1: return "Intermediate"
        case .b2: return "Upper Intermediate"
        case .c1: return "Advanced"
        case .c2: return "Mastery"
        }
    }
}

enum Language: String, Codable, CaseIterable {
    case spanish = "Spanish"
    case french = "French"
    case german = "German"
    case italian = "Italian"
    case portuguese = "Portuguese"
    case mandarin = "Mandarin"
    case japanese = "Japanese"
    case korean = "Korean"
    case arabic = "Arabic"
    case russian = "Russian"

    var code: String {
        switch self {
        case .spanish: return "es"
        case .french: return "fr"
        case .german: return "de"
        case .italian: return "it"
        case .portuguese: return "pt"
        case .mandarin: return "zh"
        case .japanese: return "ja"
        case .korean: return "ko"
        case .arabic: return "ar"
        case .russian: return "ru"
        }
    }

    var flag: String {
        switch self {
        case .spanish: return "🇪🇸"
        case .french: return "🇫🇷"
        case .german: return "🇩🇪"
        case .italian: return "🇮🇹"
        case .portuguese: return "🇵🇹"
        case .mandarin: return "🇨🇳"
        case .japanese: return "🇯🇵"
        case .korean: return "🇰🇷"
        case .arabic: return "🇸🇦"
        case .russian: return "🇷🇺"
        }
    }

    var languageFamily: LanguageFamily {
        switch self {
        case .spanish, .french, .italian, .portuguese:
            return .romance
        case .german:
            return .germanic
        case .mandarin, .japanese, .korean:
            return .asian
        case .arabic:
            return .semitic
        case .russian:
            return .slavic
        }
    }
}

enum LanguageFamily {
    case romance
    case germanic
    case asian
    case semitic
    case slavic

    var contentReusePercentage: Int {
        switch self {
        case .romance: return 60
        case .germanic: return 50
        case .asian: return 20
        case .semitic: return 30
        case .slavic: return 40
        }
    }
}

// MARK: - Universal Content
struct UniversalContent {
    static let srsAlgorithm = "Universal SRS"
    static let gamificationLogic = "Points, streaks, badges"
    static let levelingSystem = "A1-C2 CEFR framework"

    static let commonSituations = [
        "Greetings",
        "Numbers 1-100",
        "Days of the week",
        "Months of the year",
        "Colors",
        "Family members",
        "Basic directions",
        "Weather",
        "Time telling",
        "Food items"
    ]

    static let pictureVocabulary = "Universal images with language-specific labels"
    static let iconBasedUI = "Universal symbols and icons"
}

// MARK: - Language Features Protocol
protocol LanguageFeatures {
    var grammar: [String] { get }
    var pronunciation: [String] { get }
    var culture: [String] { get }
    var writing: [String]? { get }
    var uniqueChallenges: [String] { get }
    var dialects: [String: [String]]? { get }
}

// MARK: - Spanish Features
struct SpanishFeatures: LanguageFeatures {
    let grammar = [
        "Ser vs Estar",
        "Subjunctive mood",
        "Gender agreement",
        "Reflexive verbs",
        "Preterite vs Imperfect",
        "Por vs Para",
        "Direct/Indirect object pronouns"
    ]

    let pronunciation = [
        "Rolling R (trilled)",
        "LL variations by region",
        "Regional accents",
        "Vowel sounds (pure)",
        "Silent H",
        "Ñ sound"
    ]

    let culture = [
        "Formal/informal (tú/usted/vos)",
        "Meal times (late dinners)",
        "Gestures and expressions",
        "Siesta culture",
        "Family importance",
        "Regional diversity"
    ]

    let writing: [String]? = [
        "Accent marks (á, é, í, ó, ú)",
        "Upside-down punctuation (¿?¡!)",
        "Ñ letter"
    ]

    let uniqueChallenges = [
        "Subjunctive triggers",
        "Verb conjugation complexity",
        "Regional vocabulary differences",
        "Speed of native speakers"
    ]

    let dialects: [String: [String]]? = [
        "Spain": ["vosotros form", "ceceo/seseo", "different vocabulary"],
        "Mexico": ["no vosotros", "specific slang", "indigenous influences"],
        "Argentina": ["vos form", "ll/y pronunciation", "lunfardo slang"],
        "Caribbean": ["dropped S sounds", "unique vocabulary", "faster pace"]
    ]
}

// MARK: - French Features
struct FrenchFeatures: LanguageFeatures {
    let grammar = [
        "Gender (le/la)",
        "Liaison rules",
        "Subjunctive mood",
        "Past tense complexity (passé composé/imparfait)",
        "Partitive articles",
        "Y and EN pronouns",
        "Formal/informal (tu/vous)"
    ]

    let pronunciation = [
        "Nasal vowels (on, an, in, un)",
        "Silent letters (abundant)",
        "R sound (uvular)",
        "Liaison rules",
        "Elision rules",
        "Accent marks affect sound"
    ]

    let culture = [
        "Tu/Vous distinction",
        "Bise greeting (cheek kisses)",
        "Meal etiquette",
        "Café culture",
        "Art and literature appreciation",
        "Regional pride"
    ]

    let writing: [String]? = [
        "Accent marks (é, è, ê, ë, à, etc.)",
        "Ç cedilla",
        "Silent letters"
    ]

    let uniqueChallenges = [
        "Silent letters everywhere",
        "Nous vs On usage",
        "Complex verb conjugations",
        "Gender memorization",
        "Liaison when to apply"
    ]

    let dialects: [String: [String]]? = [
        "Parisian": ["Standard French", "dropped ne in negation", "specific slang"],
        "Quebec": ["Different vocabulary", "unique expressions", "pronunciation differences"],
        "Belgian": ["Septante/nonante for 70/90", "vocabulary variations"],
        "Swiss": ["Septante/huitante/nonante", "more formal"]
    ]
}

// MARK: - Mandarin Features
struct MandarinFeatures: LanguageFeatures {
    let grammar = [
        "Measure words (classifiers)",
        "Aspect markers (了, 过, 着)",
        "Topic-comment structure",
        "Serial verb construction",
        "No verb conjugation",
        "Time words (no tenses)",
        "Sentence particles"
    ]

    let pronunciation = [
        "Four tones (plus neutral)",
        "Tone sandhi rules",
        "Retroflex sounds (zh, ch, sh)",
        "Pinyin system",
        "Initial and final sounds",
        "Tone pair practice"
    ]

    let culture = [
        "Honorifics and titles",
        "Face concept (面子)",
        "Number symbolism",
        "Tea culture",
        "Gift giving etiquette",
        "Indirect communication"
    ]

    let writing: [String]? = [
        "Character stroke order",
        "Radicals (部首)",
        "Simplified vs Traditional",
        "Pinyin romanization",
        "Character composition",
        "HSK levels progression"
    ]

    let uniqueChallenges = [
        "Tone mastery critical",
        "Character memorization",
        "No phonetic alphabet",
        "Context-dependent meaning",
        "Measure word selection"
    ]

    let dialects: [String: [String]]? = [
        "Mandarin": ["Standard Beijing", "Putonghua", "official language"],
        "Cantonese": ["9 tones", "different vocabulary", "Hong Kong/Guangdong"],
        "Regional": ["Sichuan", "Dongbei", "pronunciation variations"]
    ]
}

// MARK: - Japanese Features
struct JapaneseFeatures: LanguageFeatures {
    let grammar = [
        "Particles (は、が、を、に、で、etc.)",
        "Verb conjugations (polite/plain)",
        "Keigo (politeness levels)",
        "Counters/classifiers",
        "SOV word order",
        "Relative clauses",
        "Transitive/intransitive verb pairs"
    ]

    let pronunciation = [
        "Pitch accent",
        "Long vowels (critical)",
        "Gemination (double consonants)",
        "R/L sound (neither)",
        "Rhythm (mora-timed)",
        "Intonation patterns"
    ]

    let culture = [
        "Bowing etiquette",
        "Indirect communication (空気を読む)",
        "Seasonal awareness",
        "Gift wrapping importance",
        "Removing shoes",
        "Hierarchical relationships"
    ]

    let writing: [String]? = [
        "Hiragana (46 characters)",
        "Katakana (46 characters)",
        "Kanji (2000+ for literacy)",
        "Romaji (romanization)",
        "Vertical/horizontal writing",
        "Okurigana usage"
    ]

    let uniqueChallenges = [
        "Three writing systems",
        "Politeness level selection",
        "Particle usage mastery",
        "Kanji reading (multiple readings)",
        "Counters for different objects"
    ]

    let dialects: [String: [String]]? = [
        "Tokyo": ["Standard dialect", "pitch accent", "basis for standard Japanese"],
        "Kansai": ["Different pitch", "unique vocabulary", "Osaka/Kyoto"],
        "Kyushu": ["Hakata-ben", "pronunciation differences"]
    ]
}

// MARK: - Language Features Factory
struct LanguageFeaturesFactory {
    static func features(for language: Language) -> LanguageFeatures {
        switch language {
        case .spanish:
            return SpanishFeatures()
        case .french:
            return FrenchFeatures()
        case .mandarin:
            return MandarinFeatures()
        case .japanese:
            return JapaneseFeatures()
        case .german:
            return GermanFeatures()
        case .italian:
            return ItalianFeatures()
        case .portuguese:
            return PortugueseFeatures()
        case .korean:
            return KoreanFeatures()
        case .arabic:
            return ArabicFeatures()
        case .russian:
            return RussianFeatures()
        }
    }
}

// MARK: - Additional Language Features (Basic implementations)
struct GermanFeatures: LanguageFeatures {
    let grammar = ["Cases (Nominativ, Akkusativ, Dativ, Genitiv)", "Gender (der/die/das)", "Verb-second word order", "Separable verbs", "Compound words"]
    let pronunciation = ["Umlauts (ä, ö, ü)", "ß (eszett)", "CH sound", "R sound (uvular)"]
    let culture = ["Punctuality", "Directness", "Formality (Sie/du)", "Beer culture", "Efficiency valued"]
    let writing: [String]? = ["Umlauts", "ß character", "All nouns capitalized"]
    let uniqueChallenges = ["Case system mastery", "Gender memorization", "Long compound words", "Adjective endings"]
    let dialects: [String: [String]]? = ["Standard": ["Hochdeutsch"], "Swiss": ["Swiss German differs significantly"], "Austrian": ["Different vocabulary"]]
}

struct ItalianFeatures: LanguageFeatures {
    let grammar = ["Gender agreement", "Verb conjugations", "Subjunctive mood", "Prepositions contract"]
    let pronunciation = ["Double consonants critical", "Open/closed vowels", "GL sound", "GN sound"]
    let culture = ["Hand gestures", "Family importance", "Food culture", "Passionate communication"]
    let writing: [String]? = ["Accent marks (à, è, é, ì, ò, ù)"]
    let uniqueChallenges = ["Verb conjugation complexity", "Preposition + article contractions", "Regional variations"]
    let dialects: [String: [String]]? = ["Standard": ["Tuscan-based"], "Regional": ["Sicilian, Neapolitan, Venetian"]]
}

struct PortugueseFeatures: LanguageFeatures {
    let grammar = ["Gender agreement", "Personal infinitive", "Subjunctive mood", "Verb conjugations"]
    let pronunciation = ["Nasal vowels", "Ão sound", "LH sound", "NH sound", "R sounds (multiple)"]
    let culture = ["Informal culture", "Family bonds", "Saudade concept", "Beach culture"]
    let writing: [String]? = ["Accent marks (á, â, ã, à, ç, etc.)", "Tilde on vowels"]
    let uniqueChallenges = ["Nasal sounds", "European vs Brazilian differences", "Verb conjugation complexity"]
    let dialects: [String: [String]]? = ["Brazilian": ["Different pronunciation", "você common"], "European": ["More formal", "different vocabulary"]]
}

struct KoreanFeatures: LanguageFeatures {
    let grammar = ["Honorifics system", "Subject-Object-Verb order", "Particles", "Verb conjugations", "Politeness levels"]
    let pronunciation = ["Consonant tension", "Final consonants unreleased", "Vowel combinations"]
    let culture = ["Age hierarchy", "Bowing culture", "Removing shoes", "Chopstick etiquette"]
    let writing: [String]? = ["Hangul alphabet (24 letters)", "Syllabic blocks", "Hanja (Chinese characters, rare)"]
    let uniqueChallenges = ["Honorific system complexity", "Pronunciation subtleties", "Konglish (English loanwords)"]
    let dialects: [String: [String]]? = ["Seoul": ["Standard Korean"], "Busan": ["Satoori dialect"]]
}

struct ArabicFeatures: LanguageFeatures {
    let grammar = ["Root system (trilateral)", "Verb patterns", "Dual number", "Gender agreement", "VSO word order"]
    let pronunciation = ["Emphatic consonants", "Pharyngeal sounds", "Short/long vowels", "Glottal stop"]
    let culture = ["Right-to-left reading", "Islamic culture influence", "Hospitality", "Family importance"]
    let writing: [String]? = ["Arabic script", "Connected letters", "No vowel marks (usually)", "Right-to-left"]
    let uniqueChallenges = ["Root and pattern system", "Pronunciation of new sounds", "Dialect vs MSA gap", "Reading without vowels"]
    let dialects: [String: [String]]? = ["MSA": ["Modern Standard Arabic", "formal"], "Egyptian": ["Most understood"], "Levantine": ["Syria, Lebanon, Jordan"], "Gulf": ["Saudi, UAE"]]
}

struct RussianFeatures: LanguageFeatures {
    let grammar = ["Cases (6 cases)", "Aspect (perfective/imperfective)", "Gender", "Verbs of motion", "No articles"]
    let pronunciation = ["Palatalization (soft/hard)", "Vowel reduction", "Consonant clusters", "Stress-based"]
    let culture = ["Formality (ты/вы)", "Superstitions", "Literature importance", "Hospitality"]
    let writing: [String]? = ["Cyrillic alphabet", "Cursive different from print", "Hard/soft signs"]
    let uniqueChallenges = ["Case system", "Aspect mastery", "Verbs of motion", "Stress patterns unpredictable"]
    let dialects: [String: [String]]? = ["Moscow": ["Standard Russian"], "Regional": ["Slight variations"]]
}
