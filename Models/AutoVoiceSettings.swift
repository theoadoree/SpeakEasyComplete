import Foundation

struct AutoVoiceSettings {
    var isEnabled: Bool = false
    var autoStartRecording: Bool = true
    var speakingRate: Float = 0.5
    var speechRate: Float = 0.5
    var pitchMultiplier: Float = 1.0
    var responseDelay: TimeInterval = 0.5
    var listeningTimeout: TimeInterval = 3.0
    var voiceLanguage: String = "en-US"
    var enableHapticFeedback: Bool = true
    var enableVisualFeedback: Bool = true
    var silenceThreshold: TimeInterval = 1.5
    var pauseThreshold: TimeInterval = 1.5
    var provideFeedbackDuringConversation: Bool = false
    var echoModeEnabled: Bool = false
    var interruptionAllowed: Bool = true
    var voiceDetectionSensitivity: Double = 0.5
    var useNaturalPauses: Bool = true
    var backgroundNoiseReduction: Bool = true
    var autoCorrectPronunciation: Bool = false
    var recordingQuality: RecordingQuality = .high

    enum RecordingQuality: String, CaseIterable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        case maximum = "Maximum"
    }
}

