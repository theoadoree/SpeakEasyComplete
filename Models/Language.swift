import Foundation

enum Language: String, CaseIterable, Codable {
    // English variants (excluded from onboarding per user request)
    case englishUS = "English (US)"
    case englishUK = "English (UK)"

    // Spanish variants - with native names
    case spanishSpain = "Spanish (Spain) • Español"
    case spanishLatinAmerica = "Spanish (Latin America) • Español"
    case spanishCaribbean = "Spanish (Caribbean) • Español"

    // Portuguese variants - with native names
    case portugueseBrazil = "Portuguese (Brazil) • Português"
    case portuguesePortugal = "Portuguese (Portugal) • Português"

    // Chinese variants - with native names
    case chineseMandarin = "Chinese (Mandarin) • 中文"
    case chineseCantonese = "Chinese (Cantonese) • 粵語"

    // Other major languages - with native names
    case french = "French • Français"
    case german = "German • Deutsch"
    case italian = "Italian • Italiano"
    case japanese = "Japanese • 日本語"
    case korean = "Korean • 한국어"
    case arabic = "Arabic • العربية"
    case russian = "Russian • Русский"
    case hindi = "Hindi • हिन्दी"
    case dutch = "Dutch • Nederlands"
    case polish = "Polish • Polski"
    case turkish = "Turkish • Türkçe"
    case indonesian = "Indonesian • Bahasa Indonesia"

    // Legacy support - maps to default variants (not shown in UI)
    case spanish = "Spanish"
    case chinese = "Chinese"
    case portuguese = "Portuguese"

    var flag: String {
        switch self {
        case .englishUS: return "🇺🇸"
        case .englishUK: return "🇬🇧"
        case .spanishSpain, .spanish: return "🇪🇸"
        case .spanishLatinAmerica: return "🇦🇷"  // Argentina flag for Latin America
        case .spanishCaribbean: return "🇵🇷"  // Puerto Rico flag for Caribbean
        case .portugueseBrazil: return "🇧🇷"
        case .portuguesePortugal, .portuguese: return "🇵🇹"
        case .french: return "🇫🇷"
        case .german: return "🇩🇪"
        case .italian: return "🇮🇹"
        case .japanese: return "🇯🇵"
        case .chineseMandarin, .chinese: return "🇹🇼"  // Taiwan flag for Mandarin
        case .chineseCantonese: return "🇹🇼"  // Taiwan flag for Cantonese per user request
        case .korean: return "🇰🇷"
        case .arabic: return "🇸🇦"
        case .russian: return "🇷🇺"
        case .hindi: return "🇮🇳"
        case .dutch: return "🇳🇱"
        case .polish: return "🇵🇱"
        case .turkish: return "🇹🇷"
        case .indonesian: return "🇮🇩"
        }
    }

    var greeting: String {
        switch self {
        case .englishUS, .englishUK: return "Hello!"
        case .spanishSpain, .spanishLatinAmerica, .spanishCaribbean, .spanish: return "¡Hola!"
        case .portugueseBrazil, .portuguesePortugal, .portuguese: return "Olá!"
        case .chineseMandarin, .chineseCantonese, .chinese: return "你好!"
        case .french: return "Bonjour!"
        case .german: return "Guten Tag!"
        case .italian: return "Ciao!"
        case .japanese: return "こんにちは!"
        case .korean: return "안녕하세요!"
        case .arabic: return "مرحبا!"
        case .russian: return "Привет!"
        case .hindi: return "नमस्ते!"
        case .dutch: return "Hallo!"
        case .polish: return "Cześć!"
        case .turkish: return "Merhaba!"
        case .indonesian: return "Halo!"
        }
    }

    // OpenAI language code for API calls
    var apiLanguageCode: String {
        switch self {
        case .englishUS, .englishUK: return "English"
        case .spanishSpain, .spanishLatinAmerica, .spanishCaribbean, .spanish: return "Spanish"
        case .portugueseBrazil, .portuguesePortugal, .portuguese: return "Portuguese"
        case .chineseMandarin, .chineseCantonese, .chinese: return "Chinese"
        case .french: return "French"
        case .german: return "German"
        case .italian: return "Italian"
        case .japanese: return "Japanese"
        case .korean: return "Korean"
        case .arabic: return "Arabic"
        case .russian: return "Russian"
        case .hindi: return "Hindi"
        case .dutch: return "Dutch"
        case .polish: return "Polish"
        case .turkish: return "Turkish"
        case .indonesian: return "Indonesian"
        }
    }
}

// MARK: - Language Family
enum LanguageFamily: String, Codable {
    case romance
    case germanic
    case sinoTibetan
    case japonic

    var contentReusePercentage: Double {
        switch self {
        case .romance: return 0.60 // Romance languages share 60% content
        case .germanic: return 0.50 // Germanic languages share 50% content
        case .sinoTibetan: return 0.20 // Asian languages share 20% content
        case .japonic: return 0.20
        }
    }
}

// MARK: - CEFR Level
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

    var vocabularySize: Int {
        switch self {
        case .a1: return 500
        case .a2: return 1000
        case .b1: return 2000
        case .b2: return 4000
        case .c1: return 8000
        case .c2: return 16000
        }
    }
}

// MARK: - Content Type
enum ContentType: String, Codable {
    case universal
    case templateBased
    case languageSpecific

    var reusePercentage: Double {
        switch self {
        case .universal: return 1.0 // 100% reusable
        case .templateBased: return 0.5 // 50% reusable
        case .languageSpecific: return 0.0 // 0% reusable
        }
    }
}

// MARK: - Learning Content Type
enum LearningContentType: String, Codable {
    case conversation
    case grammar
    case pronunciation
    case vocabulary
    case reading
    case writing
    case culture
    case listening
}

// MARK: - Language Features Protocol
protocol LanguageFeatures {
    var language: Language { get }

    // Grammar
    var grammarChallenges: [String] { get }
    var grammar: [String] { get } // Alias for compatibility

    // Pronunciation
    var pronunciationChallenges: [String] { get }
    var pronunciation: [String] { get } // Alias for compatibility

    // Culture
    var culturalTopics: [String] { get }
    var culture: [String] { get } // Alias for compatibility

    // Unique features and challenges
    var uniqueFeatures: [String] { get }
    var commonMistakes: [String] { get }
    var uniqueChallenges: [String] { get } // Alias for compatibility

    // Writing systems
    var writingSystems: [WritingSystem] { get }
    var writing: [String]? { get } // Optional writing system descriptions
}

// MARK: - Writing System
enum WritingSystem: String, Codable {
    case latin
    case chinese
    case hiragana
    case katakana
    case kanji
    case cyrillic
    case arabic
    case devanagari
}

// MARK: - Dialect
struct Dialect: Codable {
    let name: String
    let region: String
    let features: [String]
    let vocabulary: [String: String] // Standard: Dialectal
}
