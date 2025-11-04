//
//  MusicManager.swift
//  SpeakEasy
//
//  Created by Claude on 2025-11-01.
//

import Foundation
import Combine

// MARK: - Models

struct Song: Identifiable, Codable {
    let id: String
    let title: String
    let artist: String
    let album: String
    let duration: String
    let spotifyURL: String?
    let appleMusicURL: String?
    let youtubeURL: String?
    let difficultyLevel: Int // 1-3 (beginner, intermediate, advanced)
    let vocabularyCount: Int
    let lyrics: String?
    let genre: String
    let releaseYear: Int?

    var previewURL: String? // 30-second preview
}

struct MusicPlaylist: Identifiable, Codable {
    let id: String
    let name: String
    let songCount: Int
    let coverArtURL: String?
    let songs: [Song]
}

struct MusicGenre: Identifiable {
    let id: String
    let name: String
    let icon: String
    let color: Color
    let songCount: Int

    static let popular = [
        MusicGenre(id: "reggaeton", name: "Reggaeton", icon: "music.mic", color: .orange, songCount: 250),
        MusicGenre(id: "pop", name: "Pop Latino", icon: "star.fill", color: .pink, songCount: 180),
        MusicGenre(id: "rock", name: "Rock en Español", icon: "guitars.fill", color: .red, songCount: 120),
        MusicGenre(id: "salsa", name: "Salsa", icon: "music.note", color: .yellow, songCount: 95),
        MusicGenre(id: "ballad", name: "Baladas", icon: "heart.fill", color: .purple, songCount: 140),
        MusicGenre(id: "regional", name: "Regional Mexicano", icon: "music.note.list", color: .green, songCount: 200)
    ]
}

import SwiftUI

// MARK: - Music Manager

class MusicManager: ObservableObject {
    @Published var isConnected = false
    @Published var connectedService: MusicService?
    @Published var userPlaylists: [MusicPlaylist] = []
    @Published var recommendedSongs: [Song] = []
    @Published var trendingSongs: [Song] = []
    @Published var genres: [MusicGenre] = MusicGenre.popular
    @Published var isLoading = false

    private var cancellables = Set<AnyCancellable>()
    private let openAIService: OpenAIService

    enum MusicService {
        case spotify
        case appleMusic
        case youtube
    }

    init() {
        // Initialize OpenAI service for LLM-based recommendations
        self.openAIService = OpenAIService()
        loadSampleData()
        checkConnectedServices()
    }

    // MARK: - Service Connection

    func checkConnectedServices() {
        // Check if user has connected Spotify or Apple Music
        // For now, using sample data
        if let savedService = UserDefaults.standard.string(forKey: "connectedMusicService") {
            isConnected = true
            connectedService = savedService == "spotify" ? .spotify : .appleMusic
            loadUserPlaylists()
        }
    }

    func connectService(_ service: MusicService) {
        isConnected = true
        connectedService = service
        UserDefaults.standard.set(service == .spotify ? "spotify" : "appleMusic", forKey: "connectedMusicService")
        loadUserPlaylists()
    }

    func disconnectService() {
        isConnected = false
        connectedService = nil
        userPlaylists = []
        UserDefaults.standard.removeObject(forKey: "connectedMusicService")
    }

    // MARK: - Load Content

    func loadUserPlaylists() {
        // In production, this would call Spotify/Apple Music API
        userPlaylists = [
            MusicPlaylist(
                id: "1",
                name: "Spanish Favorites",
                songCount: 24,
                coverArtURL: nil,
                songs: []
            ),
            MusicPlaylist(
                id: "2",
                name: "Learning Spanish",
                songCount: 15,
                coverArtURL: nil,
                songs: []
            ),
            MusicPlaylist(
                id: "3",
                name: "Reggaeton Hits",
                songCount: 30,
                coverArtURL: nil,
                songs: []
            )
        ]
    }

    func loadRecommendations() {
        Task {
            await generateAIRecommendations()
        }
    }

    @MainActor
    private func generateAIRecommendations() async {
        isLoading = true

        // Use LLM to generate personalized song recommendations
        let prompt = """
        Generate 5 Spanish song recommendations for a language learner.
        Consider:
        - User level: Intermediate
        - Interests: Pop, Reggaeton
        - Learning goals: Vocabulary expansion, pronunciation

        For each song, provide:
        - Title and artist
        - Difficulty level (1-3)
        - Why it's good for learning
        - Estimated vocabulary count

        Return as JSON array.
        """

        // For now, use sample data
        // In production, call OpenAI API
        recommendedSongs = sampleRecommendedSongs()

        isLoading = false
    }

    func loadSongsForGenre(_ genre: MusicGenre) {
        // Load songs for specific genre
        // In production, this would filter from music service API
    }

    // MARK: - Sample Data

    private func loadSampleData() {
        recommendedSongs = sampleRecommendedSongs()
        trendingSongs = sampleTrendingSongs()
    }

    private func sampleRecommendedSongs() -> [Song] {
        [
            Song(
                id: "1",
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
                id: "2",
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
                id: "3",
                title: "Despacito",
                artist: "Luis Fonsi ft. Daddy Yankee",
                album: "Vida",
                duration: "3:48",
                spotifyURL: nil,
                appleMusicURL: nil,
                youtubeURL: nil,
                difficultyLevel: 2,
                vocabularyCount: 38,
                lyrics: nil,
                genre: "Reggaeton",
                releaseYear: 2017
            ),
            Song(
                id: "4",
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
            ),
            Song(
                id: "5",
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
            )
        ]
    }

    private func sampleTrendingSongs() -> [Song] {
        [
            Song(
                id: "t1",
                title: "Ella Baila Sola",
                artist: "Eslabón Armado, Peso Pluma",
                album: "Desvelado",
                duration: "2:51",
                spotifyURL: nil,
                appleMusicURL: nil,
                youtubeURL: nil,
                difficultyLevel: 2,
                vocabularyCount: 35,
                lyrics: nil,
                genre: "Regional Mexicano",
                releaseYear: 2023
            ),
            Song(
                id: "t2",
                title: "La Bachata",
                artist: "Manuel Turizo",
                album: "2000",
                duration: "2:56",
                spotifyURL: nil,
                appleMusicURL: nil,
                youtubeURL: nil,
                difficultyLevel: 1,
                vocabularyCount: 32,
                lyrics: nil,
                genre: "Bachata",
                releaseYear: 2022
            ),
            Song(
                id: "t3",
                title: "Shakira: Bzrp Music Sessions",
                artist: "Shakira, Bizarrap",
                album: "Single",
                duration: "3:16",
                spotifyURL: nil,
                appleMusicURL: nil,
                youtubeURL: nil,
                difficultyLevel: 3,
                vocabularyCount: 68,
                lyrics: nil,
                genre: "Urban",
                releaseYear: 2023
            ),
            Song(
                id: "t4",
                title: "Un x100to",
                artist: "Grupo Frontera, Bad Bunny",
                album: "Single",
                duration: "3:31",
                spotifyURL: nil,
                appleMusicURL: nil,
                youtubeURL: nil,
                difficultyLevel: 2,
                vocabularyCount: 42,
                lyrics: nil,
                genre: "Regional Mexicano",
                releaseYear: 2023
            ),
            Song(
                id: "t5",
                title: "TQG",
                artist: "Shakira, Karol G",
                album: "Single",
                duration: "3:23",
                spotifyURL: nil,
                appleMusicURL: nil,
                youtubeURL: nil,
                difficultyLevel: 2,
                vocabularyCount: 55,
                lyrics: nil,
                genre: "Reggaeton",
                releaseYear: 2023
            ),
            Song(
                id: "t6",
                title: "Columbia",
                artist: "Quevedo",
                album: "Donde Quiero Estar",
                duration: "3:05",
                spotifyURL: nil,
                appleMusicURL: nil,
                youtubeURL: nil,
                difficultyLevel: 2,
                vocabularyCount: 38,
                lyrics: nil,
                genre: "Urban",
                releaseYear: 2023
            )
        ]
    }
}
