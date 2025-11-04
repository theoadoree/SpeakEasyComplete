import SwiftUI
import Charts

struct PracticeResultsView: View {
    let lesson: Lesson
    let scenario: ConversationScenario
    let metrics: SessionMetrics
    let onContinue: () -> Void
    let onRetry: () -> Void

    @State private var animateChart = false
    @State private var showAchievements = false

    var sessionDuration: String {
        let duration = Date().timeIntervalSince(metrics.sessionStartTime)
        return TimeFormatter.shared.string(from: duration)
    }

    var averageWPM: Int {
        let duration = Date().timeIntervalSince(metrics.sessionStartTime) / 60.0
        return duration > 0 ? Int(Double(metrics.totalWords) / duration) : 0
    }

    var fluencyGrade: String {
        let score = metrics.currentFluencyScore
        if score >= 9 { return "A+" }
        else if score >= 8 { return "A" }
        else if score >= 7 { return "B" }
        else if score >= 6 { return "C" }
        else { return "Keep Practicing!" }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    ResultsHeaderView(
                        grade: fluencyGrade,
                        title: "Great Practice Session!",
                        subtitle: scenario.title
                    )
                    .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))

                    // Key Metrics
                    HStack(spacing: 16) {
                        MetricCard(
                            icon: "clock.fill",
                            value: sessionDuration,
                            label: "Duration",
                            color: Color(hex: "007AFF")
                        )

                        MetricCard(
                            icon: "speedometer",
                            value: "\(averageWPM)",
                            label: "Avg WPM",
                            color: Color(hex: "34C759")
                        )

                        MetricCard(
                            icon: "message.fill",
                            value: "\(metrics.messageCount)",
                            label: "Exchanges",
                            color: Color(hex: "AF52DE")
                        )
                    }
                    .padding(.horizontal)

                    // Fluency Analysis Chart
                    FluencyChartView(metrics: AutoVoiceService.shared.fluencyMetrics)
                        .padding(.horizontal)
                        .opacity(animateChart ? 1 : 0)
                        .animation(.easeInOut(duration: 0.8).delay(0.3), value: animateChart)

                    // Achievements
                    if showAchievements {
                        AchievementsSection()
                            .padding(.horizontal)
                            .transition(.scale.combined(with: .opacity))
                    }

                    // Feedback Section
                    if let feedback = metrics.lastFeedback {
                        FeedbackSection(feedback: feedback)
                            .padding(.horizontal)
                    }

                    // Improvement Tips
                    ImprovementTipsView(scenario: scenario)
                        .padding(.horizontal)

                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: onContinue) {
                            Text("Continue Learning")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [Color(hex: "007AFF"), Color(hex: "0051D5")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                        }

                        Button(action: onRetry) {
                            Text("Practice Again")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(hex: "007AFF"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(hex: "007AFF"), lineWidth: 2)
                                )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            .background(Color(hex: "F2F2F7"))
            .navigationBarHidden(true)
            .onAppear {
                animateChart = true
                checkForAchievements()
            }
        }
    }

    private func checkForAchievements() {
        // Check if user earned any achievements
        if averageWPM > 120 || metrics.currentFluencyScore > 8 {
            withAnimation(.spring().delay(0.5)) {
                showAchievements = true
            }
        }
    }
}

private struct AchievementsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "rosette")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color(hex: "FF9F0A"))
                Text("Achievements Unlocked")
                    .font(.system(size: 18, weight: .semibold))
            }

            VStack(spacing: 8) {
                HStack(spacing: 10) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(Color(hex: "FFD60A"))
                    Text("Great pace! Keep it up.")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                HStack(spacing: 10) {
                    Image(systemName: "bolt.fill")
                        .foregroundStyle(Color(hex: "34C759"))
                    Text("Strong fluency this session.")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
            )
        }
    }
}

private struct TimeFormatter {
    static let shared = TimeFormatter()

    func string(from timeInterval: TimeInterval) -> String {
        guard timeInterval.isFinite && timeInterval >= 0 else { return "0:00" }
        let totalSeconds = Int(timeInterval.rounded())
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

private struct MetricCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(color)
                Text(label)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
                Spacer(minLength: 0)
            }

            HStack {
                Text(value)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.primary)
                Spacer(minLength: 0)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
        )
    }
}

#Preview {
    PracticeResultsView(
        lesson: Lesson.getAllLessons().first!,
        scenario: Lesson.getAllLessons().first!.scenarios.first!,
        metrics: SessionMetrics(
            sessionStartTime: Date().addingTimeInterval(-300),
            messageCount: 10,
            totalWords: 150,
            currentFluencyScore: 7.5,
            lastFeedback: ConversationFeedback(
                fluencyScore: 7.5,
                suggestions: [],
                strengths: ["Good use of target vocabulary", "Natural intonation"],
                areasToImprove: [],
                improvements: ["Try to speak more continuously"]
            )
        ),
        onContinue: {},
        onRetry: {}
    )
}

