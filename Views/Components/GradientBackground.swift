import SwiftUI

struct GradientBackground: View {
    var colors: [Color] = [
        Color(red: 0.2, green: 0.4, blue: 0.8),
        Color(red: 0.4, green: 0.2, blue: 0.8)
    ]

    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

#Preview {
    ZStack {
        GradientBackground()

        VStack {
            Text("Gradient Background")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("Used throughout the app")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
        }
    }
}
