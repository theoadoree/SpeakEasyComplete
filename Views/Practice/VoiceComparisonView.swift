import SwiftUI
import AVFoundation
import Accelerate

struct VoiceComparisonView: View {
    let targetPhrase: String
    @State private var nativeAudioURL: URL?
    @State private var isRecording = false
    @State private var userAudioURL: URL?
    @State private var comparisonResult: ComparisonResult?
    @State private var showWaveform = false
    @State private var nativeWaveform: [Float] = []
    @State private var userWaveform: [Float] = []
    @State private var isPlayingNative = false
    @State private var isPlayingUser = false
    @State private var recordingTimer: Timer?
    @State private var recordingDuration: TimeInterval = 0

    @StateObject private var audioRecorder = AudioRecorder()
    @StateObject private var audioPlayer = AudioPlayer()
    @EnvironmentObject var openAIService: OpenAIService

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Text("Pronunciation Practice")
                        .font(.system(size: 28, weight: .bold))

                    Text(targetPhrase)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "F2F2F7"))
                        )
                }
                .padding(.horizontal)

                // Native Speaker Section
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "person.wave.2.fill")
                            .foregroundColor(Color(hex: "007AFF"))
                        Text("Native Speaker")
                            .font(.system(size: 16, weight: .semibold))
                        Spacer()
                    }

                    // Native audio waveform
                    if !nativeWaveform.isEmpty {
                        WaveformView(samples: nativeWaveform, color: Color(hex: "007AFF"))
                            .frame(height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(hex: "007AFF").opacity(0.05))
                            )
                    }

                    Button(action: playNativeAudio) {
                        HStack {
                            Image(systemName: isPlayingNative ? "stop.fill" : "play.fill")
                            Text(isPlayingNative ? "Stop" : "Play Native")
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color(hex: "007AFF"))
                        .cornerRadius(8)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                )
                .padding(.horizontal)

                // Your Recording Section
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "mic.fill")
                            .foregroundColor(Color(hex: "34C759"))
                        Text("Your Recording")
                            .font(.system(size: 16, weight: .semibold))
                        Spacer()
                    }

                    // User audio waveform
                    if !userWaveform.isEmpty {
                        WaveformView(samples: userWaveform, color: Color(hex: "34C759"))
                            .frame(height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(hex: "34C759").opacity(0.05))
                            )
                    }

                    // Recording controls
                    HStack(spacing: 16) {
                        Button(action: toggleRecording) {
                            HStack {
                                Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                                    .font(.system(size: 20))
                                Text(isRecording ? "Stop" : "Record")
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(isRecording ? Color(hex: "FF3B30") : Color(hex: "34C759"))
                            .cornerRadius(8)
                        }

                        if userAudioURL != nil && !isRecording {
                            Button(action: playUserAudio) {
                                HStack {
                                    Image(systemName: isPlayingUser ? "stop.fill" : "play.fill")
                                    Text(isPlayingUser ? "Stop" : "Play")
                                }
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(hex: "34C759"))
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(hex: "34C759"), lineWidth: 2)
                                )
                            }
                        }
                    }

                    if isRecording {
                        Text(String(format: "Recording: %.1fs", recordingDuration))
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                )
                .padding(.horizontal)

                // Comparison Results
                if let result = comparisonResult {
                    ComparisonResultView(result: result)
                        .padding(.horizontal)
                        .transition(.scale.combined(with: .opacity))
                }

                // Action Buttons
                VStack(spacing: 12) {
                    if userAudioURL != nil {
                        Button(action: compareRecordings) {
                            HStack {
                                Image(systemName: "waveform.path.ecg")
                                Text("Compare Pronunciation")
                            }
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "007AFF"), Color(hex: "0051D5")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                        }
                    }

                    Button(action: resetRecording) {
                        Text("Try Again")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "007AFF"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(hex: "007AFF"), lineWidth: 2)
                            )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .background(Color(hex: "F2F2F7"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadNativeAudio()
        }
    }

    // MARK: - Audio Functions

    private func loadNativeAudio() {
        // Generate native speaker audio
        Task {
            do {
                let audioData = try await openAIService.synthesizeSpeech(
                    text: targetPhrase,
                    voice: "nova" // Native-like voice
                )

                let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let audioURL = documentsPath.appendingPathComponent("native_\(UUID().uuidString).m4a")

                try audioData.write(to: audioURL)
                nativeAudioURL = audioURL

                // Generate waveform
                nativeWaveform = generateWaveform(from: audioURL)
            } catch {
                print("Error generating native audio: \(error)")
            }
        }
    }

    private func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        audioRecorder.startRecording()
        isRecording = true
        recordingDuration = 0

        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            recordingDuration += 0.1
        }
    }

    private func stopRecording() {
        recordingTimer?.invalidate()
        recordingTimer = nil

        if let url = audioRecorder.stopRecording() {
            userAudioURL = url
            userWaveform = generateWaveform(from: url)
        }
        isRecording = false
    }

    private func playNativeAudio() {
        guard let url = nativeAudioURL else { return }

        if isPlayingNative {
            audioPlayer.stop()
            isPlayingNative = false
        } else {
            audioPlayer.play(url: url) {
                isPlayingNative = false
            }
            isPlayingNative = true
        }
    }

    private func playUserAudio() {
        guard let url = userAudioURL else { return }

        if isPlayingUser {
            audioPlayer.stop()
            isPlayingUser = false
        } else {
            audioPlayer.play(url: url) {
                isPlayingUser = false
            }
            isPlayingUser = true
        }
    }

    private func compareRecordings() {
        guard let userURL = userAudioURL, let nativeURL = nativeAudioURL else { return }

        // Analyze recordings and generate comparison
        let analyzer = PronunciationAnalyzer()
        let result = analyzer.compare(userAudio: userURL, nativeAudio: nativeURL, targetPhrase: targetPhrase)

        withAnimation(.spring()) {
            comparisonResult = result
        }
    }

    private func resetRecording() {
        userAudioURL = nil
        userWaveform = []
        comparisonResult = nil
        recordingDuration = 0
    }

    private func generateWaveform(from url: URL) -> [Float] {
        // Simplified waveform generation
        var samples: [Float] = []

        do {
            let file = try AVAudioFile(forReading: url)
            let format = AVAudioFormat(standardFormatWithSampleRate: file.fileFormat.sampleRate, channels: 1)!
            let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 1024)!

            while file.framePosition < file.length {
                try file.read(into: buffer)
                let floatArray = Array(UnsafeBufferPointer(start: buffer.floatChannelData?[0], count: Int(buffer.frameLength)))
                samples.append(contentsOf: floatArray)
            }

            // Downsample for visualization
            let targetSampleCount = 100
            let downsampleRatio = max(1, samples.count / targetSampleCount)
            var downsampled: [Float] = []

            for i in stride(from: 0, to: samples.count, by: downsampleRatio) {
                let endIndex = min(i + downsampleRatio, samples.count)
                let chunk = Array(samples[i..<endIndex])
                let rms = sqrt(chunk.map { $0 * $0 }.reduce(0, +) / Float(chunk.count))
                downsampled.append(rms)
            }

            return downsampled
        } catch {
            print("Error generating waveform: \(error)")
            return []
        }
    }
}

// MARK: - Waveform View
struct WaveformView: View {
    let samples: [Float]
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 2) {
                ForEach(0..<samples.count, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color)
                        .frame(width: max(1, (geometry.size.width - CGFloat(samples.count * 2)) / CGFloat(samples.count)),
                               height: CGFloat(samples[index]) * geometry.size.height)
                }
            }
        }
    }
}

// MARK: - Comparison Result View
struct ComparisonResultView: View {
    let result: ComparisonResult

    var scoreColor: Color {
        if result.overallScore >= 90 { return Color(hex: "34C759") }
        else if result.overallScore >= 75 { return Color(hex: "FF9500") }
        else { return Color(hex: "FF3B30") }
    }

    var body: some View {
        VStack(spacing: 20) {
            // Overall Score
            VStack(spacing: 8) {
                Text("Pronunciation Score")
                    .font(.system(size: 18, weight: .semibold))

                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 10)
                        .frame(width: 120, height: 120)

                    Circle()
                        .trim(from: 0, to: CGFloat(result.overallScore) / 100)
                        .stroke(scoreColor, lineWidth: 10)
                        .frame(width: 120, height: 120)
                        .rotationEffect(Angle(degrees: -90))
                        .animation(.spring(), value: result.overallScore)

                    VStack {
                        Text("\(Int(result.overallScore))")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(scoreColor)
                        Text("out of 100")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
            }

            // Detailed Metrics
            VStack(spacing: 12) {
                MetricRow(label: "Rhythm", value: result.rhythmAccuracy, icon: "metronome")
                MetricRow(label: "Intonation", value: result.intonationAccuracy, icon: "waveform")
                MetricRow(label: "Clarity", value: result.clarityScore, icon: "mic")
                MetricRow(label: "Speed", value: result.speedSimilarity, icon: "speedometer")
            }

            // Feedback
            if !result.feedback.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tips for Improvement")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    ForEach(result.feedback, id: \.self) { tip in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "FF9500"))
                                .padding(.top, 2)

                            Text(tip)
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "FFF9E6"))
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        )
    }
}

// MARK: - Metric Row
struct MetricRow: View {
    let label: String
    let value: Double
    let icon: String

    var color: Color {
        if value >= 90 { return Color(hex: "34C759") }
        else if value >= 75 { return Color(hex: "FF9500") }
        else { return Color(hex: "FF3B30") }
    }

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 24)

            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.gray)

            Spacer()

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * (value / 100), height: 8)
                }
            }
            .frame(width: 100, height: 8)

            Text("\(Int(value))%")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(color)
                .frame(width: 35, alignment: .trailing)
        }
    }
}

// MARK: - Audio Recorder
class AudioRecorder: ObservableObject {
    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL?

    func startRecording() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, mode: .default)
        try? session.setActive(true)

        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentsPath.appendingPathComponent("recording_\(UUID().uuidString).m4a")
        recordingURL = audioFilename

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        audioRecorder = try? AVAudioRecorder(url: audioFilename, settings: settings)
        audioRecorder?.record()
    }

    func stopRecording() -> URL? {
        audioRecorder?.stop()
        return recordingURL
    }
}

// MARK: - Audio Player
class AudioPlayer: ObservableObject {
    private var audioPlayer: AVAudioPlayer?

    func play(url: URL, completion: @escaping () -> Void) {
        audioPlayer = try? AVAudioPlayer(contentsOf: url)
        audioPlayer?.play()

        DispatchQueue.main.asyncAfter(deadline: .now() + (audioPlayer?.duration ?? 0)) {
            completion()
        }
    }

    func stop() {
        audioPlayer?.stop()
    }
}

// MARK: - Pronunciation Analyzer
struct PronunciationAnalyzer {
    func compare(userAudio: URL, nativeAudio: URL, targetPhrase: String) -> ComparisonResult {
        // In a real implementation, this would use advanced audio analysis
        // For now, return mock results
        let score = Double.random(in: 70...95)

        var feedback: [String] = []
        if score < 80 {
            feedback.append("Try to match the native speaker's rhythm more closely")
        }
        if score < 85 {
            feedback.append("Focus on the intonation pattern, especially at the end of the phrase")
        }
        if score < 90 {
            feedback.append("Your pronunciation is good! Keep practicing for more natural flow")
        }

        return ComparisonResult(
            overallScore: score,
            rhythmAccuracy: Double.random(in: 65...95),
            intonationAccuracy: Double.random(in: 70...98),
            clarityScore: Double.random(in: 75...95),
            speedSimilarity: Double.random(in: 80...100),
            feedback: feedback
        )
    }
}

// MARK: - Comparison Result Model
struct ComparisonResult {
    let overallScore: Double
    let rhythmAccuracy: Double
    let intonationAccuracy: Double
    let clarityScore: Double
    let speedSimilarity: Double
    let feedback: [String]
}

#Preview {
    NavigationView {
        VoiceComparisonView(
            targetPhrase: "Hello, how are you today?"
        )
        .environmentObject(OpenAIService.shared)
    }
}