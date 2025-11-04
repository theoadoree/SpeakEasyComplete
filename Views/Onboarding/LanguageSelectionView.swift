import SwiftUI

struct LanguageSelectionView: View {
    let title: String
    @Binding var selectedLanguage: String
    let onNext: () -> Void

    // Use all available languages from the Language enum
    private let allLanguages = Language.allCases.filter { language in
        // Remove English variants and legacy mappings from the list
        language != .englishUS &&
        language != .englishUK &&
        language != .spanish &&
        language != .chinese &&
        language != .portuguese
    }

    // Popular languages per user specification
    private let popularLanguages: [Language] = [
        .spanishCaribbean,  // 🇵🇷 Spanish (Caribbean)
        .chineseMandarin,   // 🇹🇼 Mandarin (Taiwan Flag)
        .french,            // 🇫🇷 French
        .german,            // 🇩🇪 German
        .arabic,            // 🇸🇦 Arabic
        .korean,            // 🇰🇷 Korean
        .japanese           // 🇯🇵 Japanese
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header with Logo
                VStack(spacing: 20) {
                    // SpeakEasy Logo
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 100, height: 100)

                        VStack(spacing: -10) {
                            Image(systemName: "graduationcap.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)

                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 35, height: 25)
                                .foregroundColor(.green)
                                .offset(y: 8)
                        }
                    }

                    HStack(spacing: 6) {
                        Text("SpeakEasy")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text("AI")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.white.opacity(0.2))
                            )
                    }

                    Text(title)
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 40)

                // Language List (Scrollable with flags and names)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select Language")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal)

                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(allLanguages, id: \.self) { language in
                                Button(action: {
                                    selectedLanguage = language.rawValue
                                }) {
                                    HStack(spacing: 12) {
                                        Text(language.flag)
                                            .font(.system(size: 24))
                                        
                                        Text(language.rawValue)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        if selectedLanguage == language.rawValue {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.blue)
                                                .font(.system(size: 20))
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        selectedLanguage == language.rawValue ?
                                        Color.blue.opacity(0.3) : Color.white.opacity(0.1)
                                    )
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                selectedLanguage == language.rawValue ?
                                                Color.blue : Color.white.opacity(0.2),
                                                lineWidth: selectedLanguage == language.rawValue ? 2 : 1
                                            )
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxHeight: 300)
                }

                // Popular languages quick select
                VStack(alignment: .leading, spacing: 12) {
                    Text("Popular choices")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(popularLanguages, id: \.self) { language in
                                Button(action: {
                                    selectedLanguage = language.rawValue
                                }) {
                                    HStack(spacing: 6) {
                                        Text(language.flag)
                                            .font(.system(size: 16))
                                        Text(language.rawValue)
                                            .font(.system(size: 14, weight: .medium))
                                    }
                                    .foregroundColor(selectedLanguage == language.rawValue ? .white : .white.opacity(0.8))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        selectedLanguage == language.rawValue ?
                                        Color.blue : Color.white.opacity(0.2)
                                    )
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(
                                                selectedLanguage == language.rawValue ? Color.blue : Color.white.opacity(0.3),
                                                lineWidth: 1
                                            )
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top, 20)

                Spacer(minLength: 40)

                // Continue Button
                Button(action: onNext) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(selectedLanguage.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(12)
                }
                .disabled(selectedLanguage.isEmpty)
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    LanguageSelectionView(
        title: "What language do you want to learn?",
        selectedLanguage: .constant("Spanish"),
        onNext: {}
    )
}