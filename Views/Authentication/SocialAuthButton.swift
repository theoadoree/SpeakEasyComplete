import SwiftUI

struct SocialAuthButton: View {
    let icon: String
    let title: String
    let backgroundColor: Color
    let foregroundColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))

                Text(title)
                    .font(.system(size: 16, weight: .semibold))

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: 55)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// Custom button style with scale effect
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: 16) {
        SocialAuthButton(
            icon: "g.circle.fill",
            title: "Continue with Google",
            backgroundColor: .white,
            foregroundColor: .black
        ) {}

        SocialAuthButton(
            icon: "apple.logo",
            title: "Continue with Apple",
            backgroundColor: .black,
            foregroundColor: .white
        ) {}

        SocialAuthButton(
            icon: "person.fill.questionmark",
            title: "Continue as Guest",
            backgroundColor: .blue,
            foregroundColor: .white
        ) {}
    }
    .padding()
    .background(Color.gray.opacity(0.2))
}
