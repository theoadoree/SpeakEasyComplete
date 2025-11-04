import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var profileViewModel: UserProfileViewModel

    @State private var onboardingComplete: Bool = false

    var body: some View {
        ZStack {
            // Background layer - prevents black screen
            Color(.systemBackground)
                .ignoresSafeArea()

            Group {
                if !authViewModel.isAuthenticated {
                    // Not authenticated - show login
                    LoginView()
                } else if !onboardingComplete {
                    // Authenticated but no profile - show onboarding
                    OnboardingContainerView()
                } else {
                    // Authenticated and onboarded - show main app
                    TabBarView()
                }
            }
        }
        .onAppear {
            safeCheckOnboardingStatus()
        }
        .onChange(of: authViewModel.isAuthenticated) { authenticated in
            if authenticated {
                safeCheckOnboardingStatus()
            } else {
                onboardingComplete = false
            }
        }
        .onChange(of: profileViewModel.userProfile) { profile in
            if profile != nil {
                onboardingComplete = true
                StorageService.shared.setOnboardingComplete(true)
            }
        }
    }

    private func safeCheckOnboardingStatus() {
        // Check if user profile exists (existing user)
        if let _ = profileViewModel.userProfile {
            onboardingComplete = true
            StorageService.shared.setOnboardingComplete(true)
        } else {
            // For new users, check if they've completed onboarding
            // This will be false for first-time sign ups
            onboardingComplete = StorageService.shared.isOnboardingComplete()

            // If user is authenticated but no profile exists and onboarding flag is set,
            // reset the flag (they may have deleted their account)
            if authViewModel.isAuthenticated && onboardingComplete {
                onboardingComplete = false
                StorageService.shared.setOnboardingComplete(false)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthenticationViewModel())
        .environmentObject(UserProfileViewModel())
}
