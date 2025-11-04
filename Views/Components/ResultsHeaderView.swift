import SwiftUI

struct ResultsHeaderView: View {
    let grade: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 16) {
            // Grade Circle
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: gradeColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: gradeColors.first?.opacity(0.3) ?? .clear, radius: 20, x: 0, y: 10)

                Text(grade)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.top, 8)

            // Title and Subtitle
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)

                Text(subtitle)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 20)
    }

    private var gradeColors: [Color] {
        if grade.starts(with: "A") {
            return [Color(hex: "34C759"), Color(hex: "30D158")]
        } else if grade.starts(with: "B") {
            return [Color(hex: "007AFF"), Color(hex: "0A84FF")]
        } else if grade.starts(with: "C") {
            return [Color(hex: "FF9500"), Color(hex: "FF9F0A")]
        } else {
            return [Color(hex: "FF3B30"), Color(hex: "FF453A")]
        }
    }
}

#Preview {
    ResultsHeaderView(
        grade: "A+",
        title: "Great Practice Session!",
        subtitle: "Restaurant Ordering"
    )
}
