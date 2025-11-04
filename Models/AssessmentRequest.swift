import Foundation

// Assessment Request Model (sent to backend)
struct AssessmentRequest: Codable {
    let responses: [String]
    let targetLanguage: String
}
