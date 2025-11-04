import SwiftUI

struct LaunchScreenView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color(.secondarySystemBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    AppTheme.Colors.primary.opacity(colorScheme == .dark ? 0.25 : 0.12),
                                    Color(.systemBackground)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 210, height: 210)
                        .shadow(
                            color: Color.black.opacity(colorScheme == .dark ? 0.35 : 0.12),
                            radius: 18,
                            x: 0,
                            y: 12
                        )
                        .overlay(
                            Circle()
                                .stroke(Color(.quaternaryLabel), lineWidth: 1)
                        )

                    // Teacher illustration logo
                    Image("Teacher3")
                        .resizable()
                        .renderingMode(.original)
                        .scaledToFit()
                        .frame(width: 170, height: 170)
                        .scaleEffect(isAnimating ? 1.05 : 1.0)
                }

                // Loading text
                Text("Loading your fluency journey...")
                    .font(.system(size: 16))
                    .foregroundColor(Color(.secondaryLabel))
                    .padding(.top, 8)

                // Loading indicator
                ProgressView()
                    .progressViewStyle(
                        CircularProgressViewStyle(
                            tint: AppTheme.Colors.primary
                        )
                    )
                    .scaleEffect(1.2)
                    .padding(.top, 16)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}
