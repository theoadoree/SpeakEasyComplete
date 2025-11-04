import SwiftUI

struct OnboardingProgressView: View {
    let currentStep: Int
    let totalSteps: Int

    var progress: CGFloat {
        CGFloat(currentStep + 1) / CGFloat(totalSteps)
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Step \(currentStep + 1) of \(totalSteps)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))

                Spacer()
            }
            .padding(.horizontal, 32)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background bar
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 4)
                        .cornerRadius(2)

                    // Progress bar
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * progress, height: 4)
                        .cornerRadius(2)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: 4)
            .padding(.horizontal, 32)
        }
    }
}

#Preview {
    ZStack {
        Color.black
        VStack(spacing: 40) {
            OnboardingProgressView(currentStep: 0, totalSteps: 4)
            OnboardingProgressView(currentStep: 1, totalSteps: 4)
            OnboardingProgressView(currentStep: 2, totalSteps: 4)
            OnboardingProgressView(currentStep: 3, totalSteps: 4)
        }
    }
}
