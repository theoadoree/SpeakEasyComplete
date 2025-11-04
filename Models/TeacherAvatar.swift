import SwiftUI

// MARK: - Animated Teacher Avatar
struct TeacherAvatar: View {
    @State private var isAnimating = false
    @State private var isSpeaking = false
    @State private var eyeBlinkOffset: CGFloat = 0

    let size: CGFloat
    let emotion: TeacherEmotion

    enum TeacherEmotion {
        case neutral
        case happy
        case encouraging
        case thinking
        case excited

        var mouthShape: String {
            switch self {
            case .neutral: return "line.horizontal.3"
            case .happy: return "face.smiling"
            case .encouraging: return "hand.thumbsup.fill"
            case .thinking: return "brain.head.profile"
            case .excited: return "sparkles"
            }
        }

        var color: Color {
            switch self {
            case .neutral: return .blue
            case .happy: return .green
            case .encouraging: return .orange
            case .thinking: return .purple
            case .excited: return .yellow
            }
        }
    }

    init(size: CGFloat = 80, emotion: TeacherEmotion = .happy) {
        self.size = size
        self.emotion = emotion
    }

    var body: some View {
        ZStack {
            // Glow effect
            Circle()
                .fill(
                    RadialGradient(
                        colors: [emotion.color.opacity(0.3), emotion.color.opacity(0.0)],
                        center: .center,
                        startRadius: size * 0.3,
                        endRadius: size * 0.6
                    )
                )
                .frame(width: size * 1.2, height: size * 1.2)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 2.0)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )

            // Main avatar circle
            Circle()
                .fill(
                    LinearGradient(
                        colors: [emotion.color.opacity(0.8), emotion.color],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
                .shadow(color: emotion.color.opacity(0.4), radius: 10, y: 5)

            // Face elements
            VStack(spacing: size * 0.15) {
                // Eyes
                HStack(spacing: size * 0.25) {
                    Eye(isBlinking: eyeBlinkOffset > 0.8, size: size * 0.12)
                    Eye(isBlinking: eyeBlinkOffset > 0.8, size: size * 0.12)
                }
                .offset(y: -size * 0.1)

                // Mouth/Expression
                Image(systemName: emotion.mouthShape)
                    .font(.system(size: size * 0.25))
                    .foregroundColor(.white)
                    .scaleEffect(isSpeaking ? 1.2 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 0.3)
                            .repeatForever(autoreverses: true),
                        value: isSpeaking
                    )
            }

            // Graduation cap
            Image(systemName: "graduationcap.fill")
                .font(.system(size: size * 0.3))
                .foregroundColor(.white.opacity(0.9))
                .offset(x: size * 0.3, y: -size * 0.35)
                .rotationEffect(.degrees(isAnimating ? 5 : -5))
                .animation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
        }
        .frame(width: size, height: size)
        .onAppear {
            isAnimating = true
            startBlinking()
        }
    }

    private func startBlinking() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            eyeBlinkOffset = CGFloat.random(in: 0...1)
        }
    }

    func startSpeaking() {
        isSpeaking = true
    }

    func stopSpeaking() {
        isSpeaking = false
    }
}

// MARK: - Eye Component
struct Eye: View {
    let isBlinking: Bool
    let size: CGFloat

    var body: some View {
        if isBlinking {
            // Closed eye
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.white)
                .frame(width: size * 1.5, height: 2)
        } else {
            // Open eye
            Circle()
                .fill(Color.white)
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .fill(Color.black)
                        .frame(width: size * 0.5, height: size * 0.5)
                )
        }
    }
}

// MARK: - Animated Teacher Avatar with Speech
struct SpeakingTeacherAvatar: View {
    @State private var currentEmotion: TeacherAvatar.TeacherEmotion = .happy
    let message: String?

    var body: some View {
        VStack(spacing: 16) {
            TeacherAvatar(size: 100, emotion: currentEmotion)

            if let message = message {
                Text(message)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                    )
                    .padding(.horizontal)
            }
        }
    }

    func setEmotion(_ emotion: TeacherAvatar.TeacherEmotion) {
        withAnimation {
            currentEmotion = emotion
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        TeacherAvatar(size: 120, emotion: .happy)
        TeacherAvatar(size: 100, emotion: .encouraging)
        TeacherAvatar(size: 80, emotion: .thinking)

        SpeakingTeacherAvatar(message: "Great job! Keep practicing!")
    }
    .padding()
    .background(Color(.systemGray6))
}
