import SwiftUI

// Animated Teacher Avatar View
struct TeacherAvatarView: View {
    let isSpeaking: Bool
    let expression: TeacherExpression
    let amplitude: CGFloat?

    @State private var mouthOpenness: CGFloat = 0
    @State private var eyeBlink = false
    @State private var headTilt: Double = 0

    // Animation timers
    @State private var speakingTimer: Timer?
    @State private var blinkTimer: Timer?

    enum TeacherExpression {
        case neutral, happy, surprised, thinking, encouraging
    }

    init(isSpeaking: Bool, expression: TeacherExpression, amplitude: CGFloat? = nil) {
        self.isSpeaking = isSpeaking
        self.expression = expression
        self.amplitude = amplitude
    }

    var body: some View {
        ZStack(alignment: .center) {
            // Teacher Avatar Image - always visible, fills circle
            Image("teacher_base")
                .resizable()
                .scaledToFill()
                .frame(width: 200, height: 200)
                .clipped()
                .background(Color.clear)  // Ensure transparency works
                .onAppear {
                    print("✅ Teacher avatar image appeared")  // Debug
                }
                .onDisappear {
                    print("⚠️ Teacher avatar image disappeared")  // Debug
                }

            // Always show animated mouth since teacher_base image has no mouth
            TalkingAvatarMouth(level: mouthOpenness)
                .offset(y: 18)
                .zIndex(1)  // Ensure mouth is above image
        }
        .frame(width: 200, height: 200)
        .clipShape(Circle())
        .onAppear {
            startBlinking()
            updateMouthForAmplitude(amplitude)
        }
        .onDisappear {
            stopAnimations()
        }
        .onChange(of: isSpeaking) { speaking in
            if speaking {
                animateSpeakingIfNeeded()
            } else {
                speakingTimer?.invalidate()
                withAnimation(.easeOut(duration: 0.2)) {
                    mouthOpenness = 0
                }
            }
        }
        .onChange(of: amplitude) { newValue in
            updateMouthForAmplitude(newValue)
        }
        .onChange(of: expression) { newExpression in
            // Add head movement for certain expressions
            switch newExpression {
            case .thinking:
                withAnimation(.easeInOut(duration: 0.5)) {
                    headTilt = -5
                }
            case .surprised:
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    headTilt = 0
                }
            default:
                withAnimation(.easeInOut(duration: 0.3)) {
                    headTilt = 0
                }
            }
        }
    }

    // MARK: - Private Methods

    private func animateSpeakingIfNeeded() {
        guard amplitude == nil else {
            speakingTimer?.invalidate()
            return
        }

        speakingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.1)) {
                mouthOpenness = CGFloat.random(in: 0.2...1.0)
            }
        }
    }

    private func startBlinking() {
        // Random blink intervals for natural appearance
        blinkTimer = Timer.scheduledTimer(withTimeInterval: Double.random(in: 2...5), repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.15)) {
                eyeBlink = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeInOut(duration: 0.15)) {
                    eyeBlink = false
                }
            }
        }
    }

    private func stopAnimations() {
        speakingTimer?.invalidate()
        blinkTimer?.invalidate()
    }

    private func updateMouthForAmplitude(_ amplitude: CGFloat?) {
        if let amplitude = amplitude, isSpeaking {
            let normalized = max(0, min((amplitude - 0.02) * 6, 1))
            let smoothing: CGFloat = 0.4
            withAnimation(.easeOut(duration: 0.08)) {
                mouthOpenness += (normalized - mouthOpenness) * smoothing
            }
        } else {
            // When not speaking, keep mouth slightly visible (closed state)
            withAnimation(.easeOut(duration: 0.2)) {
                mouthOpenness = max(0.1, mouthOpenness * 0.9)
            }
        }
    }
}

// MARK: - Subviews

struct TeacherHairView: View {
    var body: some View {
        ZStack {
            // Main hair shape - Adaptive brown
            Ellipse()
                .fill(LinearGradient(
                    colors: [
                        Color.brown.opacity(0.8),  // Adaptive brown
                        Color.brown.opacity(0.6)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 200, height: 120)

            // Hair details - Adaptive
            ForEach(0..<5) { index in
                Capsule()
                    .fill(Color.brown.opacity(0.7))
                    .frame(width: 15, height: 80)
                    .rotationEffect(.degrees(Double(index - 2) * 15))
                    .offset(x: CGFloat(index - 2) * 20, y: 20)
            }
        }
    }
}

struct EyeView: View {
    let isBlinking: Bool
    let expression: TeacherAvatarView.TeacherExpression

    var eyeHeight: CGFloat {
        if isBlinking {
            return 2
        }
        switch expression {
        case .surprised:
            return 35
        case .happy:
            return 20
        default:
            return 28
        }
    }

    var body: some View {
        ZStack {
            // Eye white - Always white
            Ellipse()
                .fill(Color.white)
                .frame(width: 35, height: eyeHeight)

            if !isBlinking {
                // Iris - Adaptive brown
                Circle()
                    .fill(LinearGradient(
                        colors: [Color.brown.opacity(0.8), Color.brown],
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(width: 20, height: 20)

                // Pupil - Black
                Circle()
                    .fill(Color.black)
                    .frame(width: 10, height: 10)

                // Eye shine - White
                Circle()
                    .fill(Color.white)
                    .frame(width: 5, height: 5)
                    .offset(x: -3, y: -3)
            }
        }
    }
}

struct GlassesView: View {
    var body: some View {
        HStack(spacing: 5) {
            // Left lens - Adaptive stroke
            Circle()
                .stroke(Color.primary.opacity(0.8), lineWidth: 3)  // Dark adaptive
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(Color.blue.opacity(0.05))  // Light tint
                )

            // Bridge
            Rectangle()
                .fill(Color.primary.opacity(0.8))
                .frame(width: 15, height: 3)

            // Right lens
            Circle()
                .stroke(Color.primary.opacity(0.8), lineWidth: 3)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(Color.blue.opacity(0.05))
                )
        }
    }
}

struct MouthView: View {
    let openness: CGFloat
    let expression: TeacherAvatarView.TeacherExpression
    let isSpeaking: Bool

    var mouthPath: Path {
        var path = Path()
        let width: CGFloat = 60
        let baseHeight: CGFloat = 20

        switch expression {
        case .happy:
            // Smile
            path.move(to: CGPoint(x: -width/2, y: 0))
            path.addQuadCurve(
                to: CGPoint(x: width/2, y: 0),
                control: CGPoint(x: 0, y: baseHeight + 10)
            )
        case .surprised:
            // O shape
            let rect = CGRect(x: -20, y: -10, width: 40, height: 30 + openness * 10)
            path.addEllipse(in: rect)
        default:
            // Neutral/speaking mouth
            if isSpeaking {
                let height = baseHeight * openness
                path.move(to: CGPoint(x: -width/2, y: 0))
                path.addQuadCurve(
                    to: CGPoint(x: width/2, y: 0),
                    control: CGPoint(x: 0, y: height)
                )
                if openness > 0.5 {
                    path.addQuadCurve(
                        to: CGPoint(x: -width/2, y: 0),
                        control: CGPoint(x: 0, y: -height * 0.3)
                    )
                }
            } else {
                // Neutral line
                path.move(to: CGPoint(x: -width/2, y: 0))
                path.addLine(to: CGPoint(x: width/2, y: 0))
            }
        }

        return path
    }

    var body: some View {
        mouthPath
            .stroke(Color.red.opacity(0.8), lineWidth: 3)  // Adaptive red tint
            .background(
                mouthPath
                    .fill(expression == .surprised ? Color.primary.opacity(0.3) : Color.clear)
            )
    }
}

struct TeacherBodyView: View {
    var body: some View {
        ZStack {
            // Shoulders/jacket - Adaptive green (or use Color.secondary)
            RoundedRectangle(cornerRadius: 40)
                .fill(LinearGradient(
                    colors: [
                        Color.green.opacity(0.7),  // Adaptive green
                        Color.green.opacity(0.5)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 200, height: 100)

            // Collar - White
            VStack(spacing: 0) {
                Triangle()
                    .fill(Color.white)
                    .frame(width: 60, height: 30)
                    .rotationEffect(.degrees(180))

                Rectangle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
            }
            .offset(y: -35)

            // Apple pin (teacher detail) - Red
            Image(systemName: "applelogo")
                .foregroundColor(.red)
                .font(.system(size: 20))
                .offset(x: -60, y: -20)
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct SpeechBubbleIndicator: View {
    @State private var dotScale: [CGFloat] = [1, 1, 1]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.accentColor)  // Adaptive accent
                    .frame(width: 8, height: 8)
                    .scaleEffect(dotScale[index])
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))  // Adaptive background
                .shadow(radius: 3)
        )
        .onAppear {
            animateDots()
        }
    }

    private func animateDots() {
        for index in 0..<3 {
            withAnimation(
                .easeInOut(duration: 0.6)
                    .repeatForever()
                    .delay(Double(index) * 0.2)
            ) {
                dotScale[index] = 1.5
            }
        }
    }
}

// MARK: - Mouth Components

struct TalkingAvatarMouth: View {
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
                        Color.red.opacity(0.9),  // Adaptive red
                        Color.red.opacity(0.7)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                Capsule()
                    .stroke(Color.primary.opacity(0.2), lineWidth: 1)  // Adaptive border
            )
            .clipShape(TalkingAvatarMouthMask())
    }
}

struct TalkingAvatarMouthMask: Shape {
    func path(in rect: CGRect) -> Path {
        Path(
            roundedRect: CGRect(x: rect.midX - 45, y: rect.midY - 30, width: 90, height: 60),
            cornerSize: CGSize(width: 28, height: 28)
        )
    }
}

// MARK: - Preview with Dark Mode
struct TeacherAvatarView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TeacherAvatarView(isSpeaking: true, expression: .happy)
                .previewLayout(.sizeThatFits)
                .padding()
                .preferredColorScheme(.light)
            
            TeacherAvatarView(isSpeaking: true, expression: .happy)
                .previewLayout(.sizeThatFits)
                .padding()
                .preferredColorScheme(.dark)
        }
    }
}
