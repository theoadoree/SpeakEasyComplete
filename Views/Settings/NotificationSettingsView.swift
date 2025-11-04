import SwiftUI

struct NotificationSettingsView: View {
    @StateObject private var notificationService = NotificationService.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var showingPermissionAlert = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        VStack(spacing: 8) {
                            Image(systemName: "bell.badge.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.blue)
                                .padding()

                            Text("Notification Settings")
                                .font(.system(size: 24, weight: .bold))

                            Text("Stay motivated with helpful reminders")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .padding()

                        // Notification Status
                        VStack(alignment: .leading, spacing: 16) {
                            if !notificationService.notificationsEnabled {
                                NotificationPermissionCard(
                                    onEnable: {
                                        Task {
                                            let granted = await notificationService.requestPermission()
                                            if !granted {
                                                showingPermissionAlert = true
                                            }
                                        }
                                    }
                                )
                            }

                            // Daily Practice Reminder
                            SettingCard(
                                icon: "alarm.fill",
                                iconColor: .blue,
                                title: "Daily Practice Reminder",
                                subtitle: "Get reminded to practice every day"
                            ) {
                                VStack(spacing: 12) {
                                    DatePicker(
                                        "Reminder Time",
                                        selection: Binding(
                                            get: { notificationService.dailyReminderTime },
                                            set: { newTime in
                                                Task {
                                                    await notificationService.updateDailyReminderTime(newTime)
                                                }
                                            }
                                        ),
                                        displayedComponents: .hourAndMinute
                                    )
                                    .disabled(!notificationService.notificationsEnabled)
                                }
                            }

                            // Streak Warning
                            SettingCard(
                                icon: "flame.fill",
                                iconColor: .orange,
                                title: "Streak Reminder",
                                subtitle: "Don't break your learning streak"
                            ) {
                                Toggle("", isOn: Binding(
                                    get: { notificationService.streakReminderEnabled },
                                    set: { enabled in
                                        Task {
                                            await notificationService.toggleStreakReminder(enabled)
                                        }
                                    }
                                ))
                                .disabled(!notificationService.notificationsEnabled)
                            }

                            // Vocabulary Review
                            SettingCard(
                                icon: "book.fill",
                                iconColor: .green,
                                title: "Vocabulary Review",
                                subtitle: "Get notified when words are ready to review"
                            ) {
                                Toggle("", isOn: Binding(
                                    get: { notificationService.vocabularyReviewEnabled },
                                    set: { enabled in
                                        notificationService.toggleVocabularyReview(enabled)
                                    }
                                ))
                                .disabled(!notificationService.notificationsEnabled)
                            }

                            // Achievement Notifications
                            SettingCard(
                                icon: "trophy.fill",
                                iconColor: .yellow,
                                title: "Achievements",
                                subtitle: "Celebrate your learning milestones"
                            ) {
                                Toggle("", isOn: Binding(
                                    get: { notificationService.achievementNotificationsEnabled },
                                    set: { enabled in
                                        notificationService.toggleAchievementNotifications(enabled)
                                    }
                                ))
                                .disabled(!notificationService.notificationsEnabled)
                            }
                        }
                        .padding(.horizontal)

                        // Test Notification Button
                        if notificationService.notificationsEnabled {
                            Button(action: {
                                Task {
                                    await notificationService.sendAchievementNotification(
                                        title: "Test Notification",
                                        description: "Your notifications are working perfectly!"
                                    )
                                }
                            }) {
                                HStack {
                                    Image(systemName: "paperplane.fill")
                                    Text("Send Test Notification")
                                        .font(.headline)
                                }
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.white)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)
                        }

                        Spacer(minLength: 20)
                    }
                    .padding(.vertical)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .alert("Enable Notifications", isPresented: $showingPermissionAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please enable notifications in Settings to receive practice reminders and updates.")
        }
    }
}

// MARK: - Notification Permission Card
struct NotificationPermissionCard: View {
    let onEnable: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "bell.slash.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.orange)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Notifications Disabled")
                        .font(.headline)
                        .foregroundColor(.black)

                    Text("Enable notifications to get reminders")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()
            }

            Button(action: onEnable) {
                Text("Enable Notifications")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        )
    }
}

// MARK: - Setting Card
struct SettingCard<Content: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let content: Content

    init(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.1))
                        .frame(width: 40, height: 40)

                    Image(systemName: icon)
                        .foregroundColor(iconColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()

                content
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        )
    }
}

#Preview {
    NotificationSettingsView()
}
