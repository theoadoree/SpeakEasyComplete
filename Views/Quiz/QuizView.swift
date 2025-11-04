import SwiftUI

struct QuizView: View {
    let quiz: Quiz
    @StateObject private var viewModel: QuizViewModel
    @Environment(\.presentationMode) var presentationMode

    init(quiz: Quiz) {
        self.quiz = quiz
        self._viewModel = StateObject(wrappedValue: QuizViewModel(quiz: quiz))
    }

    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header with teacher avatar
                QuizHeaderView(
                    quiz: quiz,
                    currentQuestion: viewModel.currentQuestionIndex + 1,
                    totalQuestions: quiz.questions.count,
                    timeRemaining: viewModel.timeRemaining,
                    onClose: {
                        presentationMode.wrappedValue.dismiss()
                    }
                )

                ScrollView {
                    VStack(spacing: 24) {
                        // Teacher Avatar with encouragement
                        SpeakingTeacherAvatar(
                            message: viewModel.teacherMessage
                        )
                        .padding(.top)

                        // Question
                        if let currentQuestion = viewModel.currentQuestion {
                            QuizQuestionView(
                                question: currentQuestion,
                                selectedAnswer: viewModel.selectedAnswer,
                                isAnswered: viewModel.isAnswered,
                                onSelectAnswer: { answer in
                                    viewModel.selectAnswer(answer)
                                }
                            )
                            .padding(.horizontal)
                        }

                        // Action buttons
                        HStack(spacing: 12) {
                            if viewModel.currentQuestionIndex > 0 {
                                Button(action: viewModel.previousQuestion) {
                                    Label("Previous", systemImage: "chevron.left")
                                        .font(.headline)
                                        .foregroundColor(.blue)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background(Color.white)
                                        .cornerRadius(12)
                                }
                            }

                            Button(action: {
                                if viewModel.isLastQuestion {
                                    viewModel.submitQuiz()
                                } else {
                                    viewModel.nextQuestion()
                                }
                            }) {
                                Text(viewModel.isLastQuestion ? "Submit" : "Next")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(viewModel.selectedAnswer != nil ? Color.blue : Color.gray)
                                    .cornerRadius(12)
                            }
                            .disabled(viewModel.selectedAnswer == nil)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 32)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $viewModel.showResults) {
            QuizResultsView(
                quiz: quiz,
                result: viewModel.quizResult!,
                onRetry: {
                    viewModel.resetQuiz()
                },
                onClose: {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

// MARK: - Quiz Header
struct QuizHeaderView: View {
    let quiz: Quiz
    let currentQuestion: Int
    let totalQuestions: Int
    let timeRemaining: Int?
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.gray.opacity(0.6))
                }

                Spacer()

                VStack(spacing: 4) {
                    Text("\(currentQuestion) / \(totalQuestions)")
                        .font(.headline)
                    Text(quiz.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()

                if let timeRemaining = timeRemaining {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .foregroundColor(timeRemaining < 60 ? .red : .blue)
                        Text(formatTime(timeRemaining))
                            .font(.headline)
                            .foregroundColor(timeRemaining < 60 ? .red : .primary)
                    }
                } else {
                    Color.clear.frame(width: 80)
                }
            }
            .padding(.horizontal)
            .padding(.top)

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [.blue, .green],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geometry.size.width * CGFloat(currentQuestion) / CGFloat(totalQuestions),
                            height: 8
                        )
                }
            }
            .frame(height: 8)
            .padding(.horizontal)
        }
        .padding(.bottom, 8)
        .background(Color.white)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }

    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

// MARK: - Quiz Question View
struct QuizQuestionView: View {
    let question: QuizQuestion
    let selectedAnswer: String?
    let isAnswered: Bool
    let onSelectAnswer: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Question text
            Text(question.text)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            // Question type badge
            HStack {
                Image(systemName: questionTypeIcon)
                Text(question.type.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(.blue)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)

            // Options
            VStack(spacing: 12) {
                ForEach(question.options, id: \.self) { option in
                    QuizOptionButton(
                        option: option,
                        isSelected: selectedAnswer == option,
                        isCorrect: isAnswered && option == question.correctAnswer,
                        isIncorrect: isAnswered && selectedAnswer == option && option != question.correctAnswer,
                        onSelect: {
                            if !isAnswered {
                                onSelectAnswer(option)
                            }
                        }
                    )
                }
            }

            // Explanation (shown after answering)
            if isAnswered, let explanation = question.explanation {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.orange)
                        Text("Explanation")
                            .font(.headline)
                    }

                    Text(explanation)
                        .font(.body)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.1))
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
    }

    private var questionTypeIcon: String {
        switch question.type {
        case .multipleChoice: return "list.bullet.circle.fill"
        case .fillInBlank: return "text.cursor"
        case .translation: return "arrow.left.arrow.right"
        case .listening: return "ear.fill"
        case .matching: return "link"
        }
    }
}

// MARK: - Quiz Option Button
struct QuizOptionButton: View {
    let option: String
    let isSelected: Bool
    let isCorrect: Bool
    let isIncorrect: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack {
                Text(option)
                    .font(.body)
                    .foregroundColor(textColor)

                Spacer()

                if isCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else if isIncorrect {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                } else if isSelected {
                    Image(systemName: "circle.fill")
                        .foregroundColor(.blue)
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(backgroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var textColor: Color {
        if isCorrect { return .green }
        if isIncorrect { return .red }
        if isSelected { return .blue }
        return .primary
    }

    private var backgroundColor: Color {
        if isCorrect { return .green.opacity(0.1) }
        if isIncorrect { return .red.opacity(0.1) }
        if isSelected { return .blue.opacity(0.1) }
        return Color.white
    }

    private var borderColor: Color {
        if isCorrect { return .green }
        if isIncorrect { return .red }
        if isSelected { return .blue }
        return .gray.opacity(0.3)
    }
}

// MARK: - Quiz Results View
struct QuizResultsView: View {
    let quiz: Quiz
    let result: QuizResult
    let onRetry: () -> Void
    let onClose: () -> Void

    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()

            VStack(spacing: 32) {
                // Animated avatar with result emotion
                TeacherAvatar(
                    size: 120,
                    emotion: result.passed ? .excited : .encouraging
                )

                // Score display
                VStack(spacing: 16) {
                    Text(result.passed ? "Congratulations!" : "Keep Practicing!")
                        .font(.system(size: 32, weight: .bold))

                    Text("\(result.score)%")
                        .font(.system(size: 64, weight: .bold))
                        .foregroundColor(result.passed ? .green : .orange)

                    Text("\(result.correctAnswers) out of \(result.totalQuestions) correct")
                        .font(.headline)
                        .foregroundColor(.gray)
                }

                // Stats
                HStack(spacing: 32) {
                    ResultStat(
                        icon: "clock.fill",
                        label: "Time",
                        value: formatTime(Int(result.timeSpent))
                    )

                    ResultStat(
                        icon: "star.fill",
                        label: "Passing",
                        value: "\(quiz.passingScore)%"
                    )
                }

                // Action buttons
                VStack(spacing: 12) {
                    Button(action: onRetry) {
                        Text("Try Again")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }

                    Button(action: onClose) {
                        Text("Close")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 32)
            }
            .padding()
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

struct ResultStat: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.blue)

            Text(value)
                .font(.system(size: 20, weight: .bold))

            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    QuizView(quiz: QuizService.shared.generateQuiz(
        for: "Spanish",
        level: .beginner,
        category: .vocabulary
    ))
}
