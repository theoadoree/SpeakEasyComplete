import SwiftUI

// MARK: - Practice Mode Selector
struct PracticeModeSelectorView: View {
    @Binding var selectedMode: PracticeView.PracticeMode

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(PracticeView.PracticeMode.allCases, id: \.self) { mode in
                    PracticeModeButton(
                        mode: mode,
                        isSelected: selectedMode == mode,
                        action: { selectedMode = mode }
                    )
                }
            }
        }
    }
}

struct PracticeModeButton: View {
    let mode: PracticeView.PracticeMode
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: mode.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : Color(hex: "007AFF"))

                Text(mode.rawValue)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? .white : .gray)
            }
            .frame(width: 90, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color(hex: "007AFF") : Color.white)
                    .shadow(
                        color: isSelected ? Color(hex: "007AFF").opacity(0.3) : .black.opacity(0.05),
                        radius: isSelected ? 8 : 4,
                        y: 2
                    )
            )
        }
    }
}

// MARK: - Adaptive Difficulty Banner
struct AdaptiveDifficultyBanner: View {
    let difficulty: DifficultyLevel

    var backgroundColor: Color {
        switch difficulty {
        case .beginner: return Color(hex: "34C759").opacity(0.1)
        case .elementary: return Color(hex: "007AFF").opacity(0.1)
        case .intermediate: return Color(hex: "FFD700").opacity(0.1)
        case .upperIntermediate: return Color(hex: "FF9500").opacity(0.1)
        case .advanced: return Color(hex: "AF52DE").opacity(0.1)
        }
    }

    var textColor: Color {
        switch difficulty {
        case .beginner: return Color(hex: "34C759")
        case .elementary: return Color(hex: "007AFF")
        case .intermediate: return Color(hex: "FFD700").opacity(0.8)
        case .upperIntermediate: return Color(hex: "FF9500")
        case .advanced: return Color(hex: "AF52DE")
        }
    }

    var body: some View {
        HStack {
            Image(systemName: "speedometer")
                .font(.system(size: 16))
                .foregroundColor(textColor)

            Text("Difficulty adjusted to \(difficulty.rawValue) level")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(textColor)

            Spacer()

            Image(systemName: "info.circle")
                .font(.system(size: 14))
                .foregroundColor(textColor.opacity(0.7))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(backgroundColor)
        )
    }
}

#Preview {
    VStack {
        PracticeModeSelectorView(selectedMode: .constant(.conversation))
            .padding()

        AdaptiveDifficultyBanner(difficulty: .intermediate)
            .padding()
    }
}