//
//  MusicContentView.swift
//  SpeakEasy
//
//  Created by Claude on 2025-11-01.
//

import SwiftUI

struct MusicContentView: View {
    @Binding var showingConnect: Bool
    @StateObject private var musicManager = MusicManager()
    @State private var selectedSong: Song?
    @State private var searchText = ""
    @State private var showingSearch = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Connect Services (if not connected)
            if !musicManager.isConnected {
                ConnectMusicCard(showingConnect: $showingConnect)
            } else {
                // Music Search Bar
                MusicSearchBar(searchText: $searchText, isSearching: $showingSearch)

                // Your Library (if connected)
                YourMusicSection(
                    playlists: musicManager.userPlaylists,
                    onSongSelected: { song in selectedSong = song }
                )
            }

            // Recommended Songs (Always visible - curated by LLM)
            RecommendedSongsSection(
                songs: musicManager.recommendedSongs,
                onSongSelected: { song in selectedSong = song }
            )

            // Trending Spanish Songs
            TrendingSongsSection(
                songs: musicManager.trendingSongs,
                onSongSelected: { song in selectedSong = song }
            )

            // Learn by Genre
            GenreSection(
                genres: musicManager.genres,
                onGenreSelected: { genre in
                    musicManager.loadSongsForGenre(genre)
                }
            )
        }
        .sheet(item: $selectedSong) { song in
            SongLearningView(song: song)
        }
        .sheet(isPresented: $showingSearch) {
            MusicSearchView(musicManager: musicManager) { song in
                selectedSong = song
                showingSearch = false
            }
        }
        .onAppear {
            musicManager.loadRecommendations()
        }
    }
}

struct ConnectMusicCard: View {
    @Binding var showingConnect: Bool

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "music.note.list")
                .font(.system(size: 50))
                .foregroundColor(.blue)

            Text("Learn Spanish Through Music")
                .font(.title2)
                .fontWeight(.bold)

            Text("Connect your music service to learn with your favorite Spanish songs")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: { showingConnect = true }) {
                HStack {
                    Image(systemName: "link")
                    Text("Connect Music Service")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 30)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
    }
}

struct MusicSearchBar: View {
    @Binding var searchText: String
    @Binding var isSearching: Bool

    var body: some View {
        Button(action: { isSearching = true }) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)

                Text("Search songs, artists, or albums...")
                    .foregroundColor(.secondary)

                Spacer()
            }
            .padding(12)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
        }
    }
}

struct YourMusicSection: View {
    let playlists: [MusicPlaylist]
    let onSongSelected: (Song) -> Void
    @State private var selectedPlaylist: MusicPlaylist?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Library")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(playlists) { playlist in
                        PlaylistCard(playlist: playlist) {
                            selectedPlaylist = playlist
                        }
                    }
                }
            }
        }
        .sheet(item: $selectedPlaylist) { playlist in
            PlaylistDetailView(playlist: playlist, onSongSelected: onSongSelected)
        }
    }
}

struct PlaylistCard: View {
    let playlist: MusicPlaylist
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                // Cover Art
                RoundedRectangle(cornerRadius: 10)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [.blue, .purple]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 120, height: 120)
                    .overlay(
                        Image(systemName: "music.note")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.8))
                    )

                Text(playlist.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)

                Text("\(playlist.songCount) songs")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(width: 120)
        }
    }
}

struct RecommendedSongsSection: View {
    let songs: [Song]
    let onSongSelected: (Song) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.yellow)
                Text("AI Recommended for You")
                    .font(.headline)
            }

            Text("Based on your level and learning goals")
                .font(.caption)
                .foregroundColor(.secondary)

            ForEach(songs.prefix(5)) { song in
                SongRow(song: song, showDifficulty: true) {
                    onSongSelected(song)
                }
            }
        }
    }
}

struct TrendingSongsSection: View {
    let songs: [Song]
    let onSongSelected: (Song) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.orange)
                Text("Trending Spanish Songs")
                    .font(.headline)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(songs.prefix(10)) { song in
                        TrendingSongCard(song: song) {
                            onSongSelected(song)
                        }
                    }
                }
            }
        }
    }
}

struct TrendingSongCard: View {
    let song: Song
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                // Album Art
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 140, height: 140)
                    .overlay(
                        VStack {
                            Image(systemName: "music.note")
                                .font(.system(size: 30))
                                .foregroundColor(.gray)

                            // Difficulty badge
                            HStack(spacing: 4) {
                                ForEach(0..<3) { index in
                                    Circle()
                                        .fill(index < song.difficultyLevel ? Color.blue : Color.gray.opacity(0.3))
                                        .frame(width: 6, height: 6)
                                }
                            }
                            .padding(6)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(12)
                        }
                    )

                Text(song.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)

                Text(song.artist)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                Text("\(song.vocabularyCount) new words")
                    .font(.caption2)
                    .foregroundColor(.blue)
            }
            .frame(width: 140)
        }
    }
}

struct GenreSection: View {
    let genres: [MusicGenre]
    let onGenreSelected: (MusicGenre) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Learn by Genre")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(genres) { genre in
                    GenreCard(genre: genre) {
                        onGenreSelected(genre)
                    }
                }
            }
        }
    }
}

struct GenreCard: View {
    let genre: MusicGenre
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: genre.icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(genre.color)
                    .cornerRadius(10)

                VStack(alignment: .leading, spacing: 2) {
                    Text(genre.name)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Text("\(genre.songCount) songs")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding(12)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
    }
}

struct SongRow: View {
    let song: Song
    let showDifficulty: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Thumbnail
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "music.note")
                            .foregroundColor(.gray)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(song.title)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Text(song.artist)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack(spacing: 8) {
                        if showDifficulty {
                            HStack(spacing: 2) {
                                ForEach(0..<3) { index in
                                    Circle()
                                        .fill(index < song.difficultyLevel ? Color.blue : Color.gray.opacity(0.3))
                                        .frame(width: 5, height: 5)
                                }
                            }
                        }

                        Text("\(song.vocabularyCount) words")
                            .font(.caption2)
                            .foregroundColor(.blue)

                        Text("•")
                            .font(.caption2)
                            .foregroundColor(.secondary)

                        Text(song.duration)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    MusicContentView(showingConnect: .constant(false))
}
