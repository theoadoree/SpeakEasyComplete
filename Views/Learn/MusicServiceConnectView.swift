//
//  MusicServiceConnectView.swift
//  SpeakEasy
//
//  Created by Claude on 2025-11-01.
//

import SwiftUI

struct MusicServiceConnectView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var musicManager = MusicManager()
    @State private var selectedService: MusicManager.MusicService?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "music.note.list")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)

                        Text("Connect Your Music")
                            .font(.title)
                            .fontWeight(.bold)

                        Text("Learn Spanish through your favorite songs and discover new music")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 30)

                    // Service options
                    VStack(spacing: 16) {
                        ServiceCard(
                            icon: "music.note",
                            name: "Spotify",
                            description: "Access millions of Spanish songs",
                            color: .green,
                            isConnected: false
                        ) {
                            selectedService = .spotify
                        }

                        ServiceCard(
                            icon: "music.note",
                            name: "Apple Music",
                            description: "Learn with your Apple Music library",
                            color: .red,
                            isConnected: false
                        ) {
                            selectedService = .appleMusic
                        }

                        ServiceCard(
                            icon: "play.rectangle",
                            name: "YouTube Music",
                            description: "Explore Spanish music videos",
                            color: .red,
                            isConnected: false
                        ) {
                            selectedService = .youtube
                        }
                    }
                    .padding(.horizontal)

                    // Benefits section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("What You'll Get")
                            .font(.headline)
                            .padding(.horizontal)

                        VStack(spacing: 12) {
                            BenefitRow(
                                icon: "sparkles",
                                text: "AI-powered song recommendations based on your level",
                                color: .yellow
                            )

                            BenefitRow(
                                icon: "book.fill",
                                text: "Interactive lyrics with translations",
                                color: .blue
                            )

                            BenefitRow(
                                icon: "waveform",
                                text: "Pronunciation practice with native speakers",
                                color: .green
                            )

                            BenefitRow(
                                icon: "chart.bar.fill",
                                text: "Track vocabulary learned from songs",
                                color: .orange
                            )

                            BenefitRow(
                                icon: "globe",
                                text: "Discover cultural context and meanings",
                                color: .purple
                            )
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)

                    // Skip button
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Maybe Later")
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .alert(item: $selectedService) { service in
                Alert(
                    title: Text("Connect \(serviceName(service))"),
                    message: Text("This will redirect you to \(serviceName(service)) to authorize SpeakEasy."),
                    primaryButton: .default(Text("Continue")) {
                        connectService(service)
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }

    private func serviceName(_ service: MusicManager.MusicService) -> String {
        switch service {
        case .spotify: return "Spotify"
        case .appleMusic: return "Apple Music"
        case .youtube: return "YouTube Music"
        }
    }

    private func connectService(_ service: MusicManager.MusicService) {
        // In production, this would initiate OAuth flow
        musicManager.connectService(service)
        dismiss()
    }
}

struct ServiceCard: View {
    let icon: String
    let name: String
    let description: String
    let color: Color
    let isConnected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 60, height: 60)

                    Image(systemName: icon)
                        .font(.title)
                        .foregroundColor(color)
                }

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Action
                if isConnected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                } else {
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(15)
        }
    }
}

struct BenefitRow: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
                .frame(width: 30)

            Text(text)
                .font(.body)
                .foregroundColor(.primary)

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

extension MusicManager.MusicService: Identifiable {
    var id: String {
        switch self {
        case .spotify: return "spotify"
        case .appleMusic: return "appleMusic"
        case .youtube: return "youtube"
        }
    }
}

#Preview {
    MusicServiceConnectView()
}
