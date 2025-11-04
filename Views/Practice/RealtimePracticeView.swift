import SwiftUI

/// Realtime voice practice view with viseme-animated teacher avatar
/// Features:
/// - Viseme-based lip-sync animation
/// - Real-time voice conversation
/// - Chat transcript display
/// - Auto-voice activation
struct RealtimePracticeView: View {
    @StateObject private var vm = RealtimeVoiceViewModel()

    var body: some View {
        VStack(spacing: 16) {
            // Teacher avatar (viseme-ready)
            VisemeTeacherAvatarView(currentViseme: vm.currentViseme, speaking: vm.isSpeaking)
                .frame(width: 220, height: 220)
                .padding(.top, 12)

            Text(vm.status)
                .font(.footnote)
                .foregroundStyle(.secondary)

            ChatTranscriptView(messages: vm.messages)
                .frame(maxHeight: 260)

            HStack(spacing: 12) {
                Button(vm.isConnected ? "Disconnect" : "Connect") {
                    vm.isConnected ? vm.disconnect() : vm.connect()
                }
                .buttonStyle(.borderedProminent)

                Button(vm.isMuted ? "Unmute" : "Mute") {
                    vm.toggleMute()
                }
                .buttonStyle(.bordered)
                .disabled(!vm.isConnected)
            }
            .padding(.bottom, 8)
        }
        .padding(.horizontal, 18)
        .onAppear {
            vm.connect()
            vm.startAutoVoice()
        }
        .onDisappear {
            vm.disconnect()
        }
    }
}

#Preview {
    RealtimePracticeView()
}
