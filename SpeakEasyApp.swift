import SwiftUI

@main
struct SpeakEasyApp: App {
    @AppStorage("appTheme") private var appTheme: String = "system"
    @State private var showLaunchScreen = true
    @State private var globalError: GlobalError?
    @State private var showErrorAlert = false

    init() {
        // Set up global error handler
        setupGlobalErrorHandler()
    }

    @StateObject private var authViewModel = AuthenticationViewModel()
    @StateObject private var userProfileViewModel = UserProfileViewModel()
    @StateObject private var conversationViewModel = ConversationViewModel()

    private func setupGlobalErrorHandler() {
        // Catch uncaught exceptions
        NSSetUncaughtExceptionHandler { exception in
            print("Uncaught exception: \(exception)")
            print("Stack trace: \(exception.callStackSymbols)")
            // Save error for display
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .globalErrorOccurred,
                    object: GlobalError(
                        title: "Application Error",
                        message: exception.reason ?? "An unexpected error occurred",
                        canRecover: true
                    )
                )
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                ErrorBoundaryView {
                    ContentView()
                        .environmentObject(authViewModel)
                        .environmentObject(userProfileViewModel)
                        .environmentObject(conversationViewModel)
                        .preferredColorScheme(preferredColorScheme)
                }
                .opacity(showLaunchScreen ? 0 : 1)
                .onReceive(NotificationCenter.default.publisher(for: .globalErrorOccurred)) { notification in
                    if let error = notification.object as? GlobalError {
                        globalError = error
                        showErrorAlert = true
                    }
                }
                .alert("Error", isPresented: $showErrorAlert, presenting: globalError) { error in
                    Button("Retry") {
                        showErrorAlert = false
                        globalError = nil
                        // Try to recover
                        showLaunchScreen = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation {
                                showLaunchScreen = false
                            }
                        }
                    }
                    Button("OK", role: .cancel) {
                        showErrorAlert = false
                        globalError = nil
                    }
                } message: { error in
                    Text(error.message)
                }

                // Launch screen overlay
                if showLaunchScreen {
                    // Modern launch screen matching new design
                    ZStack {
                        // Clean white background
                        Color.white
                            .ignoresSafeArea()

                        VStack(spacing: 30) {
                            Spacer()

                            // Logo with graduation cap and speech bubble
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "007AFF").opacity(0.1))
                                    .frame(width: 140, height: 140)

                                VStack(spacing: -15) {
                                    Image(systemName: "graduationcap.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 60, height: 60)
                                        .foregroundColor(Color(hex: "007AFF"))

                                    Image(systemName: "bubble.left.and.bubble.right.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 35)
                                        .foregroundColor(Color(hex: "34C759"))
                                        .offset(y: 10)
                                }
                            }

                            // App Name
                            VStack(spacing: 8) {
                                HStack(spacing: 8) {
                                    Text("SpeakEasy")
                                        .font(.system(size: 40, weight: .bold, design: .rounded))
                                        .foregroundColor(.black)

                                    Text("AI")
                                        .font(.system(size: 28, weight: .bold, design: .rounded))
                                        .foregroundColor(Color(hex: "007AFF"))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color(hex: "007AFF").opacity(0.1))
                                        )
                                }

                                Text("Loading your fluency journey...")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                            }

                            // Loading indicator
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "007AFF")))
                                .scaleEffect(1.5)
                                .padding(.top, 20)

                            Spacer()
                        }
                    }
                    .transition(.opacity)
                    .zIndex(1)
                }
            }
            .onAppear {
                // Hide launch screen after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        showLaunchScreen = false
                        print("Launch screen dismissed")
                    }
                }
            }
        }
    }

    // Computed property for color scheme preference
    private var preferredColorScheme: ColorScheme? {
        switch appTheme {
        case "light":
            return .light
        case "dark":
            return .dark
        default:
            return nil // System default
        }
    }
}

// MARK: - Global Error Model
struct GlobalError {
    let title: String
    let message: String
    let canRecover: Bool
}

// MARK: - Error Boundary View
struct ErrorBoundaryView<Content: View>: View {
    @State private var error: Error?
    @State private var showError = false
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        ZStack {
            Group {
                if showError {
                    ErrorRecoveryView(
                        error: error?.localizedDescription ?? "Unknown error occurred",
                        onRetry: {
                            showError = false
                            error = nil
                        },
                        onDismiss: {
                            showError = false
                            error = nil
                        }
                    )
                } else {
                    content()
                }
            }
        }
        .onAppear {
            // Set up error observation
            NotificationCenter.default.addObserver(
                forName: .viewErrorOccurred,
                object: nil,
                queue: .main
            ) { notification in
                if let err = notification.object as? Error {
                    error = err
                    showError = true
                }
            }
        }
    }
}

// MARK: - Error Recovery View
struct ErrorRecoveryView: View {
    let error: String
    let onRetry: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)

            Text("Oops! Something went wrong")
                .font(.title2)
                .fontWeight(.bold)

            Text(error)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            VStack(spacing: 12) {
                Button(action: onRetry) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Try Again")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }

                Button(action: onDismiss) {
                    Text("Dismiss")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }
}
