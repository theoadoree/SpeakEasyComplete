import SwiftUI

// MARK: - App Theme
struct AppTheme {
    // MARK: - Colors
    struct Colors {
        // Primary Colors
        static let primary = Color(hex: "007AFF")        // iOS Blue
        static let primaryDark = Color(hex: "0051D5")    // Darker blue for contrast

        // Accent Colors
        static let accent = Color(hex: "34C759")         // Success Green
        static let accentOrange = Color(hex: "FF9500")   // Orange for highlights
        static let accentPurple = Color(hex: "AF52DE")   // Purple for special features

        // Background Colors
        static let background = Color(hex: "FFFFFF")     // Pure white
        static let secondaryBackground = Color(hex: "F2F2F7") // Light gray
        static let tertiaryBackground = Color(hex: "E5E5EA")  // Medium gray

        // Text Colors
        static let primaryText = Color(hex: "000000")    // Black
        static let secondaryText = Color(hex: "3C3C43").opacity(0.6)
        static let tertiaryText = Color(hex: "3C3C43").opacity(0.3)
        static let invertedText = Color(hex: "FFFFFF")

        // Semantic Colors
        static let success = Color(hex: "34C759")
        static let warning = Color(hex: "FF9500")
        static let error = Color(hex: "FF3B30")
        static let info = Color(hex: "5AC8FA")

        // Card and Surface Colors
        static let cardBackground = Color.white
        static let cardShadow = Color.black.opacity(0.05)

        // Gradient Colors
        static let gradientStart = Color(hex: "007AFF")
        static let gradientEnd = Color(hex: "00C6FF")

        // Lesson Category Colors
        static let beginnerColor = Color(hex: "34C759")
        static let intermediateColor = Color(hex: "007AFF")
        static let advancedColor = Color(hex: "AF52DE")
        static let expertColor = Color(hex: "FF3B30")
    }

    // MARK: - Typography
    struct Typography {
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
        static let title = Font.system(size: 28, weight: .bold, design: .rounded)
        static let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)
        static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
        static let headline = Font.system(size: 17, weight: .semibold, design: .default)
        static let body = Font.system(size: 17, weight: .regular, design: .default)
        static let callout = Font.system(size: 16, weight: .regular, design: .default)
        static let subheadline = Font.system(size: 15, weight: .regular, design: .default)
        static let footnote = Font.system(size: 13, weight: .regular, design: .default)
        static let caption = Font.system(size: 12, weight: .regular, design: .default)
        static let caption2 = Font.system(size: 11, weight: .regular, design: .default)
    }

    // MARK: - Spacing
    struct Spacing {
        static let xxSmall: CGFloat = 4
        static let xSmall: CGFloat = 8
        static let small: CGFloat = 12
        static let medium: CGFloat = 16
        static let large: CGFloat = 20
        static let xLarge: CGFloat = 24
        static let xxLarge: CGFloat = 32
        static let xxxLarge: CGFloat = 40
    }

    // MARK: - Corner Radius
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xLarge: CGFloat = 20
        static let full: CGFloat = 999
    }

    // MARK: - Shadow
    struct Shadow {
        static let light = (color: Color.black.opacity(0.05), radius: CGFloat(4), x: CGFloat(0), y: CGFloat(2))
        static let medium = (color: Color.black.opacity(0.1), radius: CGFloat(8), x: CGFloat(0), y: CGFloat(4))
        static let heavy = (color: Color.black.opacity(0.15), radius: CGFloat(12), x: CGFloat(0), y: CGFloat(6))
    }

    // MARK: - Animation
    struct Animation {
        static let fast = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let normal = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.5)
        static let spring = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.7)
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    // MARK: - Adaptive Colors for Light/Dark Mode
    static let adaptiveBackground = Color(.systemBackground)
    static let adaptiveSecondaryBackground = Color(.secondarySystemBackground)
    static let adaptiveTertiaryBackground = Color(.tertiarySystemBackground)
    static let adaptiveGroupedBackground = Color(.systemGroupedBackground)

    static let adaptiveLabel = Color(.label)
    static let adaptiveSecondaryLabel = Color(.secondaryLabel)
    static let adaptiveTertiaryLabel = Color(.tertiaryLabel)

    static let adaptiveCardBackground = Color(.systemBackground)
    static let adaptiveCardShadow = Color.black.opacity(0.05)
}

// MARK: - Custom View Modifiers
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(AppTheme.CornerRadius.medium)
            .shadow(
                color: AppTheme.Shadow.light.color,
                radius: AppTheme.Shadow.light.radius,
                x: AppTheme.Shadow.light.x,
                y: AppTheme.Shadow.light.y
            )
    }
}

extension View {
    func cardStyle() -> some View {
        self.modifier(CardStyle())
    }
}