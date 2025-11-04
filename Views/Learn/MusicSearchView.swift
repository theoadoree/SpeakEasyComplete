//
//  MusicSearchView.swift
//  SpeakEasy
//
//  Created by Claude on 2025-11-01.
//

import SwiftUI

struct MusicSearchView: View {
    @ObservedObject var musicManager: MusicManager
    let onSongSelected: (Song) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var searchResults: [Song] = []
    @State private var isSearching = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)

                    TextField("Search songs, artists, albums...", text: $searchText)
                        .textFieldStyle(.plain)
                        .onSubmit {
                            performSearch()
                        }

                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            searchResults = []
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))

                // Results
                if isSearching {
                    ProgressView()
                        .padding()
                    Spacer()
                } else if searchResults.isEmpty && !searchText.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "music.note.list")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)

                        Text("No results found")
                            .font(.headline)

                        Text("Try searching for a different song or artist")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    Spacer()
                } else if !searchResults.isEmpty {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(searchResults) { song in
                                SearchResultRow(song: song) {
                                    onSongSelected(song)
                                }
                                Divider()
                            }
                        }
                    }
                } else {
                    // Search suggestions
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Popular Searches")
                                    .font(.headline)
                                    .padding(.horizontal)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(popularSearches, id: \.self) { search in
                                            Button(action: {
                                                searchText = search
                                                performSearch()
                                            }) {
                                                Text(search)
                                                    .padding(.horizontal, 16)
                                                    .padding(.vertical, 8)
                                                    .background(Color(.secondarySystemBackground))
                                                    .cornerRadius(20)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }

                            VStack(alignment: .leading, spacing: 12) {
                                Text("Recommended Artists")
                                    .font(.headline)
                                    .padding(.horizontal)

                                ForEach(recommendedArtists, id: \.self) { artist in
                                    Button(action: {
                                        searchText = artist
                                        performSearch()
                                    }) {
                                        HStack {
                                            Circle()
                                                .fill(Color.blue.opacity(0.2))
                                                .frame(width: 40, height: 40)
                                                .overlay(
                                                    Image(systemName: "person.fill")
                                                        .foregroundColor(.blue)
                                                )

                                            Text(artist)
                                                .foregroundColor(.primary)

                                            Spacer()

                                            Image(systemName: "chevron.right")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(.horizontal)
                                        .padding(.vertical, 8)
                                    }
                                }
                            }
                        }
                        .padding(.top)
                    }
                }
            }
            .navigationTitle("Search Music")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func performSearch() {
        guard !searchText.isEmpty else { return }

        isSearching = true

        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // In production, this would call music service API
            searchResults = musicManager.recommendedSongs.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.artist.localizedCaseInsensitiveContains(searchText)
            }
            isSearching = false
        }
    }

    private let popularSearches = [
        "Reggaeton",
        "Shakira",
        "Bad Bunny",
        "Spanish Pop",
        "Rosalía",
        "J Balvin"
    ]

    private let recommendedArtists = [
        "Shakira",
        "Enrique Iglesias",
        "Marc Anthony",
        "Bad Bunny",
        "Rosalía",
        "J Balvin",
        "Maluma",
        "Daddy Yankee"
    ]
}

struct SearchResultRow: View {
    let song: Song
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Thumbnail
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "music.note")
                            .foregroundColor(.gray)
                    )

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

                        HStack(spacing: 2) {
                            ForEach(0..<3) { index in
                                Circle()
                                    .fill(index < song.difficultyLevel ? Color.blue : Color.gray.opacity(0.3))
                                    .frame(width: 4, height: 4)
                            }
                        }
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(song.duration)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("\(song.vocabularyCount) words")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
            }
            .padding()
        }
    }
}

#Preview {
    MusicSearchView(musicManager: MusicManager()) { _ in }
}
