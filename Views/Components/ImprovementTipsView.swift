import SwiftUI

struct ImprovementTipsView: View {
    let scenario: ConversationScenario

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "FFD700"))

                Text("Tips for Next Time")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
            }

            VStack(spacing: 12) {
                ForEach(tips, id: \.self) { tip in
                    TipRow(tip: tip)
                }
            }

            // Suggested practice
            VStack(alignment: .leading, spacing: 8) {
                Text("Suggested Practice")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)

                Text("Try repeating this scenario with a focus on reducing pauses and increasing your speaking speed.")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "007AFF").opacity(0.08))
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }

    private var tips: [String] {
        // In production, these would be tailored to the scenario and user performance
        return [
            "Practice common phrases before your session",
            "Record yourself to hear your pronunciation",
            "Focus on speaking at a steady pace",
            "Use the vocabulary from this lesson in daily life"
        ]
    }
}

struct TipRow: View {
    let tip: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: "34C759").opacity(0.15))
                    .frame(width: 28, height: 28)

                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "34C759"))
            }

            Text(tip)
                .font(.system(size: 15))
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
    }
}

#Preview {
    ImprovementTipsView(
        scenario: ConversationScenario(
            id: "restaurant",
            title: "Restaurant Ordering",
            description: "Practice ordering food at a restaurant",
            difficulty: "beginner",
            context: "You are at a restaurant and need to order food",
            suggestedPhrases: ["I would like to order", "Can I have the menu?", "What do you recommend?"],
            objectives: ["Order food", "Ask questions", "Handle payment"]
        )
    )
    .padding()
}
