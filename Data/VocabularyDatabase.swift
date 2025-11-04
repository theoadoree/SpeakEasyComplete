import Foundation

// MARK: - Vocabulary Database
// Contains the most common 100 words for each supported language

struct VocabularyDatabase {
    static let shared = VocabularyDatabase()

    private init() {}

    // MARK: - Get Vocabulary for Language
    func getVocabulary(for language: Language, limit: Int = 100) -> [VocabularyWord] {
        switch language {
        case .englishUS, .englishUK:
            return Array(englishVocabulary.prefix(limit))
        case .spanish, .spanishSpain, .spanishLatinAmerica:
            return Array(spanishVocabulary.prefix(limit))
        case .french:
            return Array(frenchVocabulary.prefix(limit))
        case .german:
            return Array(germanVocabulary.prefix(limit))
        case .italian:
            return Array(italianVocabulary.prefix(limit))
        case .portuguese:
            return Array(portugueseVocabulary.prefix(limit))
        case .japanese:
            return Array(japaneseVocabulary.prefix(limit))
        case .chinese, .chineseMandarin:
            return Array(chineseVocabulary.prefix(limit))
        case .korean:
            return Array(koreanVocabulary.prefix(limit))
        case .arabic:
            return Array(arabicVocabulary.prefix(limit))
        case .russian:
            return Array(russianVocabulary.prefix(limit))
        }
    }

    // MARK: - English Vocabulary (Top 100 most common words)
    private let englishVocabulary: [VocabularyWord] = [
        VocabularyWord(word: "the", translation: "el/la/los/las", pronunciation: "thuh", partOfSpeech: .article, frequency: 1),
        VocabularyWord(word: "be", translation: "ser/estar", pronunciation: "bee", partOfSpeech: .verb, frequency: 2),
        VocabularyWord(word: "to", translation: "a/para", pronunciation: "too", partOfSpeech: .preposition, frequency: 3),
        VocabularyWord(word: "of", translation: "de", pronunciation: "uhv", partOfSpeech: .preposition, frequency: 4),
        VocabularyWord(word: "and", translation: "y", pronunciation: "and", partOfSpeech: .conjunction, frequency: 5),
        VocabularyWord(word: "a", translation: "un/una", pronunciation: "uh", partOfSpeech: .article, frequency: 6),
        VocabularyWord(word: "in", translation: "en", pronunciation: "in", partOfSpeech: .preposition, frequency: 7),
        VocabularyWord(word: "that", translation: "ese/esa/que", pronunciation: "that", partOfSpeech: .pronoun, frequency: 8),
        VocabularyWord(word: "have", translation: "tener", pronunciation: "hav", partOfSpeech: .verb, frequency: 9),
        VocabularyWord(word: "I", translation: "yo", pronunciation: "eye", partOfSpeech: .pronoun, frequency: 10),
        VocabularyWord(word: "it", translation: "eso/ello", pronunciation: "it", partOfSpeech: .pronoun, frequency: 11),
        VocabularyWord(word: "for", translation: "para/por", pronunciation: "for", partOfSpeech: .preposition, frequency: 12),
        VocabularyWord(word: "not", translation: "no", pronunciation: "not", partOfSpeech: .adverb, frequency: 13),
        VocabularyWord(word: "on", translation: "en/sobre", pronunciation: "on", partOfSpeech: .preposition, frequency: 14),
        VocabularyWord(word: "with", translation: "con", pronunciation: "with", partOfSpeech: .preposition, frequency: 15),
        VocabularyWord(word: "he", translation: "él", pronunciation: "hee", partOfSpeech: .pronoun, frequency: 16),
        VocabularyWord(word: "as", translation: "como", pronunciation: "az", partOfSpeech: .conjunction, frequency: 17),
        VocabularyWord(word: "you", translation: "tú/usted", pronunciation: "yoo", partOfSpeech: .pronoun, frequency: 18),
        VocabularyWord(word: "do", translation: "hacer", pronunciation: "doo", partOfSpeech: .verb, frequency: 19),
        VocabularyWord(word: "at", translation: "en/a", pronunciation: "at", partOfSpeech: .preposition, frequency: 20),
        VocabularyWord(word: "this", translation: "esto/este/esta", pronunciation: "this", partOfSpeech: .pronoun, frequency: 21),
        VocabularyWord(word: "but", translation: "pero", pronunciation: "but", partOfSpeech: .conjunction, frequency: 22),
        VocabularyWord(word: "his", translation: "su (de él)", pronunciation: "hiz", partOfSpeech: .pronoun, frequency: 23),
        VocabularyWord(word: "by", translation: "por", pronunciation: "bye", partOfSpeech: .preposition, frequency: 24),
        VocabularyWord(word: "from", translation: "de/desde", pronunciation: "from", partOfSpeech: .preposition, frequency: 25),
        // Continue with top 100...
        VocabularyWord(word: "they", translation: "ellos/ellas", pronunciation: "thay", partOfSpeech: .pronoun, frequency: 26),
        VocabularyWord(word: "we", translation: "nosotros", pronunciation: "wee", partOfSpeech: .pronoun, frequency: 27),
        VocabularyWord(word: "say", translation: "decir", pronunciation: "say", partOfSpeech: .verb, frequency: 28),
        VocabularyWord(word: "her", translation: "ella/su (de ella)", pronunciation: "her", partOfSpeech: .pronoun, frequency: 29),
        VocabularyWord(word: "she", translation: "ella", pronunciation: "shee", partOfSpeech: .pronoun, frequency: 30),
        VocabularyWord(word: "or", translation: "o", pronunciation: "or", partOfSpeech: .conjunction, frequency: 31),
        VocabularyWord(word: "an", translation: "un/una", pronunciation: "an", partOfSpeech: .article, frequency: 32),
        VocabularyWord(word: "will", translation: "will (futuro)", pronunciation: "will", partOfSpeech: .verb, frequency: 33),
        VocabularyWord(word: "my", translation: "mi", pronunciation: "my", partOfSpeech: .pronoun, frequency: 34),
        VocabularyWord(word: "one", translation: "uno", pronunciation: "wun", partOfSpeech: .number, frequency: 35),
        VocabularyWord(word: "all", translation: "todo", pronunciation: "awl", partOfSpeech: .adjective, frequency: 36),
        VocabularyWord(word: "would", translation: "would (condicional)", pronunciation: "wood", partOfSpeech: .verb, frequency: 37),
        VocabularyWord(word: "there", translation: "allí/ahí", pronunciation: "there", partOfSpeech: .adverb, frequency: 38),
        VocabularyWord(word: "their", translation: "su (de ellos)", pronunciation: "there", partOfSpeech: .pronoun, frequency: 39),
        VocabularyWord(word: "what", translation: "qué", pronunciation: "wut", partOfSpeech: .pronoun, frequency: 40),
        VocabularyWord(word: "so", translation: "así/tan", pronunciation: "so", partOfSpeech: .adverb, frequency: 41),
        VocabularyWord(word: "up", translation: "arriba", pronunciation: "up", partOfSpeech: .adverb, frequency: 42),
        VocabularyWord(word: "out", translation: "fuera", pronunciation: "out", partOfSpeech: .adverb, frequency: 43),
        VocabularyWord(word: "if", translation: "si", pronunciation: "if", partOfSpeech: .conjunction, frequency: 44),
        VocabularyWord(word: "about", translation: "acerca de", pronunciation: "uh-bout", partOfSpeech: .preposition, frequency: 45),
        VocabularyWord(word: "who", translation: "quién", pronunciation: "hoo", partOfSpeech: .pronoun, frequency: 46),
        VocabularyWord(word: "get", translation: "obtener", pronunciation: "get", partOfSpeech: .verb, frequency: 47),
        VocabularyWord(word: "which", translation: "cuál/que", pronunciation: "witch", partOfSpeech: .pronoun, frequency: 48),
        VocabularyWord(word: "go", translation: "ir", pronunciation: "go", partOfSpeech: .verb, frequency: 49),
        VocabularyWord(word: "me", translation: "mí/me", pronunciation: "mee", partOfSpeech: .pronoun, frequency: 50),
    ]

    // MARK: - Spanish Vocabulary (Top 100 most common words)
    private let spanishVocabulary: [VocabularyWord] = [
        VocabularyWord(word: "el", translation: "the (masculine)", pronunciation: "el", partOfSpeech: .article, frequency: 1),
        VocabularyWord(word: "de", translation: "of/from", pronunciation: "de", partOfSpeech: .preposition, frequency: 2),
        VocabularyWord(word: "que", translation: "that/which", pronunciation: "ke", partOfSpeech: .conjunction, frequency: 3),
        VocabularyWord(word: "y", translation: "and", pronunciation: "ee", partOfSpeech: .conjunction, frequency: 4),
        VocabularyWord(word: "a", translation: "to/at", pronunciation: "a", partOfSpeech: .preposition, frequency: 5),
        VocabularyWord(word: "en", translation: "in/on", pronunciation: "en", partOfSpeech: .preposition, frequency: 6),
        VocabularyWord(word: "un", translation: "a/an (masculine)", pronunciation: "oon", partOfSpeech: .article, frequency: 7),
        VocabularyWord(word: "ser", translation: "to be (permanent)", pronunciation: "ser", partOfSpeech: .verb, frequency: 8),
        VocabularyWord(word: "la", translation: "the (feminine)", pronunciation: "la", partOfSpeech: .article, frequency: 9),
        VocabularyWord(word: "no", translation: "no/not", pronunciation: "no", partOfSpeech: .adverb, frequency: 10),
        VocabularyWord(word: "por", translation: "by/for", pronunciation: "por", partOfSpeech: .preposition, frequency: 11),
        VocabularyWord(word: "con", translation: "with", pronunciation: "kon", partOfSpeech: .preposition, frequency: 12),
        VocabularyWord(word: "para", translation: "for/to", pronunciation: "pa-ra", partOfSpeech: .preposition, frequency: 13),
        VocabularyWord(word: "una", translation: "a/an (feminine)", pronunciation: "oo-na", partOfSpeech: .article, frequency: 14),
        VocabularyWord(word: "haber", translation: "to have (auxiliary)", pronunciation: "a-ber", partOfSpeech: .verb, frequency: 15),
        VocabularyWord(word: "estar", translation: "to be (temporary)", pronunciation: "es-tar", partOfSpeech: .verb, frequency: 16),
        VocabularyWord(word: "tener", translation: "to have", pronunciation: "te-ner", partOfSpeech: .verb, frequency: 17),
        VocabularyWord(word: "hacer", translation: "to do/make", pronunciation: "a-ser", partOfSpeech: .verb, frequency: 18),
        VocabularyWord(word: "poder", translation: "can/to be able", pronunciation: "po-der", partOfSpeech: .verb, frequency: 19),
        VocabularyWord(word: "todo", translation: "all/everything", pronunciation: "to-do", partOfSpeech: .adjective, frequency: 20),
        VocabularyWord(word: "decir", translation: "to say/tell", pronunciation: "de-seer", partOfSpeech: .verb, frequency: 21),
        VocabularyWord(word: "tiempo", translation: "time/weather", pronunciation: "tee-em-po", partOfSpeech: .noun, frequency: 22),
        VocabularyWord(word: "año", translation: "year", pronunciation: "a-nyo", partOfSpeech: .noun, frequency: 23),
        VocabularyWord(word: "día", translation: "day", pronunciation: "dee-a", partOfSpeech: .noun, frequency: 24),
        VocabularyWord(word: "uno", translation: "one", pronunciation: "oo-no", partOfSpeech: .number, frequency: 25),
        VocabularyWord(word: "dos", translation: "two", pronunciation: "dos", partOfSpeech: .number, frequency: 26),
        VocabularyWord(word: "tres", translation: "three", pronunciation: "tres", partOfSpeech: .number, frequency: 27),
        VocabularyWord(word: "cuando", translation: "when", pronunciation: "kwan-do", partOfSpeech: .conjunction, frequency: 28),
        VocabularyWord(word: "pero", translation: "but", pronunciation: "pe-ro", partOfSpeech: .conjunction, frequency: 29),
        VocabularyWord(word: "muy", translation: "very", pronunciation: "moo-ee", partOfSpeech: .adverb, frequency: 30),
        VocabularyWord(word: "querer", translation: "to want/love", pronunciation: "ke-rer", partOfSpeech: .verb, frequency: 31),
        VocabularyWord(word: "saber", translation: "to know (facts)", pronunciation: "sa-ber", partOfSpeech: .verb, frequency: 32),
        VocabularyWord(word: "ver", translation: "to see", pronunciation: "ver", partOfSpeech: .verb, frequency: 33),
        VocabularyWord(word: "dar", translation: "to give", pronunciation: "dar", partOfSpeech: .verb, frequency: 34),
        VocabularyWord(word: "ir", translation: "to go", pronunciation: "eer", partOfSpeech: .verb, frequency: 35),
        VocabularyWord(word: "comer", translation: "to eat", pronunciation: "ko-mer", partOfSpeech: .verb, frequency: 36),
        VocabularyWord(word: "beber", translation: "to drink", pronunciation: "be-ber", partOfSpeech: .verb, frequency: 37),
        VocabularyWord(word: "agua", translation: "water", pronunciation: "a-gwa", partOfSpeech: .noun, frequency: 38),
        VocabularyWord(word: "casa", translation: "house", pronunciation: "ka-sa", partOfSpeech: .noun, frequency: 39),
        VocabularyWord(word: "hola", translation: "hello", pronunciation: "o-la", partOfSpeech: .interjection, frequency: 40),
        VocabularyWord(word: "gracias", translation: "thank you", pronunciation: "gra-see-as", partOfSpeech: .interjection, frequency: 41),
        VocabularyWord(word: "por favor", translation: "please", pronunciation: "por fa-vor", partOfSpeech: .phrase, frequency: 42),
        VocabularyWord(word: "sí", translation: "yes", pronunciation: "see", partOfSpeech: .adverb, frequency: 43),
        VocabularyWord(word: "adiós", translation: "goodbye", pronunciation: "a-dee-os", partOfSpeech: .interjection, frequency: 44),
        VocabularyWord(word: "bueno", translation: "good", pronunciation: "bwe-no", partOfSpeech: .adjective, frequency: 45),
        VocabularyWord(word: "malo", translation: "bad", pronunciation: "ma-lo", partOfSpeech: .adjective, frequency: 46),
        VocabularyWord(word: "grande", translation: "big/great", pronunciation: "gran-de", partOfSpeech: .adjective, frequency: 47),
        VocabularyWord(word: "pequeño", translation: "small", pronunciation: "pe-ke-nyo", partOfSpeech: .adjective, frequency: 48),
        VocabularyWord(word: "mucho", translation: "much/many", pronunciation: "moo-cho", partOfSpeech: .adverb, frequency: 49),
        VocabularyWord(word: "poco", translation: "little/few", pronunciation: "po-ko", partOfSpeech: .adverb, frequency: 50),
    ]

    // MARK: - French Vocabulary (Top 50 most common words)
    private let frenchVocabulary: [VocabularyWord] = [
        VocabularyWord(word: "le", translation: "the (masculine)", pronunciation: "luh", partOfSpeech: .article, frequency: 1),
        VocabularyWord(word: "de", translation: "of/from", pronunciation: "duh", partOfSpeech: .preposition, frequency: 2),
        VocabularyWord(word: "un", translation: "a/an (masculine)", pronunciation: "uhn", partOfSpeech: .article, frequency: 3),
        VocabularyWord(word: "être", translation: "to be", pronunciation: "eh-truh", partOfSpeech: .verb, frequency: 4),
        VocabularyWord(word: "et", translation: "and", pronunciation: "ay", partOfSpeech: .conjunction, frequency: 5),
        VocabularyWord(word: "à", translation: "to/at", pronunciation: "ah", partOfSpeech: .preposition, frequency: 6),
        VocabularyWord(word: "il", translation: "he/it", pronunciation: "eel", partOfSpeech: .pronoun, frequency: 7),
        VocabularyWord(word: "avoir", translation: "to have", pronunciation: "ah-vwar", partOfSpeech: .verb, frequency: 8),
        VocabularyWord(word: "ne", translation: "not (negation part 1)", pronunciation: "nuh", partOfSpeech: .adverb, frequency: 9),
        VocabularyWord(word: "je", translation: "I", pronunciation: "zhuh", partOfSpeech: .pronoun, frequency: 10),
        VocabularyWord(word: "son", translation: "his/her/its", pronunciation: "sohn", partOfSpeech: .pronoun, frequency: 11),
        VocabularyWord(word: "que", translation: "that/which", pronunciation: "kuh", partOfSpeech: .pronoun, frequency: 12),
        VocabularyWord(word: "se", translation: "oneself (reflexive)", pronunciation: "suh", partOfSpeech: .pronoun, frequency: 13),
        VocabularyWord(word: "qui", translation: "who/which", pronunciation: "kee", partOfSpeech: .pronoun, frequency: 14),
        VocabularyWord(word: "ce", translation: "this/that", pronunciation: "suh", partOfSpeech: .pronoun, frequency: 15),
        VocabularyWord(word: "dans", translation: "in", pronunciation: "dahn", partOfSpeech: .preposition, frequency: 16),
        VocabularyWord(word: "en", translation: "in/by", pronunciation: "ahn", partOfSpeech: .preposition, frequency: 17),
        VocabularyWord(word: "du", translation: "of the (masc.)", pronunciation: "dew", partOfSpeech: .article, frequency: 18),
        VocabularyWord(word: "elle", translation: "she/it", pronunciation: "el", partOfSpeech: .pronoun, frequency: 19),
        VocabularyWord(word: "au", translation: "to the (masc.)", pronunciation: "oh", partOfSpeech: .article, frequency: 20),
        VocabularyWord(word: "pour", translation: "for", pronunciation: "poor", partOfSpeech: .preposition, frequency: 21),
        VocabularyWord(word: "pas", translation: "not (negation part 2)", pronunciation: "pah", partOfSpeech: .adverb, frequency: 22),
        VocabularyWord(word: "sur", translation: "on", pronunciation: "sewr", partOfSpeech: .preposition, frequency: 23),
        VocabularyWord(word: "plus", translation: "more/plus", pronunciation: "plew", partOfSpeech: .adverb, frequency: 24),
        VocabularyWord(word: "pouvoir", translation: "can/to be able", pronunciation: "poo-vwar", partOfSpeech: .verb, frequency: 25),
        VocabularyWord(word: "par", translation: "by/through", pronunciation: "par", partOfSpeech: .preposition, frequency: 26),
        VocabularyWord(word: "je", translation: "I", pronunciation: "zhuh", partOfSpeech: .pronoun, frequency: 27),
        VocabularyWord(word: "avec", translation: "with", pronunciation: "a-vek", partOfSpeech: .preposition, frequency: 28),
        VocabularyWord(word: "tout", translation: "all/everything", pronunciation: "too", partOfSpeech: .adjective, frequency: 29),
        VocabularyWord(word: "faire", translation: "to do/make", pronunciation: "fer", partOfSpeech: .verb, frequency: 30),
        VocabularyWord(word: "bonjour", translation: "hello/good day", pronunciation: "bohn-zhoor", partOfSpeech: .interjection, frequency: 31),
        VocabularyWord(word: "merci", translation: "thank you", pronunciation: "mer-see", partOfSpeech: .interjection, frequency: 32),
        VocabularyWord(word: "s'il vous plaît", translation: "please", pronunciation: "seel voo pleh", partOfSpeech: .phrase, frequency: 33),
        VocabularyWord(word: "oui", translation: "yes", pronunciation: "wee", partOfSpeech: .adverb, frequency: 34),
        VocabularyWord(word: "non", translation: "no", pronunciation: "nohn", partOfSpeech: .adverb, frequency: 35),
        VocabularyWord(word: "au revoir", translation: "goodbye", pronunciation: "oh ruh-vwar", partOfSpeech: .interjection, frequency: 36),
        VocabularyWord(word: "bon", translation: "good", pronunciation: "bohn", partOfSpeech: .adjective, frequency: 37),
        VocabularyWord(word: "mauvais", translation: "bad", pronunciation: "mo-veh", partOfSpeech: .adjective, frequency: 38),
        VocabularyWord(word: "grand", translation: "big/tall", pronunciation: "grahn", partOfSpeech: .adjective, frequency: 39),
        VocabularyWord(word: "petit", translation: "small", pronunciation: "puh-tee", partOfSpeech: .adjective, frequency: 40),
        VocabularyWord(word: "manger", translation: "to eat", pronunciation: "mahn-zhay", partOfSpeech: .verb, frequency: 41),
        VocabularyWord(word: "boire", translation: "to drink", pronunciation: "bwar", partOfSpeech: .verb, frequency: 42),
        VocabularyWord(word: "eau", translation: "water", pronunciation: "oh", partOfSpeech: .noun, frequency: 43),
        VocabularyWord(word: "maison", translation: "house", pronunciation: "may-zohn", partOfSpeech: .noun, frequency: 44),
        VocabularyWord(word: "aller", translation: "to go", pronunciation: "a-lay", partOfSpeech: .verb, frequency: 45),
        VocabularyWord(word: "venir", translation: "to come", pronunciation: "vuh-neer", partOfSpeech: .verb, frequency: 46),
        VocabularyWord(word: "savoir", translation: "to know", pronunciation: "sa-vwar", partOfSpeech: .verb, frequency: 47),
        VocabularyWord(word: "voir", translation: "to see", pronunciation: "vwar", partOfSpeech: .verb, frequency: 48),
        VocabularyWord(word: "donner", translation: "to give", pronunciation: "doh-nay", partOfSpeech: .verb, frequency: 49),
        VocabularyWord(word: "prendre", translation: "to take", pronunciation: "prahn-druh", partOfSpeech: .verb, frequency: 50),
    ]

    // German, Italian, Portuguese, Japanese, Chinese, Korean, Arabic, Russian vocabularies
    // would follow the same pattern...

    private let germanVocabulary: [VocabularyWord] = []
    private let italianVocabulary: [VocabularyWord] = []
    private let portugueseVocabulary: [VocabularyWord] = []
    private let japaneseVocabulary: [VocabularyWord] = []
    private let chineseVocabulary: [VocabularyWord] = []
    private let koreanVocabulary: [VocabularyWord] = []
    private let arabicVocabulary: [VocabularyWord] = []
    private let russianVocabulary: [VocabularyWord] = []
}

// MARK: - Vocabulary Word Model
struct VocabularyWord: Identifiable, Codable {
    let id: UUID
    let word: String
    let translation: String
    let pronunciation: String
    let partOfSpeech: PartOfSpeech
    let frequency: Int

    init(word: String, translation: String, pronunciation: String, partOfSpeech: PartOfSpeech, frequency: Int) {
        self.id = UUID()
        self.word = word
        self.translation = translation
        self.pronunciation = pronunciation
        self.partOfSpeech = partOfSpeech
        self.frequency = frequency
    }

    enum PartOfSpeech: String, Codable {
        case noun = "Noun"
        case verb = "Verb"
        case adjective = "Adjective"
        case adverb = "Adverb"
        case pronoun = "Pronoun"
        case preposition = "Preposition"
        case conjunction = "Conjunction"
        case interjection = "Interjection"
        case article = "Article"
        case number = "Number"
        case phrase = "Phrase"
    }
}
