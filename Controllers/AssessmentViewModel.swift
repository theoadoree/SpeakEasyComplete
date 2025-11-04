import Foundation
import SwiftUI

@MainActor
class AssessmentViewModel: ObservableObject {
    @Published var isAssessing = false
    @Published var assessmentResult: AssessmentResult?
    @Published var showResult = false
    @Published var error: String?

    private let assessmentService = AssessmentService.shared
    private let storageService = StorageService.shared

    // MARK: - Perform Assessment
    func performAssessment(messages: [Message], targetLanguage: String) async {
        isAssessing = true
        error = nil

        do {
            let result = try await assessmentService.evaluateLevel(
                messages: messages,
                targetLanguage: targetLanguage
            )

            self.assessmentResult = result
            self.showResult = true

            // Save result
            try storageService.saveAssessmentResult(result)

        } catch {
            self.error = "Assessment failed: \(error.localizedDescription)"
        }

        isAssessing = false
    }

    // MARK: - Load Saved Assessment
    func loadSavedAssessment() {
        assessmentResult = storageService.getAssessmentResult()
    }

    // MARK: - Should Trigger Assessment
    func shouldTriggerAssessment(messages: [Message], userProfile: UserProfile) -> Bool {
        return assessmentService.shouldTriggerAssessment(
            messages: messages,
            assessmentPending: userProfile.assessmentPending
        )
    }

    // MARK: - Get Level Description
    func getLevelDescription(_ level: UserProfile.CEFRLevel) -> String {
        return assessmentService.getLevelDescription(level)
    }

    // MARK: - Get Progress Percentage
    func getProgressPercentage(_ level: UserProfile.CEFRLevel) -> Double {
        return assessmentService.getProgressPercentage(level)
    }

    // MARK: - Dismiss Result
    func dismissResult() {
        showResult = false
    }

    // MARK: - Clear Assessment
    func clearAssessment() {
        assessmentResult = nil
        showResult = false
        storageService.deleteAssessmentResult()
    }

    // MARK: - Clear Error
    func clearError() {
        error = nil
    }
}
