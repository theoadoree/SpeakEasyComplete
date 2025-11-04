import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var profileViewModel: UserProfileViewModel

    @State private var showDeleteConfirmation = false
    @State private var showSignOutConfirmation = false

    var body: some View {
        List {
            // Profile Section
            Section {
                if let user = authViewModel.user {
                    HStack(spacing: 16) {
                        // Avatar
                        if let imageUrl = user.imageUrl, let url = URL(string: imageUrl) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .foregroundColor(.gray)
                            }
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .foregroundColor(.gray)
                                .frame(width: 60, height: 60)
                        }

                        // User info
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.name)
                                .font(.headline)

                            if let email = user.email {
                                Text(email)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            Text(user.provider.rawValue.capitalized)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.2))
                                .foregroundColor(.blue)
                                .cornerRadius(4)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }

            // Learning Settings
            Section("Learning") {
                if let profile = profileViewModel.userProfile {
                    NavigationLink {
                        LanguageSettingsView(profile: profile)
                    } label: {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            Text("Languages")
                            Spacer()
                            if let language = Language.allCases.first(where: { $0.rawValue == profile.targetLanguage }) {
                                HStack(spacing: 6) {
                                    Text(language.flag)
                                        .font(.system(size: 16))
                                    Text(language.rawValue)
                                        .foregroundColor(.secondary)
                                        .font(.subheadline)
                                }
                            } else {
                                Text("\(profile.targetLanguage)")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    NavigationLink {
                        LevelSettingsView(profile: profile)
                    } label: {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(.green)
                                .frame(width: 24)
                            Text("Current Level")
                            Spacer()
                            Text(profile.level.rawValue.uppercased())
                                .foregroundColor(.secondary)
                        }
                    }

                    NavigationLink {
                        InterestsSettingsView(profile: profile)
                    } label: {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .frame(width: 24)
                            Text("Interests")
                            Spacer()
                            Text("\(profile.interests.count)")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }

            // App Settings
            Section("App") {
                NavigationLink {
                    AppearanceSettingsView()
                } label: {
                    HStack {
                        Image(systemName: "paintbrush.fill")
                            .foregroundColor(.indigo)
                            .frame(width: 24)
                        Text("Appearance")
                    }
                }

                NavigationLink {
                    NotificationsView()
                } label: {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.purple)
                            .frame(width: 24)
                        Text("Notifications")
                    }
                }

                NavigationLink {
                    DataUsageView()
                } label: {
                    HStack {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        Text("Data Usage")
                    }
                }
            }

            // Support Section
            Section("Support") {
                Link(destination: URL(string: "https://speakeasy-ai.app/help")!) {
                    HStack {
                        Image(systemName: "questionmark.circle.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        Text("Help Center")
                    }
                }

                Link(destination: URL(string: "https://speakeasy-ai.app/privacy")!) {
                    HStack {
                        Image(systemName: "hand.raised.fill")
                            .foregroundColor(.orange)
                            .frame(width: 24)
                        Text("Privacy Policy")
                    }
                }

                Link(destination: URL(string: "https://speakeasy-ai.app/terms")!) {
                    HStack {
                        Image(systemName: "doc.text.fill")
                            .foregroundColor(.gray)
                            .frame(width: 24)
                        Text("Terms of Service")
                    }
                }
            }

            // Account Actions
            Section("Account") {
                NavigationLink {
                    AccountPrivacyView(showDeleteConfirmation: $showDeleteConfirmation)
                } label: {
                    HStack {
                        Image(systemName: "person.badge.shield.checkmark.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        Text("Account & Privacy")
                    }
                }

                Button(action: { showSignOutConfirmation = true }) {
                    HStack {
                        Image(systemName: "arrow.right.square.fill")
                            .foregroundColor(.orange)
                            .frame(width: 24)
                        Text("Sign Out")
                            .foregroundColor(.primary)
                    }
                }
            }

            // App Info
            Section {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Settings")
        .confirmationDialog("Sign Out", isPresented: $showSignOutConfirmation) {
            Button("Sign Out", role: .destructive) {
                authViewModel.signOut()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .confirmationDialog("Delete Account", isPresented: $showDeleteConfirmation) {
            Button("Delete Account", role: .destructive) {
                Task {
                    await authViewModel.deleteAccount()
                    StorageService.shared.clearAllData()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone. All your data will be permanently deleted.")
        }
    }
}

// MARK: - Language Settings View
struct LanguageSettingsView: View {
    let profile: UserProfile
    @EnvironmentObject var profileViewModel: UserProfileViewModel
    @State private var showingNativeLanguagePicker = false
    @State private var showingTargetLanguagePicker = false

    var body: some View {
        List {
            Section {
                Button(action: { showingNativeLanguagePicker = true }) {
                    HStack {
                        Text("Native Language")
                            .foregroundColor(.primary)
                        Spacer()
                        if let language = Language.allCases.first(where: { $0.rawValue == profile.nativeLanguage }) {
                            HStack(spacing: 8) {
                                Text(language.flag)
                                    .font(.system(size: 20))
                                Text(language.rawValue)
                                    .foregroundColor(.secondary)
                            }
                        } else {
                            Text(profile.nativeLanguage)
                                .foregroundColor(.secondary)
                        }
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } footer: {
                Text("The language you already speak fluently")
            }

            Section {
                Button(action: { showingTargetLanguagePicker = true }) {
                    HStack {
                        Text("Target Language")
                            .foregroundColor(.primary)
                        Spacer()
                        if let language = Language.allCases.first(where: { $0.rawValue == profile.targetLanguage }) {
                            HStack(spacing: 8) {
                                Text(language.flag)
                                    .font(.system(size: 20))
                                Text(language.rawValue)
                                    .foregroundColor(.secondary)
                            }
                        } else {
                            Text(profile.targetLanguage)
                                .foregroundColor(.secondary)
                        }
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } footer: {
                Text("The language you want to learn")
            }
        }
        .navigationTitle("Languages")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingNativeLanguagePicker) {
            LanguagePickerView(
                title: "Select Native Language",
                selectedLanguage: profile.nativeLanguage,
                onSelect: { newLanguage in
                    profileViewModel.updateProfile(nativeLanguage: newLanguage)
                    showingNativeLanguagePicker = false
                }
            )
        }
        .sheet(isPresented: $showingTargetLanguagePicker) {
            LanguagePickerView(
                title: "Select Target Language",
                selectedLanguage: profile.targetLanguage,
                onSelect: { newLanguage in
                    profileViewModel.updateProfile(targetLanguage: newLanguage)
                    showingTargetLanguagePicker = false
                }
            )
        }
    }
}

// MARK: - Language Picker View
struct LanguagePickerView: View {
    let title: String
    let selectedLanguage: String
    let onSelect: (String) -> Void
    @Environment(\.dismiss) private var dismiss

    // Group languages by type
    private let englishVariants: [Language] = [.englishUS, .englishUK]
    private let spanishVariants: [Language] = [.spanishSpain, .spanishLatinAmerica, .spanishCaribbean]
    private let portugueseVariants: [Language] = [.portugueseBrazil, .portuguesePortugal]
    private let chineseVariants: [Language] = [.chineseMandarin, .chineseCantonese]

    private var otherLanguages: [Language] {
        Language.allCases.filter { language in
            !englishVariants.contains(language) &&
            !spanishVariants.contains(language) &&
            !portugueseVariants.contains(language) &&
            !chineseVariants.contains(language)
        }
    }

    var body: some View {
        NavigationView {
            List {
                if !englishVariants.isEmpty {
                    Section("English") {
                        ForEach(englishVariants, id: \.self) { language in
                            languageRow(language)
                        }
                    }
                }

                if !spanishVariants.isEmpty {
                    Section("Spanish") {
                        ForEach(spanishVariants, id: \.self) { language in
                            languageRow(language)
                        }
                    }
                }

                if !portugueseVariants.isEmpty {
                    Section("Portuguese") {
                        ForEach(portugueseVariants, id: \.self) { language in
                            languageRow(language)
                        }
                    }
                }

                if !chineseVariants.isEmpty {
                    Section("Chinese") {
                        ForEach(chineseVariants, id: \.self) { language in
                            languageRow(language)
                        }
                    }
                }

                Section("Other Languages") {
                    ForEach(otherLanguages, id: \.self) { language in
                        languageRow(language)
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func languageRow(_ language: Language) -> some View {
        Button(action: {
            onSelect(language.rawValue)
        }) {
            HStack(spacing: 12) {
                Text(language.flag)
                    .font(.system(size: 28))
                Text(language.rawValue)
                    .foregroundColor(.primary)
                Spacer()
                if language.rawValue == selectedLanguage {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
            .padding(.vertical, 4)
        }
    }
}

// MARK: - Level Settings View
struct LevelSettingsView: View {
    let profile: UserProfile

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(profile.level.rawValue.uppercased())
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text(AssessmentService.shared.getLevelDescription(profile.level))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }

            Section("Progress") {
                let progress = AssessmentService.shared.getProgressPercentage(profile.level)
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("\(Int(progress))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    ProgressView(value: progress / 100.0, total: 1.0)
                }
            }
        }
        .navigationTitle("Current Level")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Interests Settings View
struct InterestsSettingsView: View {
    let profile: UserProfile

    var body: some View {
        List {
            Section {
                ForEach(profile.interests, id: \.self) { interest in
                    Text(interest)
                }
            }
        }
        .navigationTitle("Interests")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Appearance Settings View
struct AppearanceSettingsView: View {
    @AppStorage("appTheme") private var appTheme: String = "system"
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        List {
            Section {
                Picker("Theme", selection: $appTheme) {
                    HStack {
                        Image(systemName: "sun.max.fill")
                            .foregroundColor(.orange)
                        Text("Light")
                    }
                    .tag("light")

                    HStack {
                        Image(systemName: "moon.fill")
                            .foregroundColor(.indigo)
                        Text("Dark")
                    }
                    .tag("dark")

                    HStack {
                        Image(systemName: "iphone")
                            .foregroundColor(.blue)
                        Text("System")
                    }
                    .tag("system")
                }
                .pickerStyle(.inline)
            } header: {
                Text("App Theme")
            } footer: {
                Text("Choose your preferred color scheme. System will match your device settings.")
            }

            Section("Preview") {
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "graduationcap.fill")
                            .font(.largeTitle)
                            .foregroundColor(.blue)

                        VStack(alignment: .leading) {
                            Text("SpeakEasy AI")
                                .font(.headline)
                            Text("Language Learning Assistant")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)

                    Text("Your theme preference: \(appTheme.capitalized)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Placeholder Views
struct NotificationsView: View {
    var body: some View {
        Text("Notifications settings coming soon!")
            .navigationTitle("Notifications")
    }
}

struct DataUsageView: View {
    var body: some View {
        Text("Data usage settings coming soon!")
            .navigationTitle("Data Usage")
    }
}

// MARK: - Account & Privacy View
struct AccountPrivacyView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Binding var showDeleteConfirmation: Bool

    var body: some View {
        List {
            Section("Account Information") {
                if let user = authViewModel.user {
                    if let email = user.email {
                        HStack {
                            Text("Email")
                            Spacer()
                            Text(email)
                                .foregroundColor(.secondary)
                        }
                    }

                    HStack {
                        Text("Provider")
                        Spacer()
                        Text(user.provider.rawValue.capitalized)
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("User ID")
                        Spacer()
                        if let uid = user.uid {
                            Text(String(uid.prefix(8)) + "...")
                                .foregroundColor(.secondary)
                                .font(.system(.caption, design: .monospaced))
                        }
                    }
                }
            }

            Section("Privacy & Data") {
                NavigationLink {
                    Text("Privacy settings coming soon")
                        .navigationTitle("Privacy")
                } label: {
                    HStack {
                        Image(systemName: "hand.raised.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        Text("Privacy Settings")
                    }
                }

                NavigationLink {
                    Text("Data export coming soon")
                        .navigationTitle("Export Data")
                } label: {
                    HStack {
                        Image(systemName: "arrow.down.doc.fill")
                            .foregroundColor(.green)
                            .frame(width: 24)
                        Text("Export My Data")
                    }
                }
            }

            Section {
                NavigationLink {
                    DeleteAccountView(showDeleteConfirmation: $showDeleteConfirmation)
                } label: {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                            .frame(width: 24)
                        Text("Delete Account")
                            .foregroundColor(.red)
                    }
                }
            } header: {
                Text("Danger Zone")
            } footer: {
                Text("Deleting your account is permanent and cannot be undone.")
            }
        }
        .navigationTitle("Account & Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Delete Account View
struct DeleteAccountView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Binding var showDeleteConfirmation: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.top)

                    Text("Delete Your Account")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)

                    Text("This action cannot be undone. When you delete your account:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)

                    VStack(alignment: .leading, spacing: 8) {
                        Label("All your learning progress will be lost", systemImage: "xmark.circle.fill")
                            .foregroundColor(.red)
                        Label("Your profile data will be permanently deleted", systemImage: "xmark.circle.fill")
                            .foregroundColor(.red)
                        Label("You won't be able to recover your account", systemImage: "xmark.circle.fill")
                            .foregroundColor(.red)
                        Label("Your subscription will be cancelled", systemImage: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                    .font(.subheadline)
                    .padding(.vertical)
                }
                .padding(.vertical)
            }

            Section {
                Button(action: {
                    showDeleteConfirmation = true
                    dismiss()
                }) {
                    HStack {
                        Spacer()
                        Text("I Understand, Delete My Account")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                }
                .foregroundColor(.white)
                .listRowBackground(Color.red)
            }
        }
        .navigationTitle("Delete Account")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        SettingsView()
            .environmentObject(AuthenticationViewModel())
            .environmentObject(UserProfileViewModel())
    }
}
