import SwiftUI

struct FeedbackSection: View {
    let feedback: ConversationFeedback

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "FF9500"))

                Text("AI Feedback")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
            }

            if let message = feedback.message {
                Text(message)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)
            }

            // Strengths and areas for improvement
            VStack(spacing: 12) {
                if !feedback.strengths.isEmpty {
                    FeedbackRow(
                        icon: "checkmark.circle.fill",
                        color: Color(hex: "34C759"),
                        title: "Strengths",
                        items: feedback.strengths
                    )
                }

                if !feedback.areasToImprove.isEmpty {
                    FeedbackRow(
                        icon: "arrow.up.circle.fill",
                        color: Color(hex: "007AFF"),
                        title: "Areas to Improve",
                        items: feedback.areasToImprove
                    )
                }
            }
            .padding(.top, 8)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }

}

struct FeedbackRow: View {
    let icon: String
    let color: Color
    let title: String
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)

                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
            }

            VStack(alignment: .leading, spacing: 6) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .foregroundColor(.secondary)

                        Text(item)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(.leading, 20)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.08))
        )
    }
}

#Preview {
    FeedbackSection(
        feedback: ConversationFeedback(
            message: "Great job on your practice session!",
            fluencyScore: 85,
            suggestions: [],
            strengths: ["Clear pronunciation", "Good conversation flow", "Natural intonation"],
            areasToImprove: ["Try speaking slightly faster", "Reduce filler words"]
        )
    )
    .padding()
}
