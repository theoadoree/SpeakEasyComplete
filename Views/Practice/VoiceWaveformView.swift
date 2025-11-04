import SwiftUI

struct VoiceWaveformView: View {
    @State private var waveHeights: [CGFloat] = Array(repeating: 0.3, count: 20)
    @State private var animationTimer: Timer?

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<waveHeights.count, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: 3)
                    .frame(height: waveHeights[index] * 50)
                    .animation(.easeInOut(duration: 0.3), value: waveHeights[index])
            }
        }
        .frame(height: 50)
        .onAppear {
            startAnimation()
        }
        .onDisappear {
            stopAnimation()
        }
    }

    private func startAnimation() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            for index in 0..<waveHeights.count {
                waveHeights[index] = CGFloat.random(in: 0.3...1.0)
            }
        }
    }

    private func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
}

#Preview {
    VStack(spacing: 40) {
        Text("Recording...")
            .font(.headline)

        VoiceWaveformView()
            .padding()
            .background(Color(.systemGroupedBackground))
            .cornerRadius(12)
    }
    .padding()
}
