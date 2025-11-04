import Foundation
import SwiftUI

@MainActor
class QuizViewModel: ObservableObject {
    @Published var currentQuestionIndex = 0
    @Published var selectedAnswer: String?
    @Published var isAnswered = false
    @Published var userAnswers: [QuizAnswer] = []
    @Published var showResults = false
    @Published var quizResult: QuizResult?
    @Published var timeRemaining: Int?
    @Published var teacherMessage = "Let's test your knowledge! 🎓"

    private let quiz: Quiz
    private let quizService = QuizService.shared
    private let notificationService = NotificationService.shared
    private var timer: Timer?
    private var startTime: Date?

    var currentQuestion: QuizQuestion? {
        guard currentQuestionIndex < quiz.questions.count else { return nil }
        return quiz.questions[currentQuestionIndex]
    }

    var isLastQuestion: Bool {
        currentQuestionIndex == quiz.questions.count - 1
    }

    init(quiz: Quiz) {
        self.quiz = quiz
        self.startTime = Date()

        // Set up timer if quiz has time limit
        if let timeLimit = quiz.timeLimit {
            self.timeRemaining = timeLimit * 60 // Convert minutes to seconds
            startTimer()
        }

        updateTeacherMessage()
    }

    // MARK: - Question Navigation

    func nextQuestion() {
        guard currentQuestionIndex < quiz.questions.count - 1 else { return }
        currentQuestionIndex += 1
        selectedAnswer = nil
        isAnswered = false
        updateTeacherMessage()
    }

    func previousQuestion() {
        guard currentQuestionIndex > 0 else { return }
        currentQuestionIndex -= 1

        // Check if this question was already answered
        if let previousAnswer = userAnswers.first(where: { $0.questionId == currentQuestion?.id }) {
            selectedAnswer = previousAnswer.userAnswer
            isAnswered = true
        } else {
            selectedAnswer = nil
            isAnswered = false
        }

        updateTeacherMessage()
    }

    // MARK: - Answer Selection

    func selectAnswer(_ answer: String) {
        guard !isAnswered else { return }

        selectedAnswer = answer
        isAnswered = true

        guard let question = currentQuestion else { return }

        let isCorrect = answer == question.correctAnswer
        let quizAnswer = QuizAnswer(
            questionId: question.id,
            userAnswer: answer,
            isCorrect: isCorrect,
            timeSpent: 0
        )

        // Remove any previous answer for this question
        userAnswers.removeAll { $0.questionId == question.id }
        userAnswers.append(quizAnswer)

        // Update teacher message based on answer
        if isCorrect {
            teacherMessage = "Excellent! That's correct! 🎉"
        } else {
            teacherMessage = "Not quite. Review the explanation below. 📚"
        }
    }

    // MARK: - Quiz Submission

    func submitQuiz() {
        timer?.invalidate()

        let correctAnswers = userAnswers.filter { $0.isCorrect }.count
        let score = Int((Double(correctAnswers) / Double(quiz.questions.count)) * 100)
        let timeSpent = Date().timeIntervalSince(startTime ?? Date())
        let passed = score >= quiz.passingScore

        let result = QuizResult(
            id: UUID(),
            quizId: quiz.id,
            score: score,
            correctAnswers: correctAnswers,
            totalQuestions: quiz.questions.count,
            timeSpent: timeSpent,
            answers: userAnswers,
            completedAt: Date()
        )

        self.quizResult = result
        quizService.saveQuizResult(result)

        // Send notification
        Task {
            await notificationService.sendQuizCompletionNotification(score: score, passed: passed)
        }

        // Update teacher message
        if passed {
            teacherMessage = "Congratulations! You passed with \(score)%! 🎉"
        } else {
            teacherMessage = "Keep practicing! You scored \(score)%. 💪"
        }

        showResults = true
    }

    // MARK: - Reset Quiz

    func resetQuiz() {
        currentQuestionIndex = 0
        selectedAnswer = nil
        isAnswered = false
        userAnswers.removeAll()
        showResults = false
        quizResult = nil
        startTime = Date()

        if let timeLimit = quiz.timeLimit {
            timeRemaining = timeLimit * 60
            startTimer()
        }

        updateTeacherMessage()
    }

    // MARK: - Timer

    private func startTimer() {
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            Task { @MainActor in
                if let remaining = self.timeRemaining {
                    if remaining > 0 {
                        self.timeRemaining = remaining - 1
                    } else {
                        // Time's up - auto submit
                        self.submitQuiz()
                    }
                }
            }
        }
    }

    // MARK: - Teacher Messages

    private func updateTeacherMessage() {
        let progress = Double(currentQuestionIndex + 1) / Double(quiz.questions.count)

        if currentQuestionIndex == 0 {
            teacherMessage = "Let's start! Take your time. 🎓"
        } else if progress < 0.25 {
            teacherMessage = "Great start! Keep going! 💪"
        } else if progress < 0.5 {
            teacherMessage = "You're doing well! 📚"
        } else if progress < 0.75 {
            teacherMessage = "More than halfway there! 🌟"
        } else if currentQuestionIndex == quiz.questions.count - 1 {
            teacherMessage = "Final question! You've got this! 🎯"
        } else {
            teacherMessage = "Almost done! Stay focused! ⭐"
        }
    }

    deinit {
        timer?.invalidate()
    }
}
