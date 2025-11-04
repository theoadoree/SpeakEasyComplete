//
//  AchievementsView.swift
//  SpeakEasy
//
//  Created by Claude on 2025-11-01.
//

import SwiftUI

struct AchievementsView: View {
    @StateObject private var achievementsManager = AchievementsManager()
    @State private var selectedCategory: AchievementCategory = .all

    enum AchievementCategory: String, CaseIterable {
        case all = "All"
        case learning = "Learning"
        case streaks = "Streaks"
        case vocabulary = "Vocabulary"
        case practice = "Practice"
        case social = "Social"

        var icon: String {
            switch self {
            case .all: return "star.fill"
            case .learning: return "book.fill"
            case .streaks: return "flame.fill"
            case .vocabulary: return "text.book.closed.fill"
            case .practice: return "mic.fill"
            case .social: return "person.2.fill"
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Achievement Progress Header
            AchievementProgressHeader(
                totalAchievements: achievementsManager.totalAchievements,
                unlockedCount: achievementsManager.unlockedCount,
                points: achievementsManager.totalPoints
            )

            // Category Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(AchievementCategory.allCases, id: \.self) { category in
                        CategoryFilterChip(
                            category: category,
                            isSelected: selectedCategory == category,
                            count: achievementsManager.getCount(for: category),
                            action: { selectedCategory = category }
                        )
                    }
                }
                .padding()
            }

            // Achievements List
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(achievementsManager.getAchievements(for: selectedCategory)) { achievement in
                        AchievementCard(achievement: achievement)
                    }
                }
                .padding()
            }
        }
        .onAppear {
            achievementsManager.loadAchievements()
        }
    }
}

struct AchievementProgressHeader: View {
    let totalAchievements: Int
    let unlockedCount: Int
    let points: Int

    var progressPercentage: Double {
        guard totalAchievements > 0 else { return 0 }
        return Double(unlockedCount) / Double(totalAchievements)
    }

    var body: some View {
        VStack(spacing: 16) {
            // Trophy icon with progress ring
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: CGFloat(progressPercentage))
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [.yellow, .orange]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(Angle(degrees: -90))
                    .animation(.spring(), value: progressPercentage)

                Image(systemName: "trophy.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.yellow)
            }

            // Stats
            HStack(spacing: 40) {
                VStack(spacing: 4) {
                    Text("\(unlockedCount)/\(totalAchievements)")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Unlocked")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                VStack(spacing: 4) {
                    Text("\(points)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)

                    Text("Points")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                VStack(spacing: 4) {
                    Text("\(Int(progressPercentage * 100))%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)

                    Text("Complete")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.yellow.opacity(0.1), Color.orange.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

struct CategoryFilterChip: View {
    let category: AchievementsView.AchievementCategory
    let isSelected: Bool
    let count: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: category.icon)
                    .font(.title3)

                Text(category.rawValue)
                    .font(.caption)

                if count > 0 {
                    Text("\(count)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(isSelected ? Color.white.opacity(0.3) : Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .frame(width: 80, height: 70)
            .background(isSelected ? Color.blue : Color(.secondarySystemBackground))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(12)
        }
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    @State private var showingDetail = false

    var body: some View {
        Button(action: { showingDetail = true }) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            achievement.isUnlocked
                                ? LinearGradient(
                                    gradient: Gradient(colors: [achievement.color.opacity(0.3), achievement.color.opacity(0.1)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                : LinearGradient(
                                    gradient: Gradient(colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.1)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                        )
                        .frame(width: 70, height: 70)

                    Image(systemName: achievement.icon)
                        .font(.system(size: 35))
                        .foregroundColor(achievement.isUnlocked ? achievement.color : .gray)

                    if achievement.isUnlocked {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                            .background(Circle().fill(Color.white))
                            .offset(x: 25, y: -25)
                    }
                }

                // Details
                VStack(alignment: .leading, spacing: 6) {
                    Text(achievement.title)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(achievement.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)

                    // Progress bar (if not unlocked)
                    if !achievement.isUnlocked {
                        HStack(spacing: 8) {
                            ProgressView(value: Double(achievement.currentProgress), total: Double(achievement.targetProgress))
                                .tint(achievement.color)

                            Text("\(achievement.currentProgress)/\(achievement.targetProgress)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        HStack(spacing: 6) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundColor(.yellow)

                            Text("\(achievement.points) points")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)

                            if let unlockedDate = achievement.unlockedDate {
                                Text("• \(unlockedDate.formatted(.dateTime.month().day()))")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }

                Spacer()

                // Rarity badge
                if achievement.isUnlocked {
                    RarityBadge(rarity: achievement.rarity)
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            .opacity(achievement.isUnlocked ? 1.0 : 0.7)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetail) {
            AchievementDetailView(achievement: achievement)
        }
    }
}

struct RarityBadge: View {
    let rarity: Achievement.Rarity

    var body: some View {
        Text(rarity.rawValue)
            .font(.caption2)
            .fontWeight(.bold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(rarity.color.opacity(0.2))
            .foregroundColor(rarity.color)
            .cornerRadius(8)
    }
}

struct AchievementDetailView: View {
    let achievement: Achievement
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Large icon
                    ZStack {
                        Circle()
                            .fill(
                                achievement.isUnlocked
                                    ? LinearGradient(
                                        gradient: Gradient(colors: [achievement.color.opacity(0.3), achievement.color.opacity(0.1)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    : LinearGradient(
                                        gradient: Gradient(colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.1)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                            )
                            .frame(width: 150, height: 150)

                        Image(systemName: achievement.icon)
                            .font(.system(size: 80))
                            .foregroundColor(achievement.isUnlocked ? achievement.color : .gray)

                        if achievement.isUnlocked {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.green)
                                .background(Circle().fill(Color.white).padding(-4))
                                .offset(x: 50, y: -50)
                        }
                    }
                    .padding(.top, 40)

                    // Title and description
                    VStack(spacing: 8) {
                        Text(achievement.title)
                            .font(.title)
                            .fontWeight(.bold)

                        Text(achievement.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)

                    // Stats
                    VStack(spacing: 16) {
                        HStack(spacing: 40) {
                            VStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.title2)
                                    .foregroundColor(.yellow)

                                Text("\(achievement.points)")
                                    .font(.title2)
                                    .fontWeight(.bold)

                                Text("Points")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            VStack(spacing: 4) {
                                Image(systemName: "chart.bar.fill")
                                    .font(.title2)
                                    .foregroundColor(achievement.rarity.color)

                                Text(achievement.rarity.rawValue)
                                    .font(.headline)
                                    .foregroundColor(achievement.rarity.color)

                                Text("Rarity")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }

                        if achievement.isUnlocked, let date = achievement.unlockedDate {
                            VStack(spacing: 4) {
                                Text("Unlocked on")
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                Text(date.formatted(.dateTime.month().day().year()))
                                    .font(.headline)
                            }
                        } else {
                            VStack(spacing: 12) {
                                Text("Progress")
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                ProgressView(value: Double(achievement.currentProgress), total: Double(achievement.targetProgress))
                                    .tint(achievement.color)
                                    .frame(maxWidth: 200)

                                Text("\(achievement.currentProgress) / \(achievement.targetProgress)")
                                    .font(.headline)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(15)

                    // Tips for unlocking
                    if !achievement.isUnlocked {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("How to unlock")
                                .font(.headline)

                            Text(achievement.unlockTip)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(15)
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AchievementsView()
}
