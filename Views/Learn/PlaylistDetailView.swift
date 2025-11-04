//
//  PlaylistDetailView.swift
//  SpeakEasy
//
//  Created by Claude on 2025-11-01.
//

import SwiftUI

struct PlaylistDetailView: View {
    let playlist: MusicPlaylist
    let onSongSelected: (Song) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var songs: [Song] = []

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Playlist Header
                    VStack(spacing: 16) {
                        // Cover Art
                        RoundedRectangle(cornerRadius: 15)
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [.blue, .purple]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 200, height: 200)
                            .overlay(
                                VStack(spacing: 12) {
                                    Image(systemName: "music.note.list")
                                        .font(.system(size: 60))
                                        .foregroundColor(.white.opacity(0.8))

                                    Text("\(playlist.songCount)")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)

                                    Text("songs")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            )
                            .shadow(radius: 10)

                        // Playlist Info
                        VStack(spacing: 8) {
                            Text(playlist.name)
                                .font(.title2)
                                .fontWeight(.bold)

                            Text("\(playlist.songCount) Spanish songs for learning")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        // Action Buttons
                        HStack(spacing: 12) {
                            Button(action: {
                                // Play all
                            }) {
                                HStack {
                                    Image(systemName: "play.fill")
                                    Text("Play All")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }

                            Button(action: {
                                // Shuffle
                            }) {
                                HStack {
                                    Image(systemName: "shuffle")
                                    Text("Shuffle")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .foregroundColor(.primary)
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 30)

                    // Songs List
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Songs")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.bottom, 12)

                        ForEach(Array(songs.enumerated()), id: \.element.id) { index, song in
                            PlaylistSongRow(
                                number: index + 1,
                                song: song
                            ) {
                                onSongSelected(song)
                            }

                            if index < songs.count - 1 {
                                Divider()
                                    .padding(.leading, 60)
                            }
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadPlaylistSongs()
            }
        }
    }

    private func loadPlaylistSongs() {
        // In production, load actual playlist songs from music service
        // For now, use sample data
        songs = [
            Song(
                id: "p1",
                title: "Bailando",
                artist: "Enrique Iglesias",
                album: "Sex and Love",
                duration: "4:03",
                spotifyURL: nil,
                appleMusicURL: nil,
                youtubeURL: nil,
                difficultyLevel: 1,
                vocabularyCount: 45,
                lyrics: nil,
                genre: "Pop Latino",
                releaseYear: 2014
            ),
            Song(
                id: "p2",
                title: "Vivir Mi Vida",
                artist: "Marc Anthony",
                album: "3.0",
                duration: "4:04",
                spotifyURL: nil,
                appleMusicURL: nil,
                youtubeURL: nil,
                difficultyLevel: 2,
                vocabularyCount: 52,
                lyrics: nil,
                genre: "Salsa",
                releaseYear: 2013
            ),
            Song(
                id: "p3",
                title: "La Bicicleta",
                artist: "Carlos Vives & Shakira",
                album: "Single",
                duration: "3:49",
                spotifyURL: nil,
                appleMusicURL: nil,
                youtubeURL: nil,
                difficultyLevel: 2,
                vocabularyCount: 48,
                lyrics: nil,
                genre: "Vallenato",
                releaseYear: 2016
            ),
            Song(
                id: "p4",
                title: "Me Gustas Tú",
                artist: "Manu Chao",
                album: "Próxima Estación: Esperanza",
                duration: "3:56",
                spotifyURL: nil,
                appleMusicURL: nil,
                youtubeURL: nil,
                difficultyLevel: 1,
                vocabularyCount: 28,
                lyrics: nil,
                genre: "Rock en Español",
                releaseYear: 2001
            )
        ]
    }
}

struct PlaylistSongRow: View {
    let number: Int
    let song: Song
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Track number
                Text("\(number)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 30, alignment: .trailing)

                VStack(alignment: .leading, spacing: 4) {
                    Text(song.title)
                        .font(.body)
                        .foregroundColor(.primary)

                    HStack {
                        Text(song.artist)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        // Difficulty indicator
                        HStack(spacing: 2) {
                            ForEach(0..<3) { index in
                                Circle()
                                    .fill(index < song.difficultyLevel ? Color.blue : Color.gray.opacity(0.3))
                                    .frame(width: 4, height: 4)
                            }
                        }

                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("\(song.vocabularyCount) words")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(song.duration)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
    }
}

#Preview {
    PlaylistDetailView(
        playlist: MusicPlaylist(
            id: "1",
            name: "Spanish Favorites",
            songCount: 24,
            coverArtURL: nil,
            songs: []
        ),
        onSongSelected: { _ in }
    )
}
