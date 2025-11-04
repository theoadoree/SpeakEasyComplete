import SwiftUI

struct AchievementsSection: View {
    @State private var achievements: [Achievement] = [
        Achievement(
            icon: "🎯",
            title: "First Conversation",
            description: "Completed your first practice session",
            isUnlocked: true
        ),
        Achievement(
            icon: "🔥",
            title: "5 Day Streak",
            description: "Practiced for 5 days in a row",
            isUnlocked: false,
            progress: 0.6
        ),
        Achievement(
            icon: "⭐",
            title: "Fluency Master",
            description: "Achieved 90% fluency score",
            isUnlocked: false,
            progress: 0.3
        )
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Achievements Unlocked")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)

            ForEach(achievements) { achievement in
                AchievementRow(achievement: achievement)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

struct AchievementRow: View {
    let achievement: Achievement

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? Color(hex: "FFD700").opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 50, height: 50)

                Text(achievement.icon)
                    .font(.system(size: 24))
                    .opacity(achievement.isUnlocked ? 1.0 : 0.3)
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)

                Text(achievement.description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)

                // Progress bar for locked achievements
                if !achievement.isUnlocked, let progress = achievement.progress {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 4)

                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color(hex: "007AFF"))
                                .frame(width: geometry.size.width * progress, height: 4)
                        }
                    }
                    .frame(height: 4)
                    .padding(.top, 4)
                }
            }

            Spacer()

            // Checkmark for unlocked achievements
            if achievement.isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: "34C759"))
            }
        }
        .padding(.vertical, 8)
    }
}

struct Achievement: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let isUnlocked: Bool
    let progress: Double?

    init(icon: String, title: String, description: String, isUnlocked: Bool, progress: Double? = nil) {
        self.icon = icon
        self.title = title
        self.description = description
        self.isUnlocked = isUnlocked
        self.progress = progress
    }
}

#Preview {
    AchievementsSection()
        .padding()
}
