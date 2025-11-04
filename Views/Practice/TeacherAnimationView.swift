import SwiftUI

struct TeacherAnimationView: View {
    let isListening: Bool

    @State private var animationAmount: CGFloat = 1.0
    @State private var pulseAmount: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Pulsing circles when listening
            if isListening {
                Circle()
                    .stroke(Color.blue.opacity(0.5), lineWidth: 3)
                    .scaleEffect(pulseAmount)
                    .opacity(2 - Double(pulseAmount))
                    .animation(
                        .easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: false),
                        value: pulseAmount
                    )

                Circle()
                    .stroke(Color.purple.opacity(0.5), lineWidth: 3)
                    .scaleEffect(pulseAmount * 0.8)
                    .opacity(2 - Double(pulseAmount))
                    .animation(
                        .easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: false)
                            .delay(0.3),
                        value: pulseAmount
                    )
            }

            // Teacher avatar
            ZStack {
                // Background circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)

                // Teacher icon
                Image(systemName: isListening ? "waveform.circle.fill" : "person.wave.2.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.white)
                    .scaleEffect(animationAmount)
                    .animation(
                        .easeInOut(duration: 1.0)
                            .repeatForever(autoreverses: true),
                        value: animationAmount
                    )
            }
        }
        .frame(width: 150, height: 150)
        .onAppear {
            animationAmount = 1.1
            pulseAmount = 1.5
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        Text("Normal State")
            .font(.headline)
        TeacherAnimationView(isListening: false)

        Text("Listening State")
            .font(.headline)
        TeacherAnimationView(isListening: true)
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
