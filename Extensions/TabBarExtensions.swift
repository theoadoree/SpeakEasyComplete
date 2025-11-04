//
//  TabBarExtensions.swift
//  SpeakEasy
//
//  Advanced tab bar badge and notification system
//

import SwiftUI

// MARK: - Badge Modifier
struct BadgeModifier: ViewModifier {
    let count: Int
    let color: Color
    let position: BadgePosition

    init(count: Int, color: Color = .red, position: BadgePosition = .topTrailing) {
        self.count = count
        self.color = color
        self.position = position
    }

    func body(content: Content) -> some View {
        content.overlay(
            Group {
                if count > 0 {
                    badgeView
                }
            }
        )
    }

    private var badgeView: some View {
        Text(badgeText)
            .font(.system(size: 10, weight: .bold))
            .padding(.horizontal, count > 9 ? 4 : 5)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(color)
            )
            .foregroundColor(.white)
            .offset(x: position.xOffset, y: position.yOffset)
    }

    private var badgeText: String {
        if count > 99 {
            return "99+"
        } else {
            return "\(count)"
        }
    }
}

// MARK: - Badge Position
enum BadgePosition {
    case topTrailing
    case topLeading
    case center

    var xOffset: CGFloat {
        switch self {
        case .topTrailing: return 12
        case .topLeading: return -12
        case .center: return 0
        }
    }

    var yOffset: CGFloat {
        switch self {
        case .topTrailing, .topLeading: return -10
        case .center: return 0
        }
    }
}

// MARK: - View Extension for Badges
extension View {
    /// Add a numeric badge to the view
    func badge(_ count: Int, color: Color = .red, position: BadgePosition = .topTrailing) -> some View {
        modifier(BadgeModifier(count: count, color: color, position: position))
    }

    /// Add a simple dot badge (no number)
    func dotBadge(color: Color = .red, position: BadgePosition = .topTrailing) -> some View {
        self.overlay(
            Group {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                    .offset(x: position.xOffset, y: position.yOffset)
            }
        )
    }

    /// Conditional badge that only shows when condition is true
    func badge(if condition: Bool, count: Int = 0, color: Color = .red) -> some View {
        Group {
            if condition {
                self.badge(count > 0 ? count : 1, color: color)
            } else {
                self
            }
        }
    }
}

// MARK: - Animated Badge
struct AnimatedBadge: View {
    let count: Int
    let color: Color
    @State private var scale: CGFloat = 1.0

    var body: some View {
        Text(count > 99 ? "99+" : "\(count)")
            .font(.system(size: 10, weight: .bold))
            .padding(.horizontal, count > 9 ? 4 : 5)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(color)
            )
            .foregroundColor(.white)
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6).repeatForever(autoreverses: true)) {
                    scale = 1.2
                }
            }
    }
}

// MARK: - Tab Badge Container
struct TabBadgeContainer: View {
    let icon: String
    let selectedIcon: String
    let title: String
    let isSelected: Bool
    let badgeCount: Int
    let badgeColor: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: isSelected ? selectedIcon : icon)
                .font(.system(size: 24))
                .badge(badgeCount, color: badgeColor)

            Text(title)
                .font(.caption2)
        }
        .foregroundColor(isSelected ? .blue : .gray)
    }
}

// MARK: - Notification Badge Style
struct NotificationBadgeStyle {
    static let urgent = Color.red
    static let important = Color.orange
    static let info = Color.blue
    static let success = Color.green
}

// MARK: - Badge Counter Observable
class BadgeCounter: ObservableObject {
    @Published var count: Int = 0

    func increment() {
        count += 1
    }

    func decrement() {
        if count > 0 {
            count -= 1
        }
    }

    func reset() {
        count = 0
    }

    func set(_ value: Int) {
        count = max(0, value)
    }
}

// MARK: - Custom Tab Item with Badge
struct CustomTabItem: View {
    let icon: String
    let title: String
    let badgeCount: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    Image(systemName: icon)
                        .font(.system(size: 24))

                    if badgeCount > 0 {
                        Text("\(min(badgeCount, 99))")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                            .padding(3)
                            .background(Circle().fill(Color.red))
                            .offset(x: 12, y: -10)
                    }
                }

                Text(title)
                    .font(.caption2)
            }
            .foregroundColor(isSelected ? .blue : .gray)
        }
    }
}

// MARK: - Smart Badge (Auto-hide after delay)
struct SmartBadge: View {
    let count: Int
    @State private var isVisible = true

    var body: some View {
        Group {
            if isVisible && count > 0 {
                Text("\(min(count, 99))")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, count > 9 ? 4 : 5)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Color.red))
                    .transition(.scale.combined(with: .opacity))
                    .onAppear {
                        // Auto-hide after 5 seconds if user doesn't interact
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            withAnimation {
                                isVisible = false
                            }
                        }
                    }
            }
        }
    }
}

// MARK: - Badge Preview Helpers
#if DEBUG
struct BadgePreview: View {
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 30) {
                // Standard badge
                Image(systemName: "house.fill")
                    .font(.largeTitle)
                    .badge(5)

                // Different color
                Image(systemName: "book.fill")
                    .font(.largeTitle)
                    .badge(12, color: .blue)

                // Large number
                Image(systemName: "message.fill")
                    .font(.largeTitle)
                    .badge(150, color: .green)

                // Dot badge
                Image(systemName: "bell.fill")
                    .font(.largeTitle)
                    .dotBadge(color: .orange)
            }

            HStack(spacing: 30) {
                // Animated badge
                VStack {
                    Image(systemName: "star.fill")
                        .font(.largeTitle)
                    AnimatedBadge(count: 3, color: .red)
                }

                // Custom tab item
                CustomTabItem(
                    icon: "chart.bar.fill",
                    title: "Progress",
                    badgeCount: 7,
                    isSelected: false,
                    action: {}
                )
            }
        }
        .padding()
    }
}

#Preview {
    BadgePreview()
}
#endif
