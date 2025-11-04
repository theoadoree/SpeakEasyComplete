import Foundation
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices
import CryptoKit
import UIKit

class AuthService: ObservableObject {
    static let shared = AuthService()

    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var error: String?

    private init() {
        // Check if user is already authenticated
        if let firebaseUser = Auth.auth().currentUser {
            self.currentUser = User.from(firebaseUser: firebaseUser)
            self.isAuthenticated = true
        }
    }

    // MARK: - Google Sign In
    @MainActor
    func signInWithGoogle() async throws -> User {
        isLoading = true
        error = nil

        defer { isLoading = false }

        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthError.configurationError
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            throw AuthError.noViewController
        }

        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)

        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthError.invalidCredential
        }

        let accessToken = result.user.accessToken.tokenString
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

        let authResult = try await Auth.auth().signIn(with: credential)
        let user = User.from(firebaseUser: authResult.user)

        self.currentUser = user
        self.isAuthenticated = true

        return user
    }

    // MARK: - Apple Sign In
    @MainActor
    func signInWithApple(authorization: ASAuthorization) async throws -> User {
        isLoading = true
        error = nil

        defer { isLoading = false }

        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            throw AuthError.invalidCredential
        }

        guard let nonce = currentNonce else {
            throw AuthError.invalidState
        }

        guard let appleIDToken = appleIDCredential.identityToken else {
            throw AuthError.invalidCredential
        }

        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            throw AuthError.invalidCredential
        }

        let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                   idToken: idTokenString,
                                                   rawNonce: nonce)

        let authResult = try await Auth.auth().signIn(with: credential)
        let user = User.from(firebaseUser: authResult.user)

        self.currentUser = user
        self.isAuthenticated = true

        return user
    }

    // MARK: - Guest Sign In
    @MainActor
    func signInAsGuest() async throws -> User {
        isLoading = true
        error = nil

        defer { isLoading = false }

        let authResult = try await Auth.auth().signInAnonymously()
        let user = User(
            id: authResult.user.uid,
            uid: authResult.user.uid,
            email: nil,
            name: "Guest",
            provider: .guest,
            imageUrl: nil,
            createdAt: Date()
        )

        self.currentUser = user
        self.isAuthenticated = true

        return user
    }

    // MARK: - Sign Out
    @MainActor
    func signOut() throws {
        try Auth.auth().signOut()
        GIDSignIn.sharedInstance.signOut()

        self.currentUser = nil
        self.isAuthenticated = false
    }

    // MARK: - Delete Account
    @MainActor
    func deleteAccount() async throws {
        guard let firebaseUser = Auth.auth().currentUser else {
            throw AuthError.notAuthenticated
        }

        do {
            // Attempt to delete the account
            try await firebaseUser.delete()

            self.currentUser = nil
            self.isAuthenticated = false
        } catch let error as NSError {
            // If deletion fails due to requiring recent authentication, throw a more helpful error
            if error.code == AuthErrorCode.requiresRecentLogin.rawValue {
                throw AuthError.requiresRecentLogin
            }
            throw error
        }
    }

    // MARK: - Apple Sign In Nonce
    private var currentNonce: String?

    func generateNonce() -> String {
        let nonce = randomNonceString()
        currentNonce = nonce
        return sha256(nonce)
    }

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - Auth Errors
enum AuthError: LocalizedError {
    case configurationError
    case noViewController
    case invalidCredential
    case invalidState
    case notAuthenticated
    case requiresRecentLogin

    var errorDescription: String? {
        switch self {
        case .configurationError:
            return "Firebase configuration error"
        case .noViewController:
            return "No view controller available"
        case .invalidCredential:
            return "Invalid authentication credential"
        case .invalidState:
            return "Invalid authentication state"
        case .notAuthenticated:
            return "User not authenticated"
        case .requiresRecentLogin:
            return "This operation requires recent authentication. Please sign out and sign back in, then try again."
        }
    }
}

// MARK: - User Extension
extension User {
    static func from(firebaseUser: FirebaseAuth.User) -> User {
        let provider: AuthProvider
        if firebaseUser.isAnonymous {
            provider = .guest
        } else if let providerData = firebaseUser.providerData.first {
            switch providerData.providerID {
            case "google.com":
                provider = .google
            case "apple.com":
                provider = .apple
            default:
                provider = .guest
            }
        } else {
            provider = .guest
        }

        return User(
            id: firebaseUser.uid,
            uid: firebaseUser.uid,
            email: firebaseUser.email,
            name: firebaseUser.displayName ?? "User",
            provider: provider,
            imageUrl: firebaseUser.photoURL?.absoluteString,
            createdAt: firebaseUser.metadata.creationDate ?? Date()
        )
    }
}
