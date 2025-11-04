import SwiftUI

/// Animated teacher avatar that opens its mouth based on a 0...1 amplitude value.
struct TalkingAvatarView: View {
    let amplitude: CGFloat

    @State private var smoothedLevel: CGFloat = 0

    var body: some View {
        ZStack(alignment: .center) {
            // Teacher base image
            Image("teacher_base")
                .resizable()
                .scaledToFit()

            // Always show animated mouth since teacher_base image has no mouth
            TalkingAvatarMouth(level: smoothedLevel)
                .offset(y: 18)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .onAppear {
            smoothedLevel = normalizedLevel(from: amplitude)
        }
        .onChange(of: amplitude) { newValue in
            let target = normalizedLevel(from: newValue)
            let smoothing: CGFloat = 0.35
            withAnimation(.easeOut(duration: 0.08)) {
                smoothedLevel += (target - smoothedLevel) * smoothing
            }
        }
    }

    private func normalizedLevel(from amplitude: CGFloat) -> CGFloat {
        let clamped = max(0, min(amplitude, 1))
        let scaled = max(0, min((clamped - 0.02) * 8, 1))
        return scaled
    }
}

private struct TalkingAvatarMouth: View {
    let level: CGFloat

    private var mouthHeight: CGFloat {
        let closed: CGFloat = 6
        let open: CGFloat = 42
        return closed + (open - closed) * level
    }

    var body: some View {
        Capsule()
            .frame(width: 90, height: mouthHeight)
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        Color(red: 0.85, green: 0.2, blue: 0.2),
                        Color(red: 0.65, green: 0.1, blue: 0.1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                Capsule()
                    .stroke(Color.black.opacity(0.15), lineWidth: 1)
            )
            .clipShape(TalkingAvatarMouthMask())
    }
}

private struct TalkingAvatarMouthMask: Shape {
    func path(in rect: CGRect) -> Path {
        Path(
            roundedRect: CGRect(x: rect.midX - 45, y: rect.midY - 30, width: 90, height: 60),
            cornerSize: CGSize(width: 28, height: 28)
        )
    }
}
