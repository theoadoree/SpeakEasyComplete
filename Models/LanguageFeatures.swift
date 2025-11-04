import Foundation

// MARK: - Spanish Features
struct SpanishFeatures: LanguageFeatures {
    let language = Language.spanish

    let grammarChallenges = [
        "Ser vs Estar (to be)",
        "Subjunctive mood",
        "Gender agreement (el/la)",
        "Reflexive verbs",
        "Por vs Para",
        "Preterite vs Imperfect",
        "Direct/Indirect object pronouns"
    ]
    var grammar: [String] { grammarChallenges } // Alias

    let pronunciationChallenges = [
        "Rolling R (rr)",
        "Single R tap",
        "LL pronunciation",
        "Regional accent variations",
        "B vs V (same sound)",
        "H is silent",
        "J/G before e/i"
    ]
    var pronunciation: [String] { pronunciationChallenges } // Alias

    let culturalTopics = [
        "Formal/Informal address (tú/usted)",
        "Meal times and customs",
        "Siesta culture",
        "Family importance",
        "Gestures and body language",
        "Regional celebrations",
        "Food and tapas culture"
    ]
    var culture: [String] { culturalTopics } // Alias

    let uniqueFeatures = [
        "Double negative is correct",
        "Inverted question marks (¿?)",
        "Inverted exclamation marks (¡!)",
        "Diminutives (-ito/-ita)",
        "Gender affects adjectives"
    ]

    let commonMistakes = [
        "Using estar when ser is needed",
        "Forgetting gender agreement",
        "Incorrect subjunctive usage",
        "Confusing por and para",
        "Wrong reflexive pronoun",
        "False cognates (embarazada ≠ embarrassed)"
    ]
    var uniqueChallenges: [String] { commonMistakes } // Alias

    let writingSystems = [WritingSystem.latin]
    var writing: [String]? { ["Latin alphabet with accents (á, é, í, ó, ú, ñ)"] }

    let dialects = [
        Dialect(
            name: "Castilian Spanish",
            region: "Spain",
            features: ["θ sound for c/z", "vosotros form", "ceceo/seseo"],
            vocabulary: ["coche": "car", "ordenador": "computer"]
        ),
        Dialect(
            name: "Mexican Spanish",
            region: "Mexico",
            features: ["No vosotros", "Indigenous loanwords", "Distinct intonation"],
            vocabulary: ["carro": "car", "computadora": "computer"]
        ),
        Dialect(
            name: "Rioplatense Spanish",
            region: "Argentina/Uruguay",
            features: ["Vos instead of tú", "LL/Y as 'sh' sound", "Lunfardo slang"],
            vocabulary: ["auto": "car", "colectivo": "bus"]
        )
    ]
}

// MARK: - French Features
struct FrenchFeatures: LanguageFeatures {
    let language = Language.french

    let grammarChallenges = [
        "Gender (le/la) for all nouns",
        "Subjunctive mood",
        "Multiple past tenses",
        "Partitive articles (du/de la)",
        "Complex verb conjugations",
        "Pronoun placement",
        "Negation structures"
    ]
    var grammar: [String] { grammarChallenges }

    let pronunciationChallenges = [
        "Nasal vowels (an/en/in/on/un)",
        "Silent letters",
        "French R (uvular)",
        "Liaison rules",
        "Elision",
        "Accent marks affect sound",
        "U vs OU sounds"
    ]
    var pronunciation: [String] { pronunciationChallenges }

    let culturalTopics = [
        "Tu/Vous formality",
        "La bise greeting",
        "Meal etiquette",
        "Work-life balance",
        "Art and culture appreciation",
        "Café culture",
        "French administrative complexity"
    ]
    var culture: [String] { culturalTopics }

    let uniqueFeatures = [
        "Mandatory liaison in some contexts",
        "Silent final consonants",
        "Elision (l'ami not le ami)",
        "Multiple meanings based on context",
        "Compound past tense uses avoir or être"
    ]

    let commonMistakes = [
        "Wrong gender for nouns",
        "Incorrect liaison or elision",
        "Using present instead of subjunctive",
        "Wrong auxiliary verb (avoir vs être)",
        "Confusing similar sounds",
        "False friends (actuellement ≠ actually)"
    ]
    var uniqueChallenges: [String] { commonMistakes }

    let writingSystems = [WritingSystem.latin]
    var writing: [String]? { ["Latin alphabet with accents (à, è, é, ê, ë, ç, etc.)"] }
}

// MARK: - Mandarin Features
struct MandarinFeatures: LanguageFeatures {
    let language = Language.mandarin

    let grammarChallenges = [
        "Measure words (classifiers)",
        "Aspect markers (了/着/过)",
        "Topic-comment structure",
        "Serial verb construction",
        "No verb conjugation",
        "Time expressions",
        "Resultative complements"
    ]
    var grammar: [String] { grammarChallenges }

    let pronunciationChallenges = [
        "Four tones (1st, 2nd, 3rd, 4th)",
        "Neutral tone",
        "Tone sandhi rules",
        "Retroflex sounds (zh/ch/sh)",
        "Q vs CH distinction",
        "X vs SH distinction",
        "Final -n vs -ng"
    ]
    var pronunciation: [String] { pronunciationChallenges }

    let culturalTopics = [
        "Honorifics and respect",
        "Face (面子) concept",
        "Number symbolism (4=unlucky, 8=lucky)",
        "Gift-giving etiquette",
        "Tea culture",
        "Family hierarchy",
        "Red envelopes (红包)"
    ]
    var culture: [String] { culturalTopics }

    let uniqueFeatures = [
        "Characters represent meaning + sound",
        "Same pronunciation, different tones = different meanings",
        "No alphabet, character-based",
        "Radicals build characters",
        "Grammar through word order, not inflection"
    ]

    let commonMistakes = [
        "Wrong tone on words",
        "Confusing similar sounds",
        "Incorrect measure word",
        "Wrong word order",
        "Forgetting aspect markers",
        "Using 了 incorrectly"
    ]
    var uniqueChallenges: [String] { commonMistakes }

    let writingSystems = [WritingSystem.chinese]
    var writing: [String]? { [
        "Simplified Chinese (简体字)",
        "214 radicals",
        "Stroke order rules",
        "Character components"
    ] }

    let toneSystem = ToneSystem(
        numberOfTones: 4,
        toneDescriptions: [
            "1st Tone: High level (mā)",
            "2nd Tone: Rising (má)",
            "3rd Tone: Dipping (mǎ)",
            "4th Tone: Falling (mà)"
        ],
        tonePairs: [
            "1+1": "Both high level",
            "3+3": "First becomes 2nd tone",
            "4+4": "Sharp-sharp, distinct"
        ]
    )

    let characterProgression = CharacterLearningSystem(
        startingRadicals: 214,
        basicCharacters: 500,
        intermediateCharacters: 2000,
        advancedCharacters: 5000,
        strokeOrder: [
            "Top to bottom",
            "Left to right",
            "Horizontal before vertical",
            "Outside before inside"
        ]
    )
}

// MARK: - Japanese Features
struct JapaneseFeatures: LanguageFeatures {
    let language = Language.japanese

    let grammarChallenges = [
        "Particles (は/が/を/に/で/へ/と)",
        "Verb conjugations",
        "Keigo (politeness levels)",
        "Counter words",
        "SOV word order",
        "Te-form complexity",
        "Transitive/Intransitive pairs"
    ]
    var grammar: [String] { grammarChallenges }

    let pronunciationChallenges = [
        "Pitch accent patterns",
        "Long vowels (ā/ō/ū)",
        "Double consonants (gemination)",
        "R sound (between R and L)",
        "Minimal sound inventory",
        "Mora timing",
        "N sound variations"
    ]
    var pronunciation: [String] { pronunciationChallenges }

    let culturalTopics = [
        "Bowing etiquette",
        "Indirect communication (空気を読む)",
        "Seasonal awareness",
        "Gift-giving customs",
        "Uchi-soto (in-group/out-group)",
        "Onsen culture",
        "Work hierarchy"
    ]
    var culture: [String] { culturalTopics }

    let uniqueFeatures = [
        "Three writing systems (hiragana/katakana/kanji)",
        "Multiple politeness levels",
        "No articles (a/the)",
        "Context-dependent pronouns",
        "Onomatopoeia richness",
        "Subject often omitted"
    ]

    let commonMistakes = [
        "Wrong particle usage",
        "Incorrect politeness level",
        "Confusing は and が",
        "Wrong counter word",
        "Missing context",
        "False friends from English"
    ]
    var uniqueChallenges: [String] { commonMistakes }

    let writingSystems = [WritingSystem.hiragana, WritingSystem.katakana, WritingSystem.kanji]
    var writing: [String]? { [
        "Hiragana (46 characters)",
        "Katakana (46 characters)",
        "Kanji (2000+ for fluency)",
        "Mixed script usage"
    ] }

    let writingSystemProgression = JapaneseWritingProgression(
        phase1: "Hiragana only (46 characters)",
        phase2: "Add Katakana (46 characters)",
        phase3: "Basic Kanji (N5: 100 kanji)",
        phase4: "Intermediate Kanji (N4: 300 kanji)",
        phase5: "Advanced Kanji (N1: 2000+ kanji)"
    )

    let politenessLevels = KeigoSystem(
        levels: [
            "Plain/Casual (だ/である)",
            "Polite (です/ます)",
            "Respectful (尊敬語)",
            "Humble (謙譲語)",
            "Beautification (美化語)"
        ]
    )
}

// MARK: - Supporting Structures
struct ToneSystem: Codable {
    let numberOfTones: Int
    let toneDescriptions: [String]
    let tonePairs: [String: String]
}

struct CharacterLearningSystem: Codable {
    let startingRadicals: Int
    let basicCharacters: Int
    let intermediateCharacters: Int
    let advancedCharacters: Int
    let strokeOrder: [String]
}

struct JapaneseWritingProgression: Codable {
    let phase1: String
    let phase2: String
    let phase3: String
    let phase4: String
    let phase5: String
}

struct KeigoSystem: Codable {
    let levels: [String]
}

// MARK: - Language Features Factory
class LanguageFeaturesFactory {
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
        default:
            // For now, return Spanish as default
            return SpanishFeatures()
        }
    }
}
