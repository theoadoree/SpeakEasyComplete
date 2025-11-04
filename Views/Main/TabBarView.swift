import SwiftUI

struct TabBarView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var profileViewModel: UserProfileViewModel
    @EnvironmentObject var conversationViewModel: ConversationViewModel
    @StateObject private var appState = AppState()

    @State private var selectedTab = 0
    @State private var showingSettings = false

    var body: some View {
        ZStack {
            // Main Tab View
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        TabIcon(title: "Home", icon: "house", isSelected: selectedTab == 0)
                    }
                    .tag(0)

                PracticeView()
                    .tabItem {
                        TabIcon(title: "Practice", icon: "bubble.left.and.bubble.right", isSelected: selectedTab == 1)
                    }
                    .badge(appState.challengesBadgeCount)
                    .tag(1)

                LearnView()
                    .tabItem {
                        TabIcon(title: "Learn", icon: "book", isSelected: selectedTab == 2)
                    }
                    .badge(appState.lessonsBadgeCount)
                    .tag(2)

                ProgressTabView()
                    .tabItem {
                        TabIcon(title: "Progress", icon: "chart.bar.xaxis", selectedIcon: "chart.bar.fill", isSelected: selectedTab == 3)
                    }
                    .badge(appState.pendingReviewCount)
                    .tag(3)
            }
            .accentColor(Color.accentColor)
            .onChange(of: selectedTab) { newTab in
                handleTabChange(newTab)
            }

            // Settings Button Overlay (Top Right)
            VStack {
                HStack {
                    Spacer()
                    SettingsMenuButton(showingSettings: $showingSettings)
                        .padding(.top, 8)
                        .padding(.trailing, 16)
                }
                Spacer()
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .environmentObject(appState)
        }
        .environmentObject(appState)
        .onAppear {
            // Update app state from profile
            if let profile = profileViewModel.userProfile {
                appState.updateFromProfile(profile)
            }

            // Simulate some initial data (for testing)
            setupInitialBadges()
        }
    }

    // MARK: - Helper Methods
    private func handleTabChange(_ newTab: Int) {
        // Clear badge when user visits the tab
        switch newTab {
        case 1:
            appState.clearBadge(for: .practice)
        case 2:
            appState.clearBadge(for: .learn)
        case 3:
            appState.clearBadge(for: .progress)
        default:
            break
        }
    }

    private func setupInitialBadges() {
        // Example: Set some initial badge counts
        // In production, these would come from your data sources
        if appState.pendingReviewCount == 0 {
            appState.updatePendingReviews(5) // Example: 5 pending reviews
        }
    }
}

// MARK: - Settings Menu Button
struct SettingsMenuButton: View {
    @Binding var showingSettings: Bool
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Menu {
            // Quick Settings Section
            Section {
                Button(action: { showingSettings = true }) {
                    Label("Profile & Settings", systemImage: "person.circle")
                }

                Button(action: { /* Quick toggle */ }) {
                    Label("Daily Goal: 15 min", systemImage: "target")
                }

                Button(action: { /* Quick toggle */ }) {
                    Label("Notifications: On", systemImage: "bell")
                }
            }

            // Main Settings Section
            Section {
                Button(action: {
                    showingSettings = true
                }) {
                    Label("Learning Preferences", systemImage: "slider.horizontal.3")
                }

                Button(action: {
                    showingSettings = true
                }) {
                    Label("Voice Settings", systemImage: "waveform")
                }

                Button(action: {
                    showingSettings = true
                }) {
                    Label("Connected Apps", systemImage: "link")
                }
            }

            // Help & About Section
            Section {
                Button(action: {
                    showingSettings = true
                }) {
                    Label("Help & Support", systemImage: "questionmark.circle")
                }

                Button(action: {
                    showingSettings = true
                }) {
                    Label("About", systemImage: "info.circle")
                }

                Button(action: {
                    authViewModel.signOut()
                }) {
                    Label("Sign Out", systemImage: "arrow.right.square")
                }
                .foregroundColor(.red)
            }
        } label: {
            ZStack(alignment: .topTrailing) {
                // Settings icon using custom asset with proper light/dark mode
                Image(colorScheme == .dark ? "SettingsDark" : "SettingsLight")
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(colorScheme == .dark ? Color.white : Color(red: 0.4, green: 0.4, blue: 0.4))
                    .padding(10)
                    .background(
                        Circle()
                            .fill(Color.clear)
                    )

                if appState.unreadNotifications > 0 {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 10, height: 10)
                        .offset(x: -2, y: 2)
                }
            }
        }
    }
}

// MARK: - Tab Icon Helper
private struct TabIcon: View {
    let title: String
    let icon: String
    var selectedIcon: String?
    let isSelected: Bool
    @Environment(\.colorScheme) var colorScheme

    init(title: String, icon: String, selectedIcon: String? = nil, isSelected: Bool) {
        self.title = title
        self.icon = icon
        self.selectedIcon = selectedIcon
        self.isSelected = isSelected
    }

    var body: some View {
        VStack(spacing: 4) {
            // Use custom asset images instead of SF Symbols
            if let imageName = customImageName {
                Image(imageName)
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(iconColor)
            } else {
                // Fallback to SF Symbols if no custom image
                Image(systemName: symbolName)
                    .font(.system(size: 22, weight: isSelected ? .medium : .regular))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(iconColor)
            }

            Text(title)
                .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(textColor)
        }
    }

    private var customImageName: String? {
        // Map icon names to custom assets
        let baseIconName: String
        switch icon {
        case "house":
            baseIconName = "Home"
        case "bubble.left.and.bubble.right":
            baseIconName = "Practice"
        case "book":
            baseIconName = "Learn"
        case "chart.bar.xaxis":
            baseIconName = "Progress"
        default:
            return nil
        }

        // Use Light/Dark suffix based on color scheme
        let suffix = colorScheme == .dark ? "Dark" : "Light"
        return "\(baseIconName)\(suffix)"
    }

    private var symbolName: String {
        if isSelected, let selectedIcon {
            return selectedIcon
        }
        if isSelected {
            return icon + ".fill"
        }
        return icon
    }

    private var iconColor: Color {
        if isSelected {
            // Dark navy blue for dark mode, accent color for light mode
            return colorScheme == .dark ? Color.white : Color(red: 0.106, green: 0.227, blue: 0.322)
        } else {
            return Color.gray.opacity(0.6)
        }
    }

    private var textColor: Color {
        if isSelected {
            return colorScheme == .dark ? Color.white : Color(red: 0.106, green: 0.227, blue: 0.322)
        } else {
            return Color.gray.opacity(0.7)
        }
    }
}

// MARK: - Home View (New Design)
struct HomeView: View {
    @EnvironmentObject var profileViewModel: UserProfileViewModel
    @EnvironmentObject var appState: AppState
    @State private var showCelebration = false
    @State private var animateProgress = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header with Greeting & Streak
                    HomeHeaderCard()
                        .padding(.horizontal)

                    // Milestone Banner (if achieved)
                    if appState.todayMinutes >= appState.dailyGoal && appState.todayMinutes > 0 {
                        MilestoneBanner(
                            title: "Daily Goal Achieved!",
                            message: "Great job! You've completed your daily goal.",
                            icon: "star.fill",
                            color: .yellow
                        )
                        .padding(.horizontal)
                        .transition(.scale.combined(with: .opacity))
                    }

                    // Combined Progress & Quick Actions
                    DailyProgressCard()
                        .padding(.horizontal)

                    // Primary CTA
                    BigActionButton()
                        .padding(.horizontal)

                    // Today's Content Section
                    TodaysContentSection()
                        .padding(.horizontal)

                    // Quick Stats Row
                    QuickStatsRow()
                        .padding(.horizontal)

                    // Recent Activity Section
                    RecentActivitySection()
                        .padding(.horizontal)

                    Spacer(minLength: 20)
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animateProgress = true
            }
        }
    }
}

// MARK: - Home Header Card
struct HomeHeaderCard: View {
    @EnvironmentObject var appState: AppState
    @State private var pulseAnimation = false

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good morning"
        case 12..<18: return "Good afternoon"
        default: return "Good evening"
        }
    }

    var greetingEmoji: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "☀️"
        case 12..<18: return "🌤️"
        default: return "🌙"
        }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("\(greeting), \(appState.userName)! \(greetingEmoji)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                HStack(spacing: 12) {
                    // Streak indicator
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                            .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                        Text("\(appState.streak) day\(appState.streak == 1 ? "" : "s")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    // Level badge
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text(appState.userLevel.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.yellow.opacity(0.15))
                    .cornerRadius(8)
                }
            }

            Spacer()
        }
        .padding(.top, 8)
        .onAppear {
            // Pulse animation for streak
            withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                pulseAnimation = true
            }
        }
    }
}

// MARK: - Milestone Banner
struct MilestoneBanner: View {
    let title: String
    let message: String
    let icon: String
    let color: Color
    @State private var show = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
                .rotationEffect(.degrees(show ? 360 : 0))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(message)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "confetti")
                .foregroundColor(color.opacity(0.7))
                .scaleEffect(show ? 1.2 : 0.8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
        .onAppear {
            withAnimation(Animation.spring(response: 0.5, dampingFraction: 0.6).repeatForever(autoreverses: true)) {
                show = true
            }
        }
    }
}

// MARK: - Daily Progress Card
struct DailyProgressCard: View {
    @EnvironmentObject var appState: AppState
    @State private var showingPractice = false
    @State private var showingReview = false
    @State private var animateRing = false

    var progressPercentage: Double {
        min(Double(appState.todayMinutes) / Double(appState.dailyGoal), 1.0)
    }

    var progressColor: Color {
        if progressPercentage >= 1.0 {
            return .green
        } else if progressPercentage >= 0.5 {
            return .blue
        } else {
            return .orange
        }
    }

    var body: some View {
        VStack(spacing: 18) {
            // Title
            HStack {
                Text("Today's Progress")
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                if progressPercentage >= 1.0 {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title3)
                }
            }

            // Progress Ring & Stats
            HStack(spacing: 20) {
                // Circular Progress with animation
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.15), lineWidth: 10)
                        .frame(width: 90, height: 90)

                    Circle()
                        .trim(from: 0, to: animateRing ? CGFloat(progressPercentage) : 0)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [progressColor, progressColor.opacity(0.7)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .frame(width: 90, height: 90)
                        .rotationEffect(Angle(degrees: -90))
                        .animation(.spring(response: 1.0, dampingFraction: 0.7), value: animateRing)

                    VStack(spacing: 2) {
                        Text("\(appState.todayMinutes)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(progressColor)
                        Text("of \(appState.dailyGoal)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("min")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                // Today's Stats
                VStack(alignment: .leading, spacing: 10) {
                    StatRow(icon: "target",
                           label: "Daily Goal",
                           value: "\(Int(progressPercentage * 100))%")

                    StatRow(icon: "book.fill",
                           label: "Words Today",
                           value: "+\(appState.todayWords)")

                    StatRow(icon: "arrow.triangle.2.circlepath",
                           label: "Due for Review",
                           value: "\(appState.pendingReviewCount)")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Divider()

            // Quick Action Buttons
            HStack(spacing: 12) {
                Button(action: { showingPractice = true }) {
                    HStack {
                        Image(systemName: "mic.fill")
                            .font(.subheadline)
                        Text("Practice")
                            .font(.subheadline)
                    }
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .blue.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: Color.blue.opacity(0.3), radius: 4, x: 0, y: 2)
                }

                Button(action: { showingReview = true }) {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.subheadline)
                        Text("Review")
                            .font(.subheadline)
                        if appState.pendingReviewCount > 0 {
                            Text("(\(appState.pendingReviewCount))")
                                .font(.caption)
                                .fontWeight(.bold)
                        }
                    }
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.purple, .purple.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: Color.purple.opacity(0.3), radius: 4, x: 0, y: 2)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                animateRing = true
            }
        }
        .fullScreenCover(isPresented: $showingPractice) {
            ConversationPracticeView(
                lesson: Lesson(
                    language: .spanish,
                    level: .intermediate,
                    category: .conversation,
                    title: "Free Practice",
                    description: "Practice speaking Spanish",
                    duration: 15,
                    objectives: ["Practice speaking"],
                    completionDate: nil
                ),
                scenario: ConversationScenario(
                    id: "practice",
                    title: "Free Practice",
                    description: "Practice conversation",
                    difficulty: "intermediate",
                    context: "General conversation practice",
                    suggestedPhrases: ["Hola", "¿Cómo estás?"],
                    objectives: ["Practice speaking"],
                    roleYouPlay: "Student",
                    aiRole: "Teacher",
                    autoVoiceEnabled: true
                )
            )
        }
        .sheet(isPresented: $showingReview) {
            VocabularyReviewView()
        }
    }
}

// MARK: - Stat Row
struct StatRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.blue)
                .frame(width: 16)

            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
        }
    }
}

// MARK: - Big Action Button
struct BigActionButton: View {
    var body: some View {
        NavigationLink(destination: ConversationPracticeView(
            lesson: Lesson(
                language: .spanish,
                level: .intermediate,
                category: .conversation,
                title: "Free Practice",
                description: "Practice speaking Spanish",
                duration: 15,
                objectives: ["Practice speaking"],
                completionDate: nil
            ),
            scenario: ConversationScenario(
                id: "practice",
                title: "Free Practice",
                description: "Practice conversation",
                difficulty: "intermediate",
                context: "General conversation practice",
                suggestedPhrases: ["Hola", "¿Cómo estás?"],
                objectives: ["Practice speaking"],
                roleYouPlay: "Student",
                aiRole: "Teacher",
                autoVoiceEnabled: true
            )
        )) {
            VStack(spacing: 12) {
                Image(systemName: "mic.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)

                Text("Start Speaking Practice")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("Have a conversation with AI")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 30)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.blue, .purple]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(20)
            .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
        }
    }
}

// MARK: - Today's Content Section
struct TodaysContentSection: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Today's Content")
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                NavigationLink(destination: LearnView()) {
                    HStack(spacing: 4) {
                        Text("See All")
                            .font(.subheadline)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    NavigationLink(destination: LessonListView()) {
                        ContentCard(
                            icon: "book.fill",
                            title: "Daily Lesson",
                            subtitle: "Greetings & Basics",
                            color: .green,
                            isCompleted: false
                        )
                    }

                    NavigationLink(destination: Text("Music Learning")) {
                        ContentCard(
                            icon: "music.note",
                            title: "Song of the Day",
                            subtitle: "La Bamba",
                            color: .pink,
                            isCompleted: false
                        )
                    }

                    NavigationLink(destination: Text("Video Lessons")) {
                        ContentCard(
                            icon: "play.rectangle.fill",
                            title: "Video Lesson",
                            subtitle: "Spanish Culture",
                            color: .orange,
                            isCompleted: false
                        )
                    }

                    NavigationLink(destination: FluencyChallengesView()) {
                        ContentCard(
                            icon: "gamecontroller.fill",
                            title: "Daily Challenge",
                            subtitle: "Speed Round",
                            color: .blue,
                            isCompleted: false
                        )
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }
}

// MARK: - Content Card
struct ContentCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let isCompleted: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)

                Spacer()

                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Spacer()
        }
        .frame(width: 150, height: 130)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Quick Stats Row
struct QuickStatsRow: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        HStack(spacing: 12) {
            QuickStatItem(
                icon: "book.fill",
                value: "\(appState.totalWords)",
                label: "Total Words",
                color: .blue
            )

            QuickStatItem(
                icon: "checkmark.seal.fill",
                value: "\(appState.masteredWords)",
                label: "Mastered",
                color: .green
            )

            QuickStatItem(
                icon: "clock.fill",
                value: "\(appState.todayMinutes)m",
                label: "Today",
                color: .orange
            )
        }
    }
}

// MARK: - Quick Stat Item
struct QuickStatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)

            Text(value)
                .font(.headline)
                .fontWeight(.bold)

            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 3)
    }
}

// MARK: - Recent Activity Section
struct RecentActivitySection: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.headline)
                .foregroundColor(.primary)

            VStack(spacing: 10) {
                ActivityRow(
                    icon: "book.fill",
                    title: "Completed Lesson",
                    subtitle: "Basic Greetings",
                    time: "2 hours ago",
                    color: .green
                )

                ActivityRow(
                    icon: "checkmark.circle.fill",
                    title: "Reviewed 15 Words",
                    subtitle: "Vocabulary Practice",
                    time: "5 hours ago",
                    color: .blue
                )

                ActivityRow(
                    icon: "mic.fill",
                    title: "Speaking Practice",
                    subtitle: "Conversation with AI",
                    time: "Yesterday",
                    color: .purple
                )
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5)
        }
    }
}

// MARK: - Activity Row
struct ActivityRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let time: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.callout)
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(time)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Learn View (Placeholder)
struct LearnView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Learn Tab")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Content library coming soon")
                        .foregroundColor(.secondary)

                    // Quick navigation to existing content
                    NavigationLink(destination: LessonListView()) {
                        HStack {
                            Image(systemName: "book.fill")
                                .font(.title2)
                                .foregroundColor(.white)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Browse Lessons")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text("Structured learning content")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.9))
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("Learn")
        }
    }
}

// MARK: - Progress Tab View (New)
struct ProgressTabView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Progress & Analytics")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Detailed progress tracking coming soon")
                    .foregroundColor(.secondary)

                // Quick stats preview
                HStack(spacing: 15) {
                    ProgressStatCard(
                        icon: "book.fill",
                        title: "Total Words",
                        value: "\(appState.totalWords)",
                        color: .blue
                    )

                    ProgressStatCard(
                        icon: "checkmark.seal.fill",
                        title: "Mastered",
                        value: "\(appState.masteredWords)",
                        color: .green
                    )
                }
                .padding(.horizontal)

                HStack(spacing: 15) {
                    ProgressStatCard(
                        icon: "flame.fill",
                        title: "Streak",
                        value: "\(appState.streak) days",
                        color: .orange
                    )

                    ProgressStatCard(
                        icon: "clock.fill",
                        title: "Today",
                        value: "\(appState.todayMinutes) min",
                        color: .purple
                    )
                }
                .padding(.horizontal)
            }
            .padding()
        }
    }
}

struct ProgressStatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundColor(color)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5)
    }
}

#Preview {
    TabBarView()
        .environmentObject(AuthenticationViewModel())
        .environmentObject(UserProfileViewModel())
        .environmentObject(ConversationViewModel())
}
