import SwiftUI

struct OnboardingContainerView: View {
    @EnvironmentObject var profileViewModel: UserProfileViewModel
    @State private var currentStep = 0
    @State private var name = ""
    @State private var targetLanguage = ""
    @State private var selectedInterests: [String] = []

    private let totalSteps = 4

    var body: some View {
        ZStack {
            GradientBackground()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress bar
                OnboardingProgressView(currentStep: currentStep, totalSteps: totalSteps)
                    .padding(.top, 60)

                // Content
                TabView(selection: $currentStep) {
                    // Step 1: Welcome & Name
                    WelcomeView(name: $name, onNext: nextStep)
                        .tag(0)

                    // Step 2: Target Language
                    LanguageSelectionView(
                        title: "What language do you want to learn?",
                        selectedLanguage: $targetLanguage,
                        onNext: nextStep
                    )
                    .tag(1)

                    // Step 3: Interests
                    InterestSelectionView(
                        selectedInterests: $selectedInterests,
                        onComplete: nextStep
                    )
                    .tag(2)

                    // Step 4: Notifications
                    NotificationPermissionView(
                        onComplete: completeOnboarding
                    )
                    .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStep)
            }
        }
    }

    private func nextStep() {
        withAnimation {
            currentStep += 1
        }
    }

    private func completeOnboarding() {
        // Detect native language from system settings
        let detectedNativeLanguage = detectSystemLanguage()

        // Create user profile
        profileViewModel.createProfile(
            name: name.isEmpty ? "User" : name,
            nativeLanguage: detectedNativeLanguage,
            targetLanguage: targetLanguage,
            interests: selectedInterests
        )

        // Mark onboarding as complete
        StorageService.shared.setOnboardingComplete(true)
    }

    private func detectSystemLanguage() -> String {
        // Get the user's preferred language from system settings
        guard let preferredLanguageCode = Locale.preferredLanguages.first else {
            return "English (US)" // Fallback
        }

        // Extract language and region
        let locale = Locale(identifier: preferredLanguageCode)
        let languageCode = locale.language.languageCode?.identifier ?? "en"
        let regionCode = locale.region?.identifier ?? "US"

        // Map to our Language enum
        // Try to find exact match first (language + region)
        let fullIdentifier = "\(languageCode)_\(regionCode)"

        // Check common mappings
        switch fullIdentifier {
        case "en_US":
            return Language.englishUS.rawValue
        case "en_GB", "en_UK":
            return Language.englishUK.rawValue
        case "es_ES":
            return Language.spanishSpain.rawValue
        case "es_MX", "es_AR", "es_CO", "es_CL", "es_PE", "es_VE":
            return Language.spanishLatinAmerica.rawValue
        case "es_PR", "es_DO", "es_CU":
            return Language.spanishCaribbean.rawValue
        case "fr_FR", "fr_CA", "fr_BE", "fr_CH":
            return Language.french.rawValue
        case "de_DE", "de_AT", "de_CH":
            return Language.german.rawValue
        case "it_IT", "it_CH":
            return Language.italian.rawValue
        case "pt_BR":
            return Language.portugueseBrazil.rawValue
        case "pt_PT":
            return Language.portuguesePortugal.rawValue
        case "zh_CN", "zh_SG":
            return Language.chineseMandarin.rawValue
        case "zh_TW", "zh_HK":
            return Language.chineseMandarin.rawValue // Could add Cantonese variant
        case "ja_JP":
            return Language.japanese.rawValue
        case "ko_KR":
            return Language.korean.rawValue
        case "ar_SA", "ar_EG", "ar_AE":
            return Language.arabic.rawValue
        case "ru_RU":
            return Language.russian.rawValue
        case "hi_IN":
            return Language.hindi.rawValue
        case "nl_NL", "nl_BE":
            return Language.dutch.rawValue
        case "sv_SE":
            return Language.swedish.rawValue
        case "pl_PL":
            return Language.polish.rawValue
        case "tr_TR":
            return Language.turkish.rawValue
        case "vi_VN":
            return Language.vietnamese.rawValue
        case "th_TH":
            return Language.thai.rawValue
        default:
            // Fallback to language code only
            switch languageCode {
            case "en":
                return Language.englishUS.rawValue
            case "es":
                return Language.spanishLatinAmerica.rawValue
            case "fr":
                return Language.french.rawValue
            case "de":
                return Language.german.rawValue
            case "it":
                return Language.italian.rawValue
            case "pt":
                return Language.portugueseBrazil.rawValue
            case "zh":
                return Language.chineseMandarin.rawValue
            case "ja":
                return Language.japanese.rawValue
            case "ko":
                return Language.korean.rawValue
            case "ar":
                return Language.arabic.rawValue
            case "ru":
                return Language.russian.rawValue
            case "hi":
                return Language.hindi.rawValue
            case "nl":
                return Language.dutch.rawValue
            case "sv":
                return Language.swedish.rawValue
            case "pl":
                return Language.polish.rawValue
            case "tr":
                return Language.turkish.rawValue
            case "vi":
                return Language.vietnamese.rawValue
            case "th":
                return Language.thai.rawValue
            default:
                return "English (US)" // Ultimate fallback
            }
        }
    }
}

// MARK: - Welcome View
struct WelcomeView: View {
    @Binding var name: String
    let onNext: () -> Void

    @State private var isCheckingUsername = false
    @State private var usernameAvailable = true
    @State private var errorMessage = ""

    var isValidUsername: Bool {
        // Username must be 3-20 characters, alphanumeric and underscore only
        let regex = "^[a-zA-Z0-9_]{3,20}$"
        return name.range(of: regex, options: .regularExpression) != nil
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                VStack(spacing: 20) {
                    // Logo with graduation cap and speech bubble
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 120, height: 120)

                        VStack(spacing: -10) {
                            Image(systemName: "graduationcap.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.blue.opacity(0.9))

                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 30)
                                .foregroundColor(.cyan)
                        }
                    }

                    VStack(spacing: 8) {
                        Text("SpeakEasy")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, .cyan.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )

                        Text("AI")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.cyan)
                    }

                    Text("AI-Powered Language Teacher")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Choose a username")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    Text("This will be your public display name")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))

                    TextField("Username", text: $name)
                        .textFieldStyle(RoundedTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .onChange(of: name) { newValue in
                            // Remove spaces and special characters except underscore
                            let filtered = newValue.replacingOccurrences(of: " ", with: "")
                            if filtered != newValue {
                                name = filtered
                            }
                            validateUsername()
                        }

                    // Validation feedback
                    if !name.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: isValidUsername && usernameAvailable ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(isValidUsername && usernameAvailable ? .green : .red)
                                .font(.caption)

                            Text(validationMessage)
                                .font(.caption)
                                .foregroundColor(isValidUsername && usernameAvailable ? .green : .red)
                        }
                        .padding(.horizontal, 4)
                    }

                    Text("3-20 characters, letters, numbers and underscore only")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.horizontal, 32)

                Spacer(minLength: 50)

                Button(action: onNext) {
                    HStack {
                        if isCheckingUsername {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        }
                        Text("Continue")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(isValidUsername && usernameAvailable ? Color.blue : Color.gray)
                    .cornerRadius(12)
                }
                .disabled(!isValidUsername || !usernameAvailable || isCheckingUsername)
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
        }
        .ignoresSafeArea(.keyboard)
    }

    private var validationMessage: String {
        if !isValidUsername {
            if name.count < 3 {
                return "Too short"
            } else if name.count > 20 {
                return "Too long"
            } else {
                return "Invalid characters"
            }
        } else if !usernameAvailable {
            return "Username taken"
        } else {
            return "Username available"
        }
    }

    private func validateUsername() {
        guard isValidUsername else {
            usernameAvailable = false
            return
        }

        // In a real app, check Firebase for username availability
        // For now, we'll simulate with some common names
        let takenUsernames = ["admin", "user", "test", "demo", "speakeasy"]
        usernameAvailable = !takenUsernames.contains(name.lowercased())
    }
}


// MARK: - Rounded TextField Style
struct RoundedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white.opacity(0.2))
            .cornerRadius(12)
            .foregroundColor(.white)
            .font(.body)
    }
}

#Preview {
    OnboardingContainerView()
        .environmentObject(UserProfileViewModel())
}
