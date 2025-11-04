import Foundation

/// Implements personalized, interest-based learning
/// Generates content aligned with learner goals and interests
@MainActor
class PersonalizedLearningService: ObservableObject {
    static let shared = PersonalizedLearningService()

    @Published var userInterests: [String] = []
    @Published var learningGoals: [LearningGoal] = []
    @Published var recommendedContent: [ContentRecommendation] = []

    private let openAIService = OpenAIService.shared
    private let comprehensibleInputService = ComprehensibleInputService.shared

    // MARK: - Interest-Based Content Generation

    func generatePersonalizedContent(
        interests: [String],
        level: DifficultyLevel,
        language: String,
        contentType: PersonalizedContentType
    ) async -> PersonalizedContent? {
        let prompt = """
        Create \(contentType.rawValue) in \(language) for a \(level.rawValue) learner interested in: \(interests.joined(separator: ", "))

        Requirements:
        - Make it HIGHLY RELEVANT to their interests
        - Use vocabulary from their interest areas
        - Create scenarios they would actually encounter
        - Make it engaging and motivating
        - Appropriate difficulty level (i+1)

        Content should feel personally meaningful, not generic.
        """

        do {
            let response = try await openAIService.sendMessage(prompt)
            return parsePersonalizedContent(from: response, type: contentType, level: level)
        } catch {
            return nil
        }
    }

    // MARK: - Learning Path Personalization

    func generatePersonalizedLearningPath(
        for goal: LearningGoal,
        currentLevel: DifficultyLevel,
        interests: [String],
        language: String
    ) async -> LearningPath? {
        let prompt = """
        Create a personalized 4-week learning path for:

        Goal: \(goal.description)
        Current level: \(currentLevel.rawValue)
        Interests: \(interests.joined(separator: ", "))
        Language: \(language)

        Provide week-by-week plan with:
        - Specific topics (related to their interests)
        - Skills to practice each week
        - Vocabulary themes
        - Conversation scenarios
        - Suggested activities

        Make it achievable and motivating.
        Tie everything to their personal interests and goals.
        """

        do {
            let response = try await openAIService.sendMessage(prompt)
            return parseLearningPath(from: response, goal: goal)
        } catch {
            return nil
        }
    }

    // MARK: - Real-World Relevance

    func generateRealWorldScenarios(
        for purpose: String,
        interests: [String],
        level: DifficultyLevel,
        language: String
    ) async -> [RealWorldScenario] {
        let prompt = """
        Create 5 realistic \(language) conversation scenarios for someone who:

        Purpose: \(purpose)
        Interests: \(interests.joined(separator: ", "))
        Level: \(level.rawValue)

        For each scenario provide:
        1. Setting (where and when)
        2. People involved
        3. Goal (what needs to be accomplished)
        4. Key phrases needed
        5. Potential challenges

        Make scenarios authentic and personally relevant.
        Things they might ACTUALLY need to do in the target language.
        """

        do {
            let response = try await openAIService.sendMessage(prompt)
            return parseRealWorldScenarios(from: response, level: level)
        } catch {
            return []
        }
    }

    // MARK: - Content Recommendation Engine

    func recommendNextContent(
        based on history: [ContentInteraction],
        interests: [String],
        weakAreas: [String],
        level: DifficultyLevel
    ) -> [ContentRecommendation] {
        var recommendations: [ContentRecommendation] = []

        // Recommend based on interests
        for interest in interests {
            recommendations.append(ContentRecommendation(
                title: "Story about \(interest)",
                type: .story,
                relevanceScore: 0.9,
                difficulty: level,
                reason: "Matches your interest in \(interest)"
            ))
        }

        // Recommend based on weak areas
        for weakArea in weakAreas {
            recommendations.append(ContentRecommendation(
                title: "Practice: \(weakArea)",
                type: .practice,
                relevanceScore: 0.85,
                difficulty: level,
                reason: "Targets your area for improvement"
            ))
        }

        // Sort by relevance
        return recommendations.sorted { $0.relevanceScore > $1.relevanceScore }
    }

    // MARK: - Goal Tracking

    func trackProgress(
        toward goal: LearningGoal,
        completedActivities: [CompletedActivity]
    ) -> GoalProgress {
        let totalActivities = goal.milestones.reduce(0) { $0 + $1.requiredActivities }
        let completed = completedActivities.count

        let progress = min(1.0, Double(completed) / Double(totalActivities))

        return GoalProgress(
            goal: goal,
            progress: progress,
            completedMilestones: countCompletedMilestones(goal: goal, activities: completedActivities),
            nextMilestone: getNextMilestone(goal: goal, activities: completedActivities)
        )
    }

    // MARK: - Adaptive Difficulty

    func adjustDifficultyBased(
        on performance: [PerformanceMetric],
        currentLevel: DifficultyLevel
    ) -> DifficultyAdjustment {
        let recentPerformance = performance.suffix(10)
        let averageScore = recentPerformance.reduce(0.0) { $0 + $1.score } / Double(recentPerformance.count)

        if averageScore > 0.90 {
            // Performing very well - increase challenge
            return DifficultyAdjustment(
                recommendedLevel: nextLevel(currentLevel),
                reason: "Excellent performance! Ready for more challenge.",
                confidence: 0.85
            )
        } else if averageScore < 0.60 {
            // Struggling - maintain or simplify
            return DifficultyAdjustment(
                recommendedLevel: currentLevel,
                reason: "Let's practice more at this level before advancing.",
                confidence: 0.75
            )
        } else {
            // Just right - stay at current level with some i+1
            return DifficultyAdjustment(
                recommendedLevel: currentLevel,
                reason: "Current level is optimal for learning.",
                confidence: 0.90
            )
        }
    }

    // MARK: - Helper Methods

    private func parsePersonalizedContent(
        from response: String,
        type: PersonalizedContentType,
        level: DifficultyLevel
    ) -> PersonalizedContent {
        return PersonalizedContent(
            id: UUID(),
            type: type,
            content: response,
            level: level,
            relevanceScore: 0.9
        )
    }

    private func parseLearningPath(from response: String, goal: LearningGoal) -> LearningPath {
        return LearningPath(
            goal: goal,
            weeks: [],
            totalDuration: 4
        )
    }

    private func parseRealWorldScenarios(from response: String, level: DifficultyLevel) -> [RealWorldScenario] {
        return []
    }

    private func countCompletedMilestones(goal: LearningGoal, activities: [CompletedActivity]) -> Int {
        return 0
    }

    private func getNextMilestone(goal: LearningGoal, activities: [CompletedActivity]) -> Milestone? {
        return goal.milestones.first
    }

    private func nextLevel(_ current: DifficultyLevel) -> DifficultyLevel {
        switch current {
        case .beginner: return .intermediate
        case .intermediate: return .advanced
        case .advanced: return .advanced
        }
    }
}

// MARK: - Supporting Models

enum PersonalizedContentType: String {
    case story = "a story"
    case dialogue = "a dialogue"
    case article = "an article"
    case scenario = "a practice scenario"
}

struct PersonalizedContent: Identifiable {
    let id: UUID
    let type: PersonalizedContentType
    let content: String
    let level: DifficultyLevel
    let relevanceScore: Double
}

struct LearningGoal: Identifiable {
    let id = UUID()
    let description: String
    let targetDate: Date
    let milestones: [Milestone]
    let category: GoalCategory

    enum GoalCategory {
        case conversation
        case travel
        case work
        case academic
        case cultural
        case general
    }
}

struct Milestone: Identifiable {
    let id = UUID()
    let title: String
    let requiredActivities: Int
    var completed: Bool = false
}

struct LearningPath {
    let goal: LearningGoal
    let weeks: [WeeklyPlan]
    let totalDuration: Int
}

struct WeeklyPlan {
    let weekNumber: Int
    let topics: [String]
    let skills: [String]
    let vocabulary: [String]
    let activities: [String]
}

struct RealWorldScenario: Identifiable {
    let id = UUID()
    let setting: String
    let people: [String]
    let goal: String
    let keyPhrases: [String]
    let challenges: [String]
}

struct ContentRecommendation: Identifiable {
    let id = UUID()
    let title: String
    let type: PersonalizedContentType
    let relevanceScore: Double
    let difficulty: DifficultyLevel
    let reason: String
}

struct ContentInteraction {
    let contentId: UUID
    let duration: TimeInterval
    let completed: Bool
    let rating: Double?
    let timestamp: Date
}

struct CompletedActivity {
    let type: String
    let timestamp: Date
    let score: Double
}

struct GoalProgress {
    let goal: LearningGoal
    let progress: Double
    let completedMilestones: Int
    let nextMilestone: Milestone?
}

struct PerformanceMetric {
    let activity: String
    let score: Double
    let timestamp: Date
}

struct DifficultyAdjustment {
    let recommendedLevel: DifficultyLevel
    let reason: String
    let confidence: Double
}
