import Foundation
import SwiftUI

@MainActor
class UserProfileViewModel: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var isLoading = false
    @Published var error: String?

    private let storageService = StorageService.shared
    private let assessmentService = AssessmentService.shared

    init() {
        loadProfile()
    }

    // MARK: - Load Profile
    func loadProfile() {
        userProfile = storageService.getUserProfile()
    }

    // MARK: - Save Profile
    func saveProfile(_ profile: UserProfile) {
        do {
            try storageService.saveUserProfile(profile)
            self.userProfile = profile
        } catch {
            self.error = "Failed to save profile: \(error.localizedDescription)"
        }
    }

    // MARK: - Update Profile
    func updateProfile(
        name: String? = nil,
        nativeLanguage: String? = nil,
        targetLanguage: String? = nil,
        level: UserProfile.CEFRLevel? = nil,
        interests: [String]? = nil,
        assessmentPending: Bool? = nil
    ) {
        guard var profile = userProfile else {
            self.error = "No profile to update"
            return
        }

        if let name = name {
            profile.name = name
        }
        if let nativeLanguage = nativeLanguage {
            profile.nativeLanguage = nativeLanguage
        }
        if let targetLanguage = targetLanguage {
            profile.targetLanguage = targetLanguage
        }
        if let level = level {
            profile.level = level
        }
        if let interests = interests {
            profile.interests = interests
        }
        if let assessmentPending = assessmentPending {
            profile.assessmentPending = assessmentPending
        }

        saveProfile(profile)
    }

    // MARK: - Create Profile (Onboarding)
    func createProfile(
        name: String,
        nativeLanguage: String,
        targetLanguage: String,
        interests: [String]
    ) {
        let profile = UserProfile(
            name: name,
            nativeLanguage: nativeLanguage,
            targetLanguage: targetLanguage,
            level: .unknown,
            interests: interests,
            assessmentPending: true,
            createdAt: Date()
        )

        saveProfile(profile)
    }

    // MARK: - Update Level After Assessment
    func updateLevelFromAssessment(_ assessmentResult: AssessmentResult) {
        do {
            // Save assessment result
            try storageService.saveAssessmentResult(assessmentResult)

            // Update profile with new level
            updateProfile(level: assessmentResult.level, assessmentPending: false)
        } catch {
            self.error = "Failed to save assessment: \(error.localizedDescription)"
        }
    }

    // MARK: - Get Level Description
    func getLevelDescription() -> String {
        guard let profile = userProfile else {
            return "Not yet assessed"
        }
        return assessmentService.getLevelDescription(profile.level)
    }

    // MARK: - Get Progress Percentage
    func getProgressPercentage() -> Double {
        guard let profile = userProfile else {
            return 0.0
        }
        return assessmentService.getProgressPercentage(profile.level)
    }

    // MARK: - Get Next Level
    func getNextLevel() -> UserProfile.CEFRLevel? {
        guard let profile = userProfile else {
            return nil
        }
        return assessmentService.getNextLevel(profile.level)
    }

    // MARK: - Delete Profile
    func deleteProfile() {
        storageService.deleteUserProfile()
        self.userProfile = nil
    }

    // MARK: - Clear Error
    func clearError() {
        error = nil
    }
}
