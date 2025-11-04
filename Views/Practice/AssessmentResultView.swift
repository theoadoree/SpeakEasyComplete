import SwiftUI

struct AssessmentResultView: View {
    let result: AssessmentResult
    let onDismiss: () -> Void

    @State private var showCheckmark = false

    var body: some View {
        ZStack {
            GradientBackground()

            VStack(spacing: 32) {
                Spacer()

                // Checkmark animation
                AnimatedCheckmark()
                    .frame(width: 100, height: 100)
                    .opacity(showCheckmark ? 1 : 0)
                    .scaleEffect(showCheckmark ? 1 : 0.5)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: showCheckmark)

                // Title
                VStack(spacing: 12) {
                    Text("Assessment Complete!")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("Your language level has been determined")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                }

                // Level badge
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 120, height: 120)

                        VStack(spacing: 4) {
                            Text(result.level.rawValue.uppercased())
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.white)

                            Text("Level")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }

                    Text(AssessmentService.shared.getLevelDescription(result.level))
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                // Feedback sections
                VStack(spacing: 20) {
                    // Strengths
                    if !result.strengths.isEmpty {
                        AssessmentFeedbackSection(
                            title: "Strengths",
                            icon: "star.fill",
                            items: result.strengths,
                            color: .green
                        )
                    }

                    // Areas for improvement
                    if !result.areasForImprovement.isEmpty {
                        AssessmentFeedbackSection(
                            title: "Areas to Improve",
                            icon: "chart.line.uptrend.xyaxis",
                            items: result.areasForImprovement,
                            color: .orange
                        )
                    }
                }
                .padding(.horizontal, 32)

                Spacer()

                // Continue button
                Button(action: onDismiss) {
                    Text("Continue Learning")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(Color.green)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showCheckmark = true
            }
        }
    }
}

// MARK: - Feedback Section
struct AssessmentFeedbackSection: View {
    let title: String
    let icon: String
    let items: [String]
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .foregroundColor(color.opacity(0.8))
                            .padding(.top, 6)

                        Text(item)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

#Preview {
    AssessmentResultView(
        result: AssessmentResult(
            level: .b1,
            score: 75,
            feedback: "Good progress!",
            strengths: [
                "Good vocabulary range",
                "Clear pronunciation",
                "Natural conversation flow"
            ],
            areasForImprovement: [
                "Work on past tense usage",
                "Practice more complex sentence structures"
            ],
            evaluatedAt: Date()
        ),
        onDismiss: {}
    )
}
