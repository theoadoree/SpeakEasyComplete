import SwiftUI

struct MetricCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 50, height: 50)

                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
            }

            // Value
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)

            // Label
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(color.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    HStack(spacing: 16) {
        MetricCard(
            icon: "clock.fill",
            value: "5:23",
            label: "Duration",
            color: Color(hex: "007AFF")
        )

        MetricCard(
            icon: "speedometer",
            value: "120",
            label: "Avg WPM",
            color: Color(hex: "34C759")
        )

        MetricCard(
            icon: "message.fill",
            value: "12",
            label: "Exchanges",
            color: Color(hex: "AF52DE")
        )
    }
    .padding()
}
