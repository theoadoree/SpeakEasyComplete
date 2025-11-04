//
//  LearningContentManager.swift
//  SpeakEasy
//
//  Coordinates all learning content across the Learn tab
//

import Foundation
import Combine
import SwiftUI

class LearningContentManager: ObservableObject {
    // MARK: - Published Properties
    @Published var isLoading = false
    @Published var searchResults: [Any] = []
    @Published var lessonModules: [LessonModule] = []
    @Published var stories: [Story] = []
    @Published var videos: [Video] = []
    @Published var grammarTopics: [GrammarTopic] = []

    // MARK: - Services
    private let openAIService: OpenAIService
    private let adaptiveLearningService: AdaptiveLearningService
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init() {
        self.openAIService = OpenAIService()
        self.adaptiveLearningService = AdaptiveLearningService()
        loadInitialContent()
    }

    // MARK: - Content Loading
    func loadContent(for category: LearnView.ContentCategory) {
        isLoading = true

        Task {
            await MainActor.run {
                switch category {
                case .lessons:
                    loadLessons()
                case .stories:
                    loadStories()
                case .music:
                    break // Handled by MusicManager
                case .videos:
                    loadVideos()
                case .grammar:
                    loadGrammarTopics()
                }
                isLoading = false
            }
        }
    }

    private func loadInitialContent() {
        loadLessons()
        loadStories()
        loadVideos()
        loadGrammarTopics()
    }

    // MARK: - Lessons
    func loadLessons() {
        lessonModules = ComprehensiveLessonData.allModules
    }

    func generatePersonalizedLesson(for userProfile: UserProfile) async -> LessonModule? {
        // Use AI to generate a lesson based on user's weaknesses and interests
        do {
            let prompt = """
            Create a personalized Spanish lesson for:
            Level: \(userProfile.level)
            Recent mistakes: \(userProfile.recentMistakes.prefix(5).joined(separator: ", "))
            Interests: \(userProfile.interests.joined(separator: ", "))

            Generate a 15-minute lesson with:
            - Title and description
            - 8-12 vocabulary words
            - 1 key grammar point
            - Practical examples
            - Real-world application
            """

            // In production, call OpenAI API
            // For now, return a sample lesson
            return sampleGeneratedLesson()
        } catch {
            print("Error generating lesson: \(error)")
            return nil
        }
    }

    private func sampleGeneratedLesson() -> LessonModule {
        LessonModule(
            id: UUID().uuidString,
            title: "AI-Generated: Expressing Emotions",
            description: "Learn to express your feelings and emotions in Spanish",
            level: "Intermediate",
            duration: 15,
            vocabularyCount: 12,
            progress: 0.0,
            isCompleted: false,
            topics: ["Feelings", "Reactions", "Emotional Expressions", "Idioms"]
        )
    }

    // MARK: - Stories
    func loadStories() {
        stories = [
            Story(
                id: "1",
                title: "El Café Misterioso",
                description: "A mysterious café appears in Madrid every full moon...",
                level: "Beginner",
                duration: 5,
                wordCount: 250,
                genre: "Mystery",
                isCompleted: false,
                progress: 0.0,
                thumbnailColor: .blue
            ),
            Story(
                id: "2",
                title: "La Fiesta de Cumpleaños",
                description: "Maria plans a surprise birthday party for her best friend",
                level: "Beginner",
                duration: 4,
                wordCount: 180,
                genre: "Slice of Life",
                isCompleted: false,
                progress: 0.0,
                thumbnailColor: .pink
            ),
            Story(
                id: "3",
                title: "El Viaje a Barcelona",
                description: "Follow Carlos on his first trip to Barcelona",
                level: "Intermediate",
                duration: 8,
                wordCount: 420,
                genre: "Travel",
                isCompleted: false,
                progress: 0.3,
                thumbnailColor: .orange
            ),
            Story(
                id: "4",
                title: "La Receta Secreta",
                description: "A family recipe holds more than just cooking instructions",
                level: "Intermediate",
                duration: 7,
                wordCount: 350,
                genre: "Drama",
                isCompleted: false,
                progress: 0.0,
                thumbnailColor: .green
            ),
            Story(
                id: "5",
                title: "El Fantasma del Teatro",
                description: "Strange things happen at the old theater in Buenos Aires",
                level: "Advanced",
                duration: 12,
                wordCount: 680,
                genre: "Mystery",
                isCompleted: false,
                progress: 0.0,
                thumbnailColor: .purple
            )
        ]
    }

    func generateAIStory(level: String, topic: String) async -> Story? {
        // Use OpenAI to generate a custom story
        do {
            let prompt = """
            Write a short story in Spanish for \(level) level learners about: \(topic)

            Requirements:
            - 200-400 words
            - Include dialogue
            - Use appropriate vocabulary for level
            - Include 1-2 cultural references
            - Engaging and educational
            """

            // In production, call OpenAI API
            return nil
        } catch {
            return nil
        }
    }

    // MARK: - Videos
    func loadVideos() {
        videos = [
            Video(
                id: "1",
                title: "Spanish Pronunciation Guide",
                description: "Master the basics of Spanish pronunciation",
                duration: "10:24",
                level: "Beginner",
                category: "Pronunciation",
                thumbnailURL: nil,
                videoURL: nil,
                subtitlesAvailable: true,
                vocabularyCount: 15
            ),
            Video(
                id: "2",
                title: "Ordering Food in Spanish",
                description: "Learn essential phrases for restaurants",
                duration: "8:15",
                level: "Beginner",
                category: "Conversation",
                thumbnailURL: nil,
                videoURL: nil,
                subtitlesAvailable: true,
                vocabularyCount: 25
            ),
            Video(
                id: "3",
                title: "Spanish Subjunctive Mood",
                description: "Understanding when and how to use the subjunctive",
                duration: "15:30",
                level: "Intermediate",
                category: "Grammar",
                thumbnailURL: nil,
                videoURL: nil,
                subtitlesAvailable: true,
                vocabularyCount: 20
            ),
            Video(
                id: "4",
                title: "Mexican Slang & Expressions",
                description: "Common slang used in Mexico",
                duration: "12:45",
                level: "Intermediate",
                category: "Culture",
                thumbnailURL: nil,
                videoURL: nil,
                subtitlesAvailable: true,
                vocabularyCount: 30
            ),
            Video(
                id: "5",
                title: "Business Spanish: Meetings",
                description: "Professional vocabulary for business meetings",
                duration: "18:20",
                level: "Advanced",
                category: "Business",
                thumbnailURL: nil,
                videoURL: nil,
                subtitlesAvailable: true,
                vocabularyCount: 45
            )
        ]
    }

    // MARK: - Grammar
    func loadGrammarTopics() {
        grammarTopics = [
            GrammarTopic(
                id: "1",
                title: "Present Tense",
                description: "Regular and irregular verb conjugations",
                level: "Beginner",
                subtopics: ["Regular -ar verbs", "Regular -er/-ir verbs", "Irregular verbs", "Stem-changing verbs"],
                examples: 8,
                exercises: 15
            ),
            GrammarTopic(
                id: "2",
                title: "Ser vs Estar",
                description: "Understanding the two forms of 'to be'",
                level: "Beginner",
                subtopics: ["Permanent characteristics (Ser)", "Temporary states (Estar)", "Location", "Common mistakes"],
                examples: 12,
                exercises: 20
            ),
            GrammarTopic(
                id: "3",
                title: "Past Tenses",
                description: "Preterite vs Imperfect",
                level: "Intermediate",
                subtopics: ["Preterite", "Imperfect", "When to use each", "Narrative structures"],
                examples: 15,
                exercises: 25
            ),
            GrammarTopic(
                id: "4",
                title: "Subjunctive Mood",
                description: "Formation and uses of the subjunctive",
                level: "Advanced",
                subtopics: ["Present subjunctive", "Imperfect subjunctive", "Triggers", "Complex sentences"],
                examples: 20,
                exercises: 30
            ),
            GrammarTopic(
                id: "5",
                title: "Por vs Para",
                description: "Distinguishing between these challenging prepositions",
                level: "Intermediate",
                subtopics: ["Uses of Por", "Uses of Para", "Common expressions", "Practice scenarios"],
                examples: 18,
                exercises: 22
            )
        ]
    }

    // MARK: - Search
    func search(query: String, in category: LearnView.ContentCategory) {
        guard !query.isEmpty else {
            clearSearch()
            return
        }

        let lowercaseQuery = query.lowercased()

        switch category {
        case .lessons:
            searchResults = lessonModules.filter {
                $0.title.lowercased().contains(lowercaseQuery) ||
                $0.description.lowercased().contains(lowercaseQuery) ||
                $0.topics.contains(where: { $0.lowercased().contains(lowercaseQuery) })
            }
        case .stories:
            searchResults = stories.filter {
                $0.title.lowercased().contains(lowercaseQuery) ||
                $0.description.lowercased().contains(lowercaseQuery) ||
                $0.genre.lowercased().contains(lowercaseQuery)
            }
        case .videos:
            searchResults = videos.filter {
                $0.title.lowercased().contains(lowercaseQuery) ||
                $0.description.lowercased().contains(lowercaseQuery) ||
                $0.category.lowercased().contains(lowercaseQuery)
            }
        case .grammar:
            searchResults = grammarTopics.filter {
                $0.title.lowercased().contains(lowercaseQuery) ||
                $0.description.lowercased().contains(lowercaseQuery) ||
                $0.subtopics.contains(where: { $0.lowercased().contains(lowercaseQuery) })
            }
        case .music:
            // Music search handled by MusicManager
            break
        }
    }

    func clearSearch() {
        searchResults = []
    }
}

// MARK: - Supporting Models

struct Story: Identifiable {
    let id: String
    let title: String
    let description: String
    let level: String
    let duration: Int // minutes
    let wordCount: Int
    let genre: String
    let isCompleted: Bool
    let progress: Double
    let thumbnailColor: Color
}

struct Video: Identifiable {
    let id: String
    let title: String
    let description: String
    let duration: String
    let level: String
    let category: String
    let thumbnailURL: String?
    let videoURL: String?
    let subtitlesAvailable: Bool
    let vocabularyCount: Int
}

struct GrammarTopic: Identifiable {
    let id: String
    let title: String
    let description: String
    let level: String
    let subtopics: [String]
    let examples: Int
    let exercises: Int
}

struct UserProfile {
    let level: String
    let recentMistakes: [String]
    let interests: [String]
}
