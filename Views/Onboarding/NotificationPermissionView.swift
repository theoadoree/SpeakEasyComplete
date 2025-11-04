import SwiftUI

struct NotificationPermissionView: View {
    @StateObject private var notificationService = NotificationService.shared
    let onComplete: () -> Void

    @State private var notificationGranted = false
    @State private var showingPermissionAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Icon and Title
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 120, height: 120)

                        Image(systemName: "bell.badge.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.blue.opacity(0.9))
                    }

                    Text("Stay on Track!")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text("Get helpful reminders to practice and track your progress")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 40)

                // Benefits
                VStack(spacing: 20) {
                    NotificationBenefit(
                        icon: "clock.fill",
                        color: .blue,
                        title: "Daily Reminders",
                        description: "Never miss your practice time"
                    )

                    NotificationBenefit(
                        icon: "flame.fill",
                        color: .orange,
                        title: "Streak Tracking",
                        description: "Keep your learning streak alive"
                    )

                    NotificationBenefit(
                        icon: "book.fill",
                        color: .green,
                        title: "Review Alerts",
                        description: "Know when vocabulary needs review"
                    )

                    NotificationBenefit(
                        icon: "trophy.fill",
                        color: .yellow,
                        title: "Achievement Badges",
                        description: "Celebrate your milestones"
                    )
                }
                .padding(.horizontal, 32)

                Spacer(minLength: 40)

                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        Task {
                            let granted = await notificationService.requestPermission()
                            notificationGranted = granted
                            if !granted {
                                showingPermissionAlert = true
                            } else {
                                // Schedule default notifications
                                await notificationService.scheduleDefaultNotifications()
                                onComplete()
                            }
                        }
                    }) {
                        Text("Enable Notifications")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }

                    Button(action: onComplete) {
                        Text("Maybe Later")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
        }
        .ignoresSafeArea(.keyboard)
        .alert("Enable Notifications", isPresented: $showingPermissionAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Skip") {
                onComplete()
            }
        } message: {
            Text("You can enable notifications later in Settings to get practice reminders.")
        }
    }
}

// MARK: - Notification Benefit Row
struct NotificationBenefit: View {
    let icon: String
    let color: Color
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)

                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
    }
}

#Preview {
    NotificationPermissionView(onComplete: {})
}
