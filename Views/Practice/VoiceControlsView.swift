import SwiftUI

struct VoiceControlsView: View {
    let isRecording: Bool
    let onStartRecording: () -> Void
    let onStopRecording: () -> Void

    @State private var pulseAnimation = false

    var body: some View {
        Button(action: {
            if isRecording {
                onStopRecording()
            } else {
                onStartRecording()
            }
        }) {
            ZStack {
                // Pulse effect when recording
                if isRecording {
                    Circle()
                        .fill(Color.red.opacity(0.3))
                        .frame(width: 50, height: 50)
                        .scaleEffect(pulseAnimation ? 1.3 : 1.0)
                        .opacity(pulseAnimation ? 0 : 1)
                }

                // Microphone icon
                Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(isRecording ? .red : .blue)
            }
        }
        .onChange(of: isRecording) { recording in
            if recording {
                withAnimation(.easeOut(duration: 1.0).repeatForever(autoreverses: false)) {
                    pulseAnimation = true
                }
            } else {
                pulseAnimation = false
            }
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        Text("Not Recording")
            .font(.headline)
        VoiceControlsView(
            isRecording: false,
            onStartRecording: {},
            onStopRecording: {}
        )

        Text("Recording")
            .font(.headline)
        VoiceControlsView(
            isRecording: true,
            onStartRecording: {},
            onStopRecording: {}
        )
    }
    .padding()
}
