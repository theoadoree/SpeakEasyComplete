import SwiftUI

/// Viseme-based animated teacher avatar for realtime voice interactions
/// Supports 8 viseme states: "0" (neutral), "A", "E", "O", "U", "M", "F", "L"
struct VisemeTeacherAvatarView: View {
    let currentViseme: String   // "0","A","E","O","U","M","F","L"
    let speaking: Bool

    var body: some View {
        ZStack {
            Circle().fill(.ultraThinMaterial)

            Image(imageName)
                .resizable()
                .scaledToFit()
                .padding(12)
                .overlay(
                    Circle().strokeBorder(.white.opacity(0.12), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.15), radius: 8, y: 6)

            if speaking {
                Circle()
                    .strokeBorder(Color.accentColor.opacity(0.35), lineWidth: 6)
                    .scaleEffect(1.05)
                    .blur(radius: 6)
            }
        }
        .animation(.easeInOut(duration: 0.15), value: currentViseme)
        .clipShape(Circle())
        .shadow(color: .black.opacity(0.12), radius: 24, y: 12)
    }

    private var imageName: String {
        return "Viseme_\(currentViseme)"
    }
}

#Preview {
    VStack(spacing: 20) {
        VisemeTeacherAvatarView(currentViseme: "0", speaking: false)
            .frame(width: 220, height: 220)

        VisemeTeacherAvatarView(currentViseme: "A", speaking: true)
            .frame(width: 220, height: 220)
    }
    .padding()
}
