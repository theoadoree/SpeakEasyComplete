import SwiftUI

struct AutoVoiceSettingsView: View {
    @StateObject private var autoVoiceService = AutoVoiceService.shared
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                // Main Settings
                Section(header: Text("Auto Voice Mode")) {
                    Toggle("Enable Auto Voice", isOn: $autoVoiceService.settings.isEnabled)
                        .tint(Color(hex: "007AFF"))

                    Toggle("Auto-Start Recording", isOn: $autoVoiceService.settings.autoStartRecording)
                        .tint(Color(hex: "007AFF"))

                    Toggle("Allow Interruption", isOn: $autoVoiceService.settings.interruptionAllowed)
                        .tint(Color(hex: "007AFF"))
                }

                // Voice Detection
                Section(header: Text("Voice Detection")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sensitivity")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)

                        HStack {
                            Text("Low")
                                .font(.system(size: 12))
                            Slider(value: $autoVoiceService.settings.voiceDetectionSensitivity,
                                  in: 0...1)
                                .tint(Color(hex: "007AFF"))
                            Text("High")
                                .font(.system(size: 12))
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Pause Threshold")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)

                        HStack {
                            Text("0.5s")
                                .font(.system(size: 12))
                            Slider(value: $autoVoiceService.settings.pauseThreshold,
                                  in: 0.5...3.0,
                                  step: 0.5)
                                .tint(Color(hex: "007AFF"))
                            Text("3.0s")
                                .font(.system(size: 12))
                        }

                        Text("\(String(format: "%.1f", autoVoiceService.settings.pauseThreshold)) seconds")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }

                // Speech Settings
                Section(header: Text("Speech Output")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Speech Rate")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)

                        HStack {
                            Text("Slow")
                                .font(.system(size: 12))
                            Slider(value: $autoVoiceService.settings.speechRate,
                                  in: 0.5...2.0)
                                .tint(Color(hex: "007AFF"))
                            Text("Fast")
                                .font(.system(size: 12))
                        }

                        Text("\(String(format: "%.1fx", autoVoiceService.settings.speechRate))")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Voice Pitch")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)

                        HStack {
                            Text("Low")
                                .font(.system(size: 12))
                            Slider(value: $autoVoiceService.settings.pitchMultiplier,
                                  in: 0.5...1.5)
                                .tint(Color(hex: "007AFF"))
                            Text("High")
                                .font(.system(size: 12))
                        }
                    }

                    Toggle("Use Natural Pauses", isOn: $autoVoiceService.settings.useNaturalPauses)
                        .tint(Color(hex: "007AFF"))
                }

                // Advanced Features
                Section(header: Text("Advanced Features")) {
                    Toggle("Background Noise Reduction", isOn: $autoVoiceService.settings.backgroundNoiseReduction)
                        .tint(Color(hex: "007AFF"))

                    Toggle("Auto-Correct Pronunciation", isOn: $autoVoiceService.settings.autoCorrectPronunciation)
                        .tint(Color(hex: "007AFF"))

                    Toggle("Provide Live Feedback", isOn: $autoVoiceService.settings.provideFeedbackDuringConversation)
                        .tint(Color(hex: "007AFF"))

                    Toggle("Echo Mode (Shadow Speaking)", isOn: $autoVoiceService.settings.echoModeEnabled)
                        .tint(Color(hex: "007AFF"))
                }

                // Recording Quality
                Section(header: Text("Recording Quality")) {
                    Picker("Quality", selection: $autoVoiceService.settings.recordingQuality) {
                        Text("Low").tag(AutoVoiceSettings.RecordingQuality.low)
                        Text("Medium").tag(AutoVoiceSettings.RecordingQuality.medium)
                        Text("High").tag(AutoVoiceSettings.RecordingQuality.high)
                        Text("Maximum").tag(AutoVoiceSettings.RecordingQuality.maximum)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                // Tips
                Section(header: Text("Tips")) {
                    VStack(alignment: .leading, spacing: 12) {
                        TipView(
                            icon: "mic.fill",
                            text: "Speak clearly and at a natural pace for best results"
                        )

                        TipView(
                            icon: "speaker.wave.3.fill",
                            text: "Use headphones to avoid audio feedback"
                        )

                        TipView(
                            icon: "waveform",
                            text: "Practice in a quiet environment for better recognition"
                        )
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Auto Voice Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    saveSettings()
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(Color(hex: "007AFF"))
            )
        }
    }

    private func saveSettings() {
        // Save settings to UserDefaults or storage
        // This would be implemented with actual persistence
    }
}

// MARK: - Tip View
struct TipView: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "007AFF"))
                .frame(width: 24)

            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    AutoVoiceSettingsView()
}