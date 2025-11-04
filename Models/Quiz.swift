import Foundation

// MARK: - Quiz Models

struct Quiz: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let language: String
    let level: DifficultyLevel
    let category: QuizCategory
    let questions: [QuizQuestion]
    let timeLimit: Int? // seconds, nil for no limit
    let passingScore: Int // percentage

    var duration: Int {
        questions.count * 60 // 1 minute per question estimate
    }
}

enum QuizCategory: String, Codable, CaseIterable {
    case vocabulary = "Vocabulary"
    case grammar = "Grammar"
    case listening = "Listening"
    case reading = "Reading"
    case comprehensive = "Comprehensive"

    var icon: String {
        switch self {
        case .vocabulary: return "book.fill"
        case .grammar: return "text.book.closed.fill"
        case .listening: return "ear.fill"
        case .reading: return "eyeglasses"
        case .comprehensive: return "star.fill"
        }
    }

    var color: String {
        switch self {
        case .vocabulary: return "purple"
        case .grammar: return "blue"
        case .listening: return "green"
        case .reading: return "orange"
        case .comprehensive: return "red"
        }
    }
}

// MARK: - Quiz Generation Service

class QuizService {
    static let shared = QuizService()

    private init() {}

    func generateQuiz(for language: String, level: DifficultyLevel, category: QuizCategory) -> Quiz {
        let questions = generateQuestions(language: language, level: level, category: category, count: 10)

        return Quiz(
            id: UUID(),
            title: "\(level.rawValue.capitalized) \(category.rawValue) Quiz",
            description: "Test your \(language) \(category.rawValue.lowercased()) skills",
            language: language,
            level: level,
            category: category,
            questions: questions,
            timeLimit: 600, // 10 minutes
            passingScore: 70
        )
    }

    private func generateQuestions(language: String, level: DifficultyLevel, category: QuizCategory, count: Int) -> [QuizQuestion] {
        var questions: [QuizQuestion] = []

        for i in 0..<count {
            let question = generateQuestion(
                index: i,
                language: language,
                level: level,
                category: category
            )
            questions.append(question)
        }

        return questions
    }

    private func generateQuestion(index: Int, language: String, level: DifficultyLevel, category: QuizCategory) -> QuizQuestion {
        switch category {
        case .vocabulary:
            return generateVocabularyQuestion(index: index, language: language, level: level)
        case .grammar:
            return generateGrammarQuestion(index: index, language: language, level: level)
        case .listening:
            return generateListeningQuestion(index: index, language: language, level: level)
        case .reading:
            return generateReadingQuestion(index: index, language: language, level: level)
        case .comprehensive:
            return generateComprehensiveQuestion(index: index, language: language, level: level)
        }
    }

    private func generateVocabularyQuestion(index: Int, language: String, level: DifficultyLevel) -> QuizQuestion {
        // Sample vocabulary questions for Spanish
        let spanishQuestions = [
            (text: "What is the Spanish word for 'hello'?", options: ["Hola", "Adiós", "Gracias", "Por favor"], correct: "Hola"),
            (text: "What does 'gracias' mean?", options: ["Please", "Thank you", "Goodbye", "Hello"], correct: "Thank you"),
            (text: "How do you say 'goodbye' in Spanish?", options: ["Hola", "Adiós", "Sí", "No"], correct: "Adiós"),
            (text: "What is 'por favor' in English?", options: ["Thank you", "Please", "You're welcome", "Excuse me"], correct: "Please"),
            (text: "What does 'agua' mean?", options: ["Water", "Food", "Fire", "Air"], correct: "Water"),
        ]

        let q = spanishQuestions[index % spanishQuestions.count]

        return QuizQuestion(
            id: UUID(),
            text: q.text,
            type: .multipleChoice,
            options: q.options,
            correctAnswer: q.correct,
            explanation: "This is a common \(language) word you'll use frequently.",
            audioURL: nil,
            imageURL: nil
        )
    }

    private func generateGrammarQuestion(index: Int, language: String, level: DifficultyLevel) -> QuizQuestion {
        let questions = [
            (text: "Which article is correct: ___ libro (the book)?", options: ["el", "la", "los", "las"], correct: "el"),
            (text: "Conjugate 'hablar' in first person: Yo ___", options: ["hablo", "hablas", "habla", "hablan"], correct: "hablo"),
            (text: "Which is the correct plural: casa → ___?", options: ["casas", "casaes", "casis", "casa"], correct: "casas"),
        ]

        let q = questions[index % questions.count]

        return QuizQuestion(
            id: UUID(),
            text: q.text,
            type: .multipleChoice,
            options: q.options,
            correctAnswer: q.correct,
            explanation: "Grammar rules are essential for proper \(language) communication.",
            audioURL: nil,
            imageURL: nil
        )
    }

    private func generateListeningQuestion(index: Int, language: String, level: DifficultyLevel) -> QuizQuestion {
        return QuizQuestion(
            id: UUID(),
            text: "Listen and select the correct response:",
            type: .listening,
            options: ["Buenos días", "Buenas tardes", "Buenas noches", "Hola"],
            correctAnswer: "Buenos días",
            explanation: "Listening comprehension helps you understand native speakers.",
            audioURL: "audio/question_\(index).mp3",
            imageURL: nil
        )
    }

    private func generateReadingQuestion(index: Int, language: String, level: DifficultyLevel) -> QuizQuestion {
        return QuizQuestion(
            id: UUID(),
            text: "Read the passage and answer: '¿Cómo está usted?' means:",
            type: .multipleChoice,
            options: ["How are you?", "What is your name?", "Where are you?", "What do you want?"],
            correctAnswer: "How are you?",
            explanation: "Reading comprehension is key to understanding written \(language).",
            audioURL: nil,
            imageURL: nil
        )
    }

    private func generateComprehensiveQuestion(index: Int, language: String, level: DifficultyLevel) -> QuizQuestion {
        return QuizQuestion(
            id: UUID(),
            text: "Translate: 'I speak Spanish'",
            type: .translation,
            options: ["Yo hablo español", "Tú hablas español", "Él habla español", "Nosotros hablamos español"],
            correctAnswer: "Yo hablo español",
            explanation: "Translation exercises combine vocabulary, grammar, and comprehension.",
            audioURL: nil,
            imageURL: nil
        )
    }

    func saveQuizResult(_ result: QuizResult) {
        // Save to UserDefaults or database
        if let data = try? JSONEncoder().encode(result) {
            let key = "quiz_result_\(result.id.uuidString)"
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func getQuizResults() -> [QuizResult] {
        // Load from UserDefaults
        let defaults = UserDefaults.standard
        let keys = defaults.dictionaryRepresentation().keys.filter { $0.hasPrefix("quiz_result_") }

        return keys.compactMap { key in
            guard let data = defaults.data(forKey: key),
                  let result = try? JSONDecoder().decode(QuizResult.self, from: data) else {
                return nil
            }
            return result
        }
    }
}
