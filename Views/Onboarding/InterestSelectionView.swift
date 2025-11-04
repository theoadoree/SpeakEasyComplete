import SwiftUI

struct InterestSelectionView: View {
    @Binding var selectedInterests: [String]
    let onComplete: () -> Void

    private let interests: [(emoji: String, name: String)] = [
        ("✈️", "Travel"), ("💼", "Business"), ("💻", "Technology"), ("🍳", "Food & Cooking"),
        ("⚽️", "Sports"), ("🎵", "Music"), ("🎬", "Movies & TV"), ("📚", "Books"),
        ("🎨", "Art & Design"), ("🔬", "Science"), ("💪", "Health & Fitness"), ("🎮", "Gaming"),
        ("👗", "Fashion"), ("📜", "History"), ("🌿", "Nature"), ("📰", "News & Politics")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "star.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.yellow)

                    Text("What are you interested in?")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text("Select at least 3 topics")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.top, 20)

                // Interest Grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(interests, id: \.name) { interest in
                        InterestButton(
                            emoji: interest.emoji,
                            interest: interest.name,
                            isSelected: selectedInterests.contains(interest.name)
                        ) {
                            toggleInterest(interest.name)
                        }
                    }
                }
                .padding(.horizontal, 20)

                // Continue Button
                VStack(spacing: 12) {
                    if !selectedInterests.isEmpty {
                        Text("\(selectedInterests.count) selected")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }

                    Button(action: onComplete) {
                        Text("Get Started")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(selectedInterests.count >= 3 ? Color.green : Color.gray)
                            .cornerRadius(12)
                    }
                    .disabled(selectedInterests.count < 3)
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 20)
            }
        }
        .ignoresSafeArea(.keyboard)
    }

    private func toggleInterest(_ interest: String) {
        if selectedInterests.contains(interest) {
            selectedInterests.removeAll { $0 == interest }
        } else {
            selectedInterests.append(interest)
        }
    }
}

// MARK: - Interest Button
struct InterestButton: View {
    let emoji: String
    let interest: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(emoji)
                    .font(.system(size: 24))

                Text(interest)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.9))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.green)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 85)
            .background(
                isSelected ?
                Color.blue.opacity(0.8) :
                Color.white.opacity(0.2)
            )
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        isSelected ? Color.green : Color.white.opacity(0.3),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    GradientBackground()
        .overlay(
            InterestSelectionView(
                selectedInterests: .constant(["Travel", "Technology", "Music"]),
                onComplete: {}
            )
        )
}
