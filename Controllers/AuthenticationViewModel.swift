import Foundation
import SwiftUI
import AuthenticationServices

@MainActor
class AuthenticationViewModel: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var error: String?

    private let authService = AuthService.shared

    init() {
        // Check existing authentication
        self.user = authService.currentUser
        self.isAuthenticated = authService.isAuthenticated

        // Observe auth service changes
        setupObservers()
    }

    private func setupObservers() {
        authService.$currentUser
            .assign(to: &$user)

        authService.$isAuthenticated
            .assign(to: &$isAuthenticated)

        authService.$isLoading
            .assign(to: &$isLoading)

        authService.$error
            .assign(to: &$error)
    }

    // MARK: - Google Sign In
    func signInWithGoogle() async {
        isLoading = true
        error = nil

        do {
            let user = try await authService.signInWithGoogle()
            self.user = user
            self.isAuthenticated = true
        } catch {
            self.error = error.localizedDescription
            print("Google Sign In failed: \(error)")
        }

        isLoading = false
    }

    // MARK: - Apple Sign In
    func signInWithApple(authorization: ASAuthorization) async {
        isLoading = true
        error = nil

        do {
            let user = try await authService.signInWithApple(authorization: authorization)
            self.user = user
            self.isAuthenticated = true
        } catch {
            self.error = error.localizedDescription
            print("Apple Sign In failed: \(error)")
        }

        isLoading = false
    }

    // MARK: - Guest Sign In
    func signInAsGuest() async {
        isLoading = true
        error = nil

        do {
            let user = try await authService.signInAsGuest()
            self.user = user
            self.isAuthenticated = true
        } catch {
            self.error = error.localizedDescription
            print("Guest Sign In failed: \(error)")
        }

        isLoading = false
    }

    // MARK: - Sign Out
    func signOut() {
        do {
            try authService.signOut()
            self.user = nil
            self.isAuthenticated = false
            self.error = nil
        } catch {
            self.error = error.localizedDescription
            print("Sign Out failed: \(error)")
        }
    }

    // MARK: - Delete Account
    func deleteAccount() async {
        isLoading = true
        error = nil

        do {
            try await authService.deleteAccount()
            self.user = nil
            self.isAuthenticated = false
        } catch {
            self.error = error.localizedDescription
            print("Delete Account failed: \(error)")
        }

        isLoading = false
    }

    // MARK: - Clear Error
    func clearError() {
        error = nil
    }
}
