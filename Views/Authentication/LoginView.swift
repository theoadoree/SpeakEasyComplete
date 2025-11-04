import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.colorScheme) private var colorScheme
    @State private var showError = false
    @State private var logoScale: CGFloat = 0.8
    @State private var buttonsOffset: CGFloat = 50
    @State private var featuresOpacity: Double = 0

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color(.secondarySystemBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // Branding
                    VStack(spacing: 18) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            AppTheme.Colors.primary.opacity(colorScheme == .dark ? 0.28 : 0.1),
                                            Color(.systemBackground)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 220, height: 220)
                                .shadow(
                                    color: Color.black.opacity(colorScheme == .dark ? 0.35 : 0.12),
                                    radius: 20,
                                    x: 0,
                                    y: 14
                                )
                                .overlay(
                                    Circle()
                                        .stroke(Color(.quaternaryLabel), lineWidth: 1)
                                )

                            Image("Teacher3")
                                .resizable()
                                .renderingMode(.original)
                                .scaledToFit()
                                .frame(width: 180, height: 180)
                        }

                        VStack(spacing: 6) {
                            Image("LogoWords")
                                .resizable()
                                .renderingMode(.original)
                                .scaledToFit()
                                .frame(height: 48)

                            Text("AI-Powered Language Teacher")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(.secondaryLabel))
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, 24)
                    .scaleEffect(logoScale)

                    // Features section
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Why learners love SpeakEasy")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(.label))

                        FeatureRow(
                            icon: "mic.fill",
                            title: "Auto Voice Mode",
                            description: "Hands-free conversation practice",
                            color: AppTheme.Colors.primary
                        )

                        FeatureRow(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "Fluency Analytics",
                            description: "Track your speaking progress",
                            color: AppTheme.Colors.accent
                        )

                        FeatureRow(
                            icon: "sparkles",
                            title: "AI-Powered Lessons",
                            description: "30+ structured learning paths",
                            color: AppTheme.Colors.accentPurple
                        )
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color(.secondarySystemBackground).opacity(colorScheme == .dark ? 0.7 : 0.95))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .stroke(Color(.quaternaryLabel), lineWidth: 1)
                            )
                    )
                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.08), radius: 18, x: 0, y: 12)
                    .opacity(featuresOpacity)

                    // Sign-in buttons
                    VStack(spacing: 14) {
                        // Google Sign-In
                        Button(action: {
                            Task {
                                await authViewModel.signInWithGoogle()
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "g.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.white)

                                Text("Continue with Google")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.white)

                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(AppTheme.Colors.primary)
                            )
                        }
                        .buttonStyle(ScaleButtonStyle())

                        // Apple Sign-In
                        SignInWithAppleButton(.signIn) { request in
                            request.requestedScopes = [.fullName, .email]
                            request.nonce = AuthService.shared.generateNonce()
                        } onCompletion: { result in
                            switch result {
                            case .success(let authorization):
                                Task {
                                    await authViewModel.signInWithApple(authorization: authorization)
                                }
                            case .failure(let error):
                                authViewModel.error = error.localizedDescription
                                showError = true
                            }
                        }
                        .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                        .frame(height: 56)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                        // Guest Sign-In
                        Button(action: {
                            Task {
                                await authViewModel.signInAsGuest()
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "person.fill.questionmark")
                                    .font(.system(size: 20))
                                    .foregroundColor(AppTheme.Colors.primary)

                                Text("Try as Guest")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(AppTheme.Colors.primary)

                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(AppTheme.Colors.primary.opacity(0.08))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(AppTheme.Colors.primary.opacity(0.7), lineWidth: 1)
                            )
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color(.systemBackground).opacity(colorScheme == .dark ? 0.85 : 1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .stroke(Color(.quaternaryLabel), lineWidth: 1)
                            )
                    )
                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.35 : 0.1), radius: 20, x: 0, y: 14)
                    .offset(y: buttonsOffset)

                    // Terms and privacy
                    Text("By continuing, you agree to our\nTerms of Service and Privacy Policy")
                        .font(.caption)
                        .foregroundColor(Color(.tertiaryLabel))
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
                .padding(.horizontal, 28)
                .padding(.top, 60)
                .padding(.bottom, 56)
                .frame(maxWidth: 520)
                .frame(maxWidth: .infinity)
            }

            // Loading overlay
            if authViewModel.isLoading {
                LoadingView()
            }
        }
        .alert("Sign In Error", isPresented: $showError) {
            Button("OK") {
                authViewModel.clearError()
            }
        } message: {
            if let error = authViewModel.error {
                Text(error)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                logoScale = 1.0
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                buttonsOffset = 0
            }
            withAnimation(.easeOut(duration: 0.8).delay(0.4)) {
                featuresOpacity = 1.0
            }
        }
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    @Environment(\.colorScheme) private var colorScheme
    let icon: String
    let title: String
    let description: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(colorScheme == .dark ? 0.25 : 0.12))
                    .frame(width: 52, height: 52)

                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(.label))

                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(Color(.secondaryLabel))
            }

            Spacer(minLength: 0)
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationViewModel())
}
