import Foundation

// MARK: - Comprehensive Lesson Data
// Based on evidence-based language learning principles:
// - Comprehensible Input (i+1)
// - Spaced Repetition
// - Active Production
// - Meaningful Interaction
// - Focus on Form (Noticing)
// - Personalized Content

struct ComprehensiveLessonData {

    // MARK: - All 30 Lessons

    static func getAllLessons(for language: Language) -> [DetailedLesson] {
        return [
            // BEGINNER LEVEL (Lessons 1-10)
            lesson1_Greetings(language: language),
            lesson2_Introductions(language: language),
            lesson3_Numbers1to20(language: language),
            lesson4_ColorsAndShapes(language: language),
            lesson5_DaysOfWeek(language: language),
            lesson6_BasicFamily(language: language),
            lesson7_WeatherAndSeasons(language: language),
            lesson8_SimpleQuestions(language: language),
            lesson9_FoodBasics(language: language),
            lesson10_LocationsNearby(language: language),

            // ELEMENTARY LEVEL (Lessons 11-20)
            lesson11_PresentTense(language: language),
            lesson12_ShoppingBasics(language: language),
            lesson13_TransportationTravel(language: language),
            lesson14_TimeAndSchedule(language: language),
            lesson15_BodyAndHealth(language: language),
            lesson16_HobbiesInterests(language: language),
            lesson17_RestaurantDining(language: language),
            lesson18_PastTense(language: language),
            lesson19_EmotionsFeelings(language: language),
            lesson20_DirectionsNavigation(language: language),

            // INTERMEDIATE LEVEL (Lessons 21-25)
            lesson21_FuturePlans(language: language),
            lesson22_WorkCareer(language: language),
            lesson23_TechnologyMedia(language: language),
            lesson24_OpinionsDebate(language: language),
            lesson25_ConditionalTense(language: language),

            // ADVANCED LEVEL (Lessons 26-30)
            lesson26_IdiomsExpressions(language: language),
            lesson27_CulturalTraditions(language: language),
            lesson28_ComplexNarrative(language: language),
            lesson29_FormalBusiness(language: language),
            lesson30_SubjectiveMood(language: language)
        ]
    }

    // MARK: - BEGINNER LESSONS (1-10)

    static func lesson1_Greetings(language: Language) -> DetailedLesson {
        let content = LanguageLessonContent.getContent(for: language, lessonNumber: 1)

        return DetailedLesson(
            id: "lesson-1",
            number: 1,
            title: content.title,
            subtitle: "Start your language journey",
            language: language,
            level: .beginner,
            category: .greetings,
            duration: 15,
            objectives: [
                "Master basic greetings in formal and informal contexts",
                "Learn to introduce yourself with name and origin",
                "Understand cultural greeting customs",
                "Practice pronunciation of greeting phrases",
                "Respond appropriately to common greetings"
            ],

            // Comprehensible Input (i+1)
            vocabularyItems: content.vocabulary,

            // Focus on Form (Noticing)
            grammarPoints: [
                GrammarPoint(
                    title: "Greeting Structure",
                    explanation: content.grammarExplanation,
                    examples: content.grammarExamples,
                    commonMistakes: ["Don't use formal greetings with friends", "Match the time of day with appropriate greeting"]
                )
            ],

            // Meaningful Interaction
            dialogues: content.dialogues,

            // Active Production
            practiceExercises: [
                PracticeExercise(
                    type: .speaking,
                    instruction: "Introduce yourself to three different people: a friend, a teacher, and a stranger",
                    difficulty: .beginner,
                    estimatedTime: 5
                ),
                PracticeExercise(
                    type: .listening,
                    instruction: "Listen and identify formal vs informal greetings",
                    difficulty: .beginner,
                    estimatedTime: 3
                ),
                PracticeExercise(
                    type: .roleplay,
                    instruction: "Practice greeting someone at different times of day",
                    difficulty: .beginner,
                    estimatedTime: 5
                )
            ],

            // Spaced Repetition - Key phrases to review
            srsKeyPhrases: content.srsKeyPhrases,

            culturalNotes: content.culturalNotes,
            fluencyTechniques: content.fluencyTechniques,

            // Personalized scenarios
            conversationScenarios: content.scenarios,

            pronunciationTips: content.pronunciationTips,

            nextLessonSuggestion: "lesson-2"
        )
    }

    static func lesson2_Introductions(language: Language) -> DetailedLesson {
        let content = LanguageLessonContent.getContent(for: language, lessonNumber: 2)

        return DetailedLesson(
            id: "lesson-2",
            number: 2,
            title: content.title,
            subtitle: "Tell your story",
            language: language,
            level: .beginner,
            category: .greetings,
            duration: 20,
            objectives: [
                "Share detailed personal information",
                "Ask and answer questions about name, age, nationality",
                "Use possessive pronouns correctly",
                "Express where you're from and where you live",
                "Practice active listening skills"
            ],
            vocabularyItems: content.vocabulary,
            grammarPoints: [
                GrammarPoint(
                    title: "Personal Pronouns and 'To Be'",
                    explanation: content.grammarExplanation,
                    examples: content.grammarExamples,
                    commonMistakes: ["Forgetting verb conjugation", "Mixing up formal/informal 'you'"]
                )
            ],
            dialogues: content.dialogues,
            practiceExercises: [
                PracticeExercise(
                    type: .speaking,
                    instruction: "Create a 1-minute self-introduction speech",
                    difficulty: .beginner,
                    estimatedTime: 10
                ),
                PracticeExercise(
                    type: .writing,
                    instruction: "Write 5 sentences about yourself",
                    difficulty: .beginner,
                    estimatedTime: 5
                ),
                PracticeExercise(
                    type: .listening,
                    instruction: "Listen to introductions and identify key information",
                    difficulty: .beginner,
                    estimatedTime: 5
                )
            ],
            srsKeyPhrases: content.srsKeyPhrases,
            culturalNotes: content.culturalNotes,
            fluencyTechniques: content.fluencyTechniques,
            conversationScenarios: content.scenarios,
            pronunciationTips: content.pronunciationTips,
            nextLessonSuggestion: "lesson-3"
        )
    }

    static func lesson3_Numbers1to20(language: Language) -> DetailedLesson {
        let content = LanguageLessonContent.getContent(for: language, lessonNumber: 3)

        return DetailedLesson(
            id: "lesson-3",
            number: 3,
            title: content.title,
            subtitle: "Count with confidence",
            language: language,
            level: .beginner,
            category: .numbers,
            duration: 15,
            objectives: [
                "Count from 1 to 20 accurately",
                "Use numbers in practical contexts (phone, age, price)",
                "Understand number pronunciation patterns",
                "Ask 'how many' questions",
                "Practice number listening comprehension"
            ],
            vocabularyItems: content.vocabulary,
            grammarPoints: [
                GrammarPoint(
                    title: "Number Formation",
                    explanation: content.grammarExplanation,
                    examples: content.grammarExamples,
                    commonMistakes: ["Confusing similar-sounding numbers", "Incorrect pronunciation of teens"]
                )
            ],
            dialogues: content.dialogues,
            practiceExercises: [
                PracticeExercise(
                    type: .speaking,
                    instruction: "Say 10 random numbers aloud, then verify",
                    difficulty: .beginner,
                    estimatedTime: 5
                ),
                PracticeExercise(
                    type: .listening,
                    instruction: "Listen and write down numbers you hear",
                    difficulty: .beginner,
                    estimatedTime: 5
                ),
                PracticeExercise(
                    type: .game,
                    instruction: "Number bingo - match spoken numbers to written",
                    difficulty: .beginner,
                    estimatedTime: 5
                )
            ],
            srsKeyPhrases: content.srsKeyPhrases,
            culturalNotes: content.culturalNotes,
            fluencyTechniques: content.fluencyTechniques,
            conversationScenarios: content.scenarios,
            pronunciationTips: content.pronunciationTips,
            nextLessonSuggestion: "lesson-4"
        )
    }

    static func lesson4_ColorsAndShapes(language: Language) -> DetailedLesson {
        let content = LanguageLessonContent.getContent(for: language, lessonNumber: 4)

        return DetailedLesson(
            id: "lesson-4",
            number: 4,
            title: content.title,
            subtitle: "Describe the world around you",
            language: language,
            level: .beginner,
            category: .grammar,
            duration: 15,
            objectives: [
                "Name 10+ common colors",
                "Describe objects using color and shape",
                "Use adjective-noun agreement correctly",
                "Ask about colors and descriptions",
                "Build descriptive vocabulary"
            ],
            vocabularyItems: content.vocabulary,
            grammarPoints: [
                GrammarPoint(
                    title: "Adjectives and Agreement",
                    explanation: content.grammarExplanation,
                    examples: content.grammarExamples,
                    commonMistakes: ["Wrong adjective placement", "Missing gender/number agreement"]
                )
            ],
            dialogues: content.dialogues,
            practiceExercises: [
                PracticeExercise(
                    type: .speaking,
                    instruction: "Describe 5 objects in your room with color and shape",
                    difficulty: .beginner,
                    estimatedTime: 5
                ),
                PracticeExercise(
                    type: .game,
                    instruction: "I Spy game - describe objects for others to guess",
                    difficulty: .beginner,
                    estimatedTime: 7
                ),
                PracticeExercise(
                    type: .writing,
                    instruction: "Write descriptions of 3 favorite possessions",
                    difficulty: .beginner,
                    estimatedTime: 5
                )
            ],
            srsKeyPhrases: content.srsKeyPhrases,
            culturalNotes: content.culturalNotes,
            fluencyTechniques: content.fluencyTechniques,
            conversationScenarios: content.scenarios,
            pronunciationTips: content.pronunciationTips,
            nextLessonSuggestion: "lesson-5"
        )
    }

    static func lesson5_DaysOfWeek(language: Language) -> DetailedLesson {
        let content = LanguageLessonContent.getContent(for: language, lessonNumber: 5)

        return DetailedLesson(
            id: "lesson-5",
            number: 5,
            title: content.title,
            subtitle: "Master time vocabulary",
            language: language,
            level: .beginner,
            category: .time,
            duration: 15,
            objectives: [
                "Name all days of the week",
                "Discuss schedules and routines",
                "Use time prepositions (on, at, in)",
                "Talk about past and future days",
                "Ask about appointments and plans"
            ],
            vocabularyItems: content.vocabulary,
            grammarPoints: [
                GrammarPoint(
                    title: "Time Expressions",
                    explanation: content.grammarExplanation,
                    examples: content.grammarExamples,
                    commonMistakes: ["Wrong preposition with time", "Confusing 'on' vs 'at' vs 'in'"]
                )
            ],
            dialogues: content.dialogues,
            practiceExercises: [
                PracticeExercise(
                    type: .speaking,
                    instruction: "Describe your weekly schedule",
                    difficulty: .beginner,
                    estimatedTime: 5
                ),
                PracticeExercise(
                    type: .listening,
                    instruction: "Listen to schedule and identify which days",
                    difficulty: .beginner,
                    estimatedTime: 5
                ),
                PracticeExercise(
                    type: .roleplay,
                    instruction: "Make plans with a friend for the week",
                    difficulty: .beginner,
                    estimatedTime: 5
                )
            ],
            srsKeyPhrases: content.srsKeyPhrases,
            culturalNotes: content.culturalNotes,
            fluencyTechniques: content.fluencyTechniques,
            conversationScenarios: content.scenarios,
            pronunciationTips: content.pronunciationTips,
            nextLessonSuggestion: "lesson-6"
        )
    }

    static func lesson6_BasicFamily(language: Language) -> DetailedLesson {
        let content = LanguageLessonContent.getContent(for: language, lessonNumber: 6)

        return DetailedLesson(
            id: "lesson-6",
            number: 6,
            title: content.title,
            subtitle: "Talk about loved ones",
            language: language,
            level: .beginner,
            category: .family,
            duration: 20,
            objectives: [
                "Name immediate family members",
                "Use possessive adjectives correctly",
                "Describe family relationships",
                "Talk about family size and structure",
                "Ask polite questions about family"
            ],
            vocabularyItems: content.vocabulary,
            grammarPoints: [
                GrammarPoint(
                    title: "Possessive Adjectives",
                    explanation: content.grammarExplanation,
                    examples: content.grammarExamples,
                    commonMistakes: ["Confusing 'his' and 'her'", "Wrong possessive form"]
                )
            ],
            dialogues: content.dialogues,
            practiceExercises: [
                PracticeExercise(
                    type: .speaking,
                    instruction: "Describe your family tree for 2 minutes",
                    difficulty: .beginner,
                    estimatedTime: 7
                ),
                PracticeExercise(
                    type: .writing,
                    instruction: "Write about 3 family members",
                    difficulty: .beginner,
                    estimatedTime: 8
                ),
                PracticeExercise(
                    type: .listening,
                    instruction: "Listen to family description and draw family tree",
                    difficulty: .beginner,
                    estimatedTime: 5
                )
            ],
            srsKeyPhrases: content.srsKeyPhrases,
            culturalNotes: content.culturalNotes,
            fluencyTechniques: content.fluencyTechniques,
            conversationScenarios: content.scenarios,
            pronunciationTips: content.pronunciationTips,
            nextLessonSuggestion: "lesson-7"
        )
    }

    static func lesson7_WeatherAndSeasons(language: Language) -> DetailedLesson {
        let content = LanguageLessonContent.getContent(for: language, lessonNumber: 7)

        return DetailedLesson(
            id: "lesson-7",
            number: 7,
            title: content.title,
            subtitle: "Discuss climate and conditions",
            language: language,
            level: .beginner,
            category: .culture,
            duration: 15,
            objectives: [
                "Name all four seasons",
                "Describe weather conditions",
                "Use weather expressions idiomatically",
                "Discuss temperature and climate",
                "Make weather-related small talk"
            ],
            vocabularyItems: content.vocabulary,
            grammarPoints: [
                GrammarPoint(
                    title: "Impersonal Expressions",
                    explanation: content.grammarExplanation,
                    examples: content.grammarExamples,
                    commonMistakes: ["Using 'I' instead of 'it' for weather", "Wrong weather verb"]
                )
            ],
            dialogues: content.dialogues,
            practiceExercises: [
                PracticeExercise(
                    type: .speaking,
                    instruction: "Give a weather report for your location",
                    difficulty: .beginner,
                    estimatedTime: 5
                ),
                PracticeExercise(
                    type: .listening,
                    instruction: "Listen to weather forecast and note key details",
                    difficulty: .beginner,
                    estimatedTime: 5
                ),
                PracticeExercise(
                    type: .roleplay,
                    instruction: "Make small talk about the weather",
                    difficulty: .beginner,
                    estimatedTime: 5
                )
            ],
            srsKeyPhrases: content.srsKeyPhrases,
            culturalNotes: content.culturalNotes,
            fluencyTechniques: content.fluencyTechniques,
            conversationScenarios: content.scenarios,
            pronunciationTips: content.pronunciationTips,
            nextLessonSuggestion: "lesson-8"
        )
    }

    static func lesson8_SimpleQuestions(language: Language) -> DetailedLesson {
        let content = LanguageLessonContent.getContent(for: language, lessonNumber: 8)

        return DetailedLesson(
            id: "lesson-8",
            number: 8,
            title: content.title,
            subtitle: "Ask and understand",
            language: language,
            level: .beginner,
            category: .conversation,
            duration: 20,
            objectives: [
                "Master question words (who, what, where, when, why, how)",
                "Form yes/no questions correctly",
                "Use rising intonation for questions",
                "Answer questions appropriately",
                "Practice information gathering"
            ],
            vocabularyItems: content.vocabulary,
            grammarPoints: [
                GrammarPoint(
                    title: "Question Formation",
                    explanation: content.grammarExplanation,
                    examples: content.grammarExamples,
                    commonMistakes: ["Wrong word order", "Forgetting question mark/intonation"]
                )
            ],
            dialogues: content.dialogues,
            practiceExercises: [
                PracticeExercise(
                    type: .speaking,
                    instruction: "Interview a partner using 10 different questions",
                    difficulty: .beginner,
                    estimatedTime: 10
                ),
                PracticeExercise(
                    type: .listening,
                    instruction: "Identify question type from audio",
                    difficulty: .beginner,
                    estimatedTime: 5
                ),
                PracticeExercise(
                    type: .game,
                    instruction: "20 Questions game in target language",
                    difficulty: .beginner,
                    estimatedTime: 5
                )
            ],
            srsKeyPhrases: content.srsKeyPhrases,
            culturalNotes: content.culturalNotes,
            fluencyTechniques: content.fluencyTechniques,
            conversationScenarios: content.scenarios,
            pronunciationTips: content.pronunciationTips,
            nextLessonSuggestion: "lesson-9"
        )
    }

    static func lesson9_FoodBasics(language: Language) -> DetailedLesson {
        let content = LanguageLessonContent.getContent(for: language, lessonNumber: 9)

        return DetailedLesson(
            id: "lesson-9",
            number: 9,
            title: content.title,
            subtitle: "Essential food vocabulary",
            language: language,
            level: .beginner,
            category: .food,
            duration: 20,
            objectives: [
                "Name 20+ common foods and drinks",
                "Express food preferences",
                "Use 'like' and 'want' correctly",
                "Discuss meals and eating habits",
                "Learn food-related cultural customs"
            ],
            vocabularyItems: content.vocabulary,
            grammarPoints: [
                GrammarPoint(
                    title: "Preference Verbs",
                    explanation: content.grammarExplanation,
                    examples: content.grammarExamples,
                    commonMistakes: ["Wrong verb for preference", "Missing articles with food"]
                )
            ],
            dialogues: content.dialogues,
            practiceExercises: [
                PracticeExercise(
                    type: .speaking,
                    instruction: "Describe your favorite meals and why",
                    difficulty: .beginner,
                    estimatedTime: 7
                ),
                PracticeExercise(
                    type: .vocabulary,
                    instruction: "Categorize 30 food items by meal type",
                    difficulty: .beginner,
                    estimatedTime: 5
                ),
                PracticeExercise(
                    type: .roleplay,
                    instruction: "Discuss dinner plans with friends",
                    difficulty: .beginner,
                    estimatedTime: 8
                )
            ],
            srsKeyPhrases: content.srsKeyPhrases,
            culturalNotes: content.culturalNotes,
            fluencyTechniques: content.fluencyTechniques,
            conversationScenarios: content.scenarios,
            pronunciationTips: content.pronunciationTips,
            nextLessonSuggestion: "lesson-10"
        )
    }

    static func lesson10_LocationsNearby(language: Language) -> DetailedLesson {
        let content = LanguageLessonContent.getContent(for: language, lessonNumber: 10)

        return DetailedLesson(
            id: "lesson-10",
            number: 10,
            title: content.title,
            subtitle: "Navigate your neighborhood",
            language: language,
            level: .beginner,
            category: .travel,
            duration: 20,
            objectives: [
                "Name common places (store, bank, school, etc.)",
                "Use location prepositions (next to, near, far)",
                "Give and understand simple directions",
                "Ask where places are located",
                "Describe your neighborhood"
            ],
            vocabularyItems: content.vocabulary,
            grammarPoints: [
                GrammarPoint(
                    title: "Prepositions of Place",
                    explanation: content.grammarExplanation,
                    examples: content.grammarExamples,
                    commonMistakes: ["Confusing 'in', 'on', 'at'", "Wrong preposition for location"]
                )
            ],
            dialogues: content.dialogues,
            practiceExercises: [
                PracticeExercise(
                    type: .speaking,
                    instruction: "Describe route from home to 3 different places",
                    difficulty: .beginner,
                    estimatedTime: 8
                ),
                PracticeExercise(
                    type: .listening,
                    instruction: "Follow audio directions on a map",
                    difficulty: .beginner,
                    estimatedTime: 7
                ),
                PracticeExercise(
                    type: .roleplay,
                    instruction: "Ask for and give directions to tourist",
                    difficulty: .beginner,
                    estimatedTime: 5
                )
            ],
            srsKeyPhrases: content.srsKeyPhrases,
            culturalNotes: content.culturalNotes,
            fluencyTechniques: content.fluencyTechniques,
            conversationScenarios: content.scenarios,
            pronunciationTips: content.pronunciationTips,
            nextLessonSuggestion: "lesson-11"
        )
    }

    // MARK: - ELEMENTARY LESSONS (11-20)

    static func lesson11_PresentTense(language: Language) -> DetailedLesson {
        let content = LanguageLessonContent.getContent(for: language, lessonNumber: 11)

        return DetailedLesson(
            id: "lesson-11",
            number: 11,
            title: content.title,
            subtitle: "Express current actions and habits",
            language: language,
            level: .elementary,
            category: .grammar,
            duration: 25,
            objectives: [
                "Conjugate regular verbs in present tense",
                "Use present tense for habits and routines",
                "Understand subject-verb agreement",
                "Express ongoing actions",
                "Distinguish present simple vs continuous"
            ],
            vocabularyItems: content.vocabulary,
            grammarPoints: [
                GrammarPoint(
                    title: "Present Tense Formation",
                    explanation: content.grammarExplanation,
                    examples: content.grammarExamples,
                    commonMistakes: ["Wrong verb ending", "Forgetting irregular verbs"]
                )
            ],
            dialogues: content.dialogues,
            practiceExercises: [
                PracticeExercise(
                    type: .grammar,
                    instruction: "Conjugate 10 verbs in all persons",
                    difficulty: .elementary,
                    estimatedTime: 10
                ),
                PracticeExercise(
                    type: .speaking,
                    instruction: "Describe your daily routine using present tense",
                    difficulty: .elementary,
                    estimatedTime: 8
                ),
                PracticeExercise(
                    type: .writing,
                    instruction: "Write paragraph about typical day",
                    difficulty: .elementary,
                    estimatedTime: 7
                )
            ],
            srsKeyPhrases: content.srsKeyPhrases,
            culturalNotes: content.culturalNotes,
            fluencyTechniques: content.fluencyTechniques,
            conversationScenarios: content.scenarios,
            pronunciationTips: content.pronunciationTips,
            nextLessonSuggestion: "lesson-12"
        )
    }

    static func lesson12_ShoppingBasics(language: Language) -> DetailedLesson {
        let content = LanguageLessonContent.getContent(for: language, lessonNumber: 12)

        return DetailedLesson(
            id: "lesson-12",
            number: 12,
            title: content.title,
            subtitle: "Shop like a local",
            language: language,
            level: .elementary,
            category: .shopping,
            duration: 20,
            objectives: [
                "Navigate stores and markets",
                "Ask about prices and sizes",
                "Negotiate and make purchases",
                "Use currency and numbers confidently",
                "Handle shopping problems (returns, exchanges)"
            ],
            vocabularyItems: content.vocabulary,
            grammarPoints: [
                GrammarPoint(
                    title: "Polite Requests and Questions",
                    explanation: content.grammarExplanation,
                    examples: content.grammarExamples,
                    commonMistakes: ["Being too direct", "Wrong word for 'how much'"]
                )
            ],
            dialogues: content.dialogues,
            practiceExercises: [
                PracticeExercise(
                    type: .roleplay,
                    instruction: "Complete shopping transaction from browsing to payment",
                    difficulty: .elementary,
                    estimatedTime: 10
                ),
                PracticeExercise(
                    type: .listening,
                    instruction: "Identify prices and items from shop dialogues",
                    difficulty: .elementary,
                    estimatedTime: 5
                ),
                PracticeExercise(
                    type: .speaking,
                    instruction: "Describe shopping experience and purchases",
                    difficulty: .elementary,
                    estimatedTime: 5
                )
            ],
            srsKeyPhrases: content.srsKeyPhrases,
            culturalNotes: content.culturalNotes,
            fluencyTechniques: content.fluencyTechniques,
            conversationScenarios: content.scenarios,
            pronunciationTips: content.pronunciationTips,
            nextLessonSuggestion: "lesson-13"
        )
    }

    static func lesson13_TransportationTravel(language: Language) -> DetailedLesson {
        let content = LanguageLessonContent.getContent(for: language, lessonNumber: 13)

        return DetailedLesson(
            id: "lesson-13",
            number: 13,
            title: content.title,
            subtitle: "Get around with ease",
            language: language,
            level: .elementary,
            category: .travel,
            duration: 25,
            objectives: [
                "Name modes of transportation",
                "Buy tickets and read schedules",
                "Ask about departure and arrival times",
                "Navigate airports and train stations",
                "Handle travel problems and delays"
            ],
            vocabularyItems: content.vocabulary,
            grammarPoints: [
                GrammarPoint(
                    title: "Movement Verbs and Prepositions",
                    explanation: content.grammarExplanation,
                    examples: content.grammarExamples,
                    commonMistakes: ["Wrong preposition with transportation", "Confusing 'go' vs 'take'"]
                )
            ],
            dialogues: content.dialogues,
            practiceExercises: [
                PracticeExercise(
                    type: .roleplay,
                    instruction: "Buy train ticket and ask about connections",
                    difficulty: .elementary,
                    estimatedTime: 8
                ),
                PracticeExercise(
                    type: .listening,
                    instruction: "Listen to announcements and identify platform/gate",
                    difficulty: .elementary,
                    estimatedTime: 7
                ),
                PracticeExercise(
                    type: .speaking,
                    instruction: "Explain your commute or travel plans",
                    difficulty: .elementary,
                    estimatedTime: 10
                )
            ],
            srsKeyPhrases: content.srsKeyPhrases,
            culturalNotes: content.culturalNotes,
            fluencyTechniques: content.fluencyTechniques,
            conversationScenarios: content.scenarios,
            pronunciationTips: content.pronunciationTips,
            nextLessonSuggestion: "lesson-14"
        )
    }

    static func lesson14_TimeAndSchedule(language: Language) -> DetailedLesson {
        let content = LanguageLessonContent.getContent(for: language, lessonNumber: 14)

        return DetailedLesson(
            id: "lesson-14",
            number: 14,
            title: content.title,
            subtitle: "Master telling time",
            language: language,
            level: .elementary,
            category: .time,
            duration: 20,
            objectives: [
                "Tell time accurately (hours, minutes)",
                "Use 12 and 24-hour formats",
                "Discuss schedules and appointments",
                "Express duration (for 2 hours, since Monday)",
                "Talk about being late/early/on time"
            ],
            vocabularyItems: content.vocabulary,
            grammarPoints: [
                GrammarPoint(
                    title: "Time Expressions and Prepositions",
                    explanation: content.grammarExplanation,
                    examples: content.grammarExamples,
                    commonMistakes: ["AM/PM confusion", "Wrong preposition with time"]
                )
            ],
            dialogues: content.dialogues,
            practiceExercises: [
                PracticeExercise(
                    type: .speaking,
                    instruction: "Tell the time at 10 random clock images",
                    difficulty: .elementary,
                    estimatedTime: 5
                ),
                PracticeExercise(
                    type: .listening,
                    instruction: "Draw clock hands based on spoken times",
                    difficulty: .elementary,
                    estimatedTime: 5
                ),
                PracticeExercise(
                    type: .roleplay,
                    instruction: "Schedule appointment and discuss timing",
                    difficulty: .elementary,
                    estimatedTime: 10
                )
            ],
            srsKeyPhrases: content.srsKeyPhrases,
            culturalNotes: content.culturalNotes,
            fluencyTechniques: content.fluencyTechniques,
            conversationScenarios: content.scenarios,
            pronunciationTips: content.pronunciationTips,
            nextLessonSuggestion: "lesson-15"
        )
    }

    static func lesson15_BodyAndHealth(language: Language) -> DetailedLesson {
        let content = LanguageLessonContent.getContent(for: language, lessonNumber: 15)

        return DetailedLesson(
            id: "lesson-15",
            number: 15,
            title: content.title,
            subtitle: "Describe symptoms and wellness",
            language: language,
            level: .elementary,
            category: .health,
            duration: 25,
            objectives: [
                "Name body parts and organs",
                "Describe symptoms and pain",
                "Make doctor appointments",
                "Understand medical advice",
                "Discuss health habits and wellness"
            ],
            vocabularyItems: content.vocabulary,
            grammarPoints: [
                GrammarPoint(
                    title: "Expressing Pain and Symptoms",
                    explanation: content.grammarExplanation,
                    examples: content.grammarExamples,
                    commonMistakes: ["Wrong verb for 'hurt'", "Confusing 'ache' and 'pain'"]
                )
            ],
            dialogues: content.dialogues,
            practiceExercises: [
                PracticeExercise(
                    type: .vocabulary,
                    instruction: "Label body diagram with 20+ parts",
                    difficulty: .elementary,
                    estimatedTime: 7
                ),
                PracticeExercise(
                    type: .roleplay,
                    instruction: "Doctor visit - describe symptoms",
                    difficulty: .elementary,
                    estimatedTime: 10
                ),
                PracticeExercise(
                    type: .listening,
                    instruction: "Listen to symptoms and identify illness",
                    difficulty: .elementary,
                    estimatedTime: 8
                )
            ],
            srsKeyPhrases: content.srsKeyPhrases,
            culturalNotes: content.culturalNotes,
            fluencyTechniques: content.fluencyTechniques,
            conversationScenarios: content.scenarios,
            pronunciationTips: content.pronunciationTips,
            nextLessonSuggestion: "lesson-16"
        )
    }

    static func lesson16_HobbiesInterests(language: Language) -> DetailedLesson {
        let content = LanguageLessonContent.getContent(for: language, lessonNumber: 16)

        return DetailedLesson(
            id: "lesson-16",
            number: 16,
            title: content.title,
            subtitle: "Share your passions",
            language: language,
            level: .elementary,
            category: .conversation,
            duration: 20,
            objectives: [
                "Discuss hobbies and free time activities",
                "Express preferences and interests",
                "Use frequency adverbs (always, sometimes, never)",
                "Invite others to join activities",
                "Talk about sports and arts"
            ],
            vocabularyItems: content.vocabulary,
            grammarPoints: [
                GrammarPoint(
                    title: "Frequency Adverbs and Preferences",
                    explanation: content.grammarExplanation,
                    examples: content.grammarExamples,
                    commonMistakes: ["Wrong adverb position", "Confusing 'like' and 'like to'"]
                )
            ],
            dialogues: content.dialogues,
            practiceExercises: [
                PracticeExercise(
                    type: .speaking,
                    instruction: "Describe 3 hobbies in detail",
                    difficulty: .elementary,
                    estimatedTime: 8
                ),
                PracticeExercise(
                    type: .roleplay,
                    instruction: "Invite friend to activity and negotiate plans",
                    difficulty: .elementary,
                    estimatedTime: 7
                ),
                PracticeExercise(
                    type: .writing,
                    instruction: "Write about ideal weekend activities",
                    difficulty: .elementary,
                    estimatedTime: 5
                )
            ],
            srsKeyPhrases: content.srsKeyPhrases,
            culturalNotes: content.culturalNotes,
            fluencyTechniques: content.fluencyTechniques,
            conversationScenarios: content.scenarios,
            pronunciationTips: content.pronunciationTips,
            nextLessonSuggestion: "lesson-17"
        )
    }

    static func lesson17_RestaurantDining(language: Language) -> DetailedLesson {
        let content = LanguageLessonContent.getContent(for: language, lessonNumber: 17)

        return DetailedLesson(
            id: "lesson-17",
            number: 17,
            title: content.title,
            subtitle: "Dine with confidence",
            language: language,
            level: .elementary,
            category: .food,
            duration: 25,
            objectives: [
                "Order complete meals at restaurants",
                "Ask about menu items and ingredients",
                "Make special requests and modifications",
                "Handle complaints politely",
                "Understand menu vocabulary"
            ],
            vocabularyItems: content.vocabulary,
            grammarPoints: [
                GrammarPoint(
                    title: "Polite Requests and Conditionals",
                    explanation: content.grammarExplanation,
                    examples: content.grammarExamples,
                    commonMistakes: ["Too direct ordering", "Confusing 'I want' vs 'I would like'"]
                )
            ],
            dialogues: content.dialogues,
            practiceExercises: [
                PracticeExercise(
                    type: .roleplay,
                    instruction: "Complete dining experience from seating to payment",
                    difficulty: .elementary,
                    estimatedTime: 12
                ),
                PracticeExercise(
                    type: .vocabulary,
                    instruction: "Read and understand authentic menu",
                    difficulty: .elementary,
                    estimatedTime: 5
                ),
                PracticeExercise(
                    type: .listening,
                    instruction: "Take order as waiter/waitress",
                    difficulty: .elementary,
                    estimatedTime: 8
                )
            ],
            srsKeyPhrases: content.srsKeyPhrases,
            culturalNotes: content.culturalNotes,
            fluencyTechniques: content.fluencyTechniques,
            conversationScenarios: content.scenarios,
            pronunciationTips: content.pronunciationTips,
            nextLessonSuggestion: "lesson-18"
        )
    }

    static func lesson18_PastTense(language: Language) -> DetailedLesson {
        let content = LanguageLessonContent.getContent(for: language, lessonNumber: 18)

        return DetailedLesson(
            id: "lesson-18",
            number: 18,
            title: content.title,
            subtitle: "Talk about past events",
            language: language,
            level: .elementary,
            category: .grammar,
            duration: 30,
            objectives: [
                "Form past tense of regular verbs",
                "Use common irregular past forms",
                "Narrate past events in sequence",
                "Use time markers (yesterday, last week, ago)",
                "Distinguish completed vs ongoing past actions"
            ],
            vocabularyItems: content.vocabulary,
            grammarPoints: [
                GrammarPoint(
                    title: "Past Tense Formation",
                    explanation: content.grammarExplanation,
                    examples: content.grammarExamples,
                    commonMistakes: ["Wrong irregular form", "Forgetting to change verb"]
                )
            ],
            dialogues: content.dialogues,
            practiceExercises: [
                PracticeExercise(
                    type: .grammar,
                    instruction: "Convert 20 present sentences to past",
                    difficulty: .elementary,
                    estimatedTime: 10
                ),
                PracticeExercise(
                    type: .speaking,
                    instruction: "Tell story about your last vacation",
                    difficulty: .elementary,
                    estimatedTime: 10
                ),
                PracticeExercise(
                    type: .writing,
                    instruction: "Write diary entry about yesterday",
                    difficulty: .elementary,
                    estimatedTime: 10
                )
            ],
            srsKeyPhrases: content.srsKeyPhrases,
            culturalNotes: content.culturalNotes,
            fluencyTechniques: content.fluencyTechniques,
            conversationScenarios: content.scenarios,
            pronunciationTips: content.pronunciationTips,
            nextLessonSuggestion: "lesson-19"
        )
    }

    static func lesson19_EmotionsFeelings(language: Language) -> DetailedLesson {
        let content = LanguageLessonContent.getContent(for: language, lessonNumber: 19)

        return DetailedLesson(
            id: "lesson-19",
            number: 19,
            title: content.title,
            subtitle: "Express how you feel",
            language: language,
            level: .elementary,
            category: .conversation,
            duration: 20,
            objectives: [
                "Name 20+ emotions and feelings",
                "Express emotional states accurately",
                "Ask about others' feelings",
                "Give emotional support",
                "Use emotion adjectives vs verbs correctly"
            ],
            vocabularyItems: content.vocabulary,
            grammarPoints: [
                GrammarPoint(
                    title: "Emotion Verbs and Adjectives",
                    explanation: content.grammarExplanation,
                    examples: content.grammarExamples,
                    commonMistakes: ["'I am boring' vs 'I am bored'", "Wrong preposition after emotion"]
                )
            ],
            dialogues: content.dialogues,
            practiceExercises: [
                PracticeExercise(
                    type: .speaking,
                    instruction: "Describe emotional reaction to 5 scenarios",
                    difficulty: .elementary,
                    estimatedTime: 8
                ),
                PracticeExercise(
                    type: .listening,
                    instruction: "Identify emotions from tone and context",
                    difficulty: .elementary,
                    estimatedTime: 5
                ),
                PracticeExercise(
                    type: .roleplay,
                    instruction: "Comfort friend who is upset",
                    difficulty: .elementary,
                    estimatedTime: 7
                )
            ],
            srsKeyPhrases: content.srsKeyPhrases,
            culturalNotes: content.culturalNotes,
            fluencyTechniques: content.fluencyTechniques,
            conversationScenarios: content.scenarios,
            pronunciationTips: content.pronunciationTips,
            nextLessonSuggestion: "lesson-20"
        )
    }

    static func lesson20_DirectionsNavigation(language: Language) -> DetailedLesson {
        let content = LanguageLessonContent.getContent(for: language, lessonNumber: 20)

        return DetailedLesson(
            id: "lesson-20",
            number: 20,
            title: content.title,
            subtitle: "Never get lost again",
            language: language,
            level: .elementary,
            category: .travel,
            duration: 25,
            objectives: [
                "Give detailed step-by-step directions",
                "Understand complex navigation instructions",
                "Use directional vocabulary (turn left, go straight)",
                "Describe landmarks and distances",
                "Handle being lost and asking for help"
            ],
            vocabularyItems: content.vocabulary,
            grammarPoints: [
                GrammarPoint(
                    title: "Imperative Mood and Directions",
                    explanation: content.grammarExplanation,
                    examples: content.grammarExamples,
                    commonMistakes: ["Wrong imperative form", "Unclear reference points"]
                )
            ],
            dialogues: content.dialogues,
            practiceExercises: [
                PracticeExercise(
                    type: .speaking,
                    instruction: "Give directions to 3 places from current location",
                    difficulty: .elementary,
                    estimatedTime: 10
                ),
                PracticeExercise(
                    type: .listening,
                    instruction: "Follow verbal directions on map to reach destination",
                    difficulty: .elementary,
                    estimatedTime: 8
                ),
                PracticeExercise(
                    type: .roleplay,
                    instruction: "Lost tourist asks for directions",
                    difficulty: .elementary,
                    estimatedTime: 7
                )
            ],
            srsKeyPhrases: content.srsKeyPhrases,
            culturalNotes: content.culturalNotes,
            fluencyTechniques: content.fluencyTechniques,
            conversationScenarios: content.scenarios,
            pronunciationTips: content.pronunciationTips,
            nextLessonSuggestion: "lesson-21"
        )
    }

    // MARK: - INTERMEDIATE LESSONS (21-25)

    static func lesson21_FuturePlans(language: Language) -> DetailedLesson {
        let content = LanguageLessonContent.getContent(for: language, lessonNumber: 21)

        return DetailedLesson(
            id: "lesson-21",
            number: 21,
            title: content.title,
            subtitle: "Discuss intentions and predictions",
            language: language,
            level: .intermediate,
            category: .grammar,
            duration: 30,
            objectives: [
                "Use future tense correctly",
                "Express intentions and plans",
                "Make predictions and forecasts",
                "Distinguish near vs distant future",
                "Use 'going to' vs 'will' appropriately"
            ],
            vocabularyItems: content.vocabulary,
            grammarPoints: [
                GrammarPoint(
                    title: "Future Tense Forms",
                    explanation: content.grammarExplanation,
                    examples: content.grammarExamples,
                    commonMistakes: ["Using present for future", "Confusing different future forms"]
                )
            ],
            dialogues: content.dialogues,
            practiceExercises: [
                PracticeExercise(
                    type: .speaking,
                    instruction: "Describe your plans for next 5 years",
                    difficulty: .intermediate,
                    estimatedTime: 10
                ),
                PracticeExercise(
                    type: .writing,
                    instruction: "Write about goals and dreams",
                    difficulty: .intermediate,
                    estimatedTime: 12
                ),
                PracticeExercise(
                    type: .grammar,
                    instruction: "Choose correct future form in 20 sentences",
                    difficulty: .intermediate,
                    estimatedTime: 8
                )
            ],
            srsKeyPhrases: content.srsKeyPhrases,
            culturalNotes: content.culturalNotes,
            fluencyTechniques: content.fluencyTechniques,
            conversationScenarios: content.scenarios,
            pronunciationTips: content.pronunciationTips,
            nextLessonSuggestion: "lesson-22"
        )
    }

    static func lesson22_WorkCareer(language: Language) -> DetailedLesson {
        let content = LanguageLessonContent.getContent(for: language, lessonNumber: 22)

        return DetailedLesson(
            id: "lesson-22",
            number: 22,
            title: content.title,
            subtitle: "Professional vocabulary and scenarios",
            language: language,
            level: .intermediate,
            category: .work,
            duration: 30,
            objectives: [
                "Discuss job roles and responsibilities",
                "Conduct job interviews",
                "Write professional emails",
                "Participate in business meetings",
                "Network and make professional introductions"
            ],
            vocabularyItems: content.vocabulary,
            grammarPoints: [
                GrammarPoint(
                    title: "Formal Register and Professional Language",
                    explanation: content.grammarExplanation,
                    examples: content.grammarExamples,
                    commonMistakes: ["Too informal in business", "Mixing registers"]
                )
            ],
            dialogues: content.dialogues,
            practiceExercises: [
                PracticeExercise(
                    type: .roleplay,
                    instruction: "Job interview - answer questions professionally",
                    difficulty: .intermediate,
                    estimatedTime: 15
                ),
                PracticeExercise(
                    type: .writing,
                    instruction: "Write professional email and cover letter",
                    difficulty: .intermediate,
                    estimatedTime: 10
                ),
                PracticeExercise(
                    type: .speaking,
                    instruction: "Describe career path and goals",
                    difficulty: .intermediate,
                    estimatedTime: 5
                )
            ],
            srsKeyPhrases: content.srsKeyPhrases,
            culturalNotes: content.culturalNotes,
            fluencyTechniques: content.fluencyTechniques,
            conversationScenarios: content.scenarios,
            pronunciationTips: content.pronunciationTips,
            nextLessonSuggestion: "lesson-23"
        )
    }

    static func lesson23_TechnologyMedia(language: Language) -> DetailedLesson {
        let content = LanguageLessonContent.getContent(for: language, lessonNumber: 23)

        return DetailedLesson(
            id: "lesson-23",
            number: 23,
            title: content.title,
            subtitle: "Modern digital vocabulary",
            language: language,
            level: .intermediate,
            category: .conversation,
            duration: 25,
            objectives: [
                "Discuss technology and digital tools",
                "Explain technical problems",
                "Talk about social media",
                "Describe online activities",
                "Use tech vocabulary appropriately"
            ],
            vocabularyItems: content.vocabulary,
            grammarPoints: [
                GrammarPoint(
                    title: "Technical Vocabulary and Phrasal Verbs",
                    explanation: content.grammarExplanation,
                    examples: content.grammarExamples,
                    commonMistakes: ["Direct translation of tech terms", "Outdated vocabulary"]
                )
            ],
            dialogues: content.dialogues,
            practiceExercises: [
                PracticeExercise(
                    type: .speaking,
                    instruction: "Explain how to use an app or website",
                    difficulty: .intermediate,
                    estimatedTime: 8
                ),
                PracticeExercise(
                    type: .roleplay,
                    instruction: "Tech support call - describe problem",
                    difficulty: .intermediate,
                    estimatedTime: 10
                ),
                PracticeExercise(
                    type: .vocabulary,
                    instruction: "Match tech terms with definitions",
                    difficulty: .intermediate,
                    estimatedTime: 7
                )
            ],
            srsKeyPhrases: content.srsKeyPhrases,
            culturalNotes: content.culturalNotes,
            fluencyTechniques: content.fluencyTechniques,
            conversationScenarios: content.scenarios,
            pronunciationTips: content.pronunciationTips,
            nextLessonSuggestion: "lesson-24"
        )
    }

    static func lesson24_OpinionsDebate(language: Language) -> DetailedLesson {
        let content = LanguageLessonContent.getContent(for: language, lessonNumber: 24)

        return DetailedLesson(
            id: "lesson-24",
            number: 24,
            title: content.title,
            subtitle: "Express viewpoints persuasively",
            language: language,
            level: .intermediate,
            category: .conversation,
            duration: 30,
            objectives: [
                "State opinions clearly and support them",
                "Agree and disagree politely",
                "Use persuasive language",
                "Present arguments logically",
                "Engage in respectful debate"
            ],
            vocabularyItems: content.vocabulary,
            grammarPoints: [
                GrammarPoint(
                    title: "Opinion Expressions and Connectors",
                    explanation: content.grammarExplanation,
                    examples: content.grammarExamples,
                    commonMistakes: ["Too aggressive disagreement", "Weak argument structure"]
                )
            ],
            dialogues: content.dialogues,
            practiceExercises: [
                PracticeExercise(
                    type: .speaking,
                    instruction: "Debate a topic with partner, each taking opposite side",
                    difficulty: .intermediate,
                    estimatedTime: 15
                ),
                PracticeExercise(
                    type: .writing,
                    instruction: "Write opinion essay on current topic",
                    difficulty: .intermediate,
                    estimatedTime: 10
                ),
                PracticeExercise(
                    type: .listening,
                    instruction: "Identify arguments and counterarguments",
                    difficulty: .intermediate,
                    estimatedTime: 5
                )
            ],
            srsKeyPhrases: content.srsKeyPhrases,
            culturalNotes: content.culturalNotes,
            fluencyTechniques: content.fluencyTechniques,
            conversationScenarios: content.scenarios,
            pronunciationTips: content.pronunciationTips,
            nextLessonSuggestion: "lesson-25"
        )
    }

    static func lesson25_ConditionalTense(language: Language) -> DetailedLesson {
        let content = LanguageLessonContent.getContent(for: language, lessonNumber: 25)

        return DetailedLesson(
            id: "lesson-25",
            number: 25,
            title: content.title,
            subtitle: "Express hypothetical situations",
            language: language,
            level: .intermediate,
            category: .grammar,
            duration: 30,
            objectives: [
                "Use first conditional (real possibility)",
                "Form second conditional (hypothetical)",
                "Understand third conditional (past unreal)",
                "Make polite requests with conditionals",
                "Express regrets and wishes"
            ],
            vocabularyItems: content.vocabulary,
            grammarPoints: [
                GrammarPoint(
                    title: "Conditional Structures",
                    explanation: content.grammarExplanation,
                    examples: content.grammarExamples,
                    commonMistakes: ["Mixing conditional types", "Wrong tense in if-clause"]
                )
            ],
            dialogues: content.dialogues,
            practiceExercises: [
                PracticeExercise(
                    type: .grammar,
                    instruction: "Complete 30 conditional sentences",
                    difficulty: .intermediate,
                    estimatedTime: 12
                ),
                PracticeExercise(
                    type: .speaking,
                    instruction: "Describe 'what if' scenarios",
                    difficulty: .intermediate,
                    estimatedTime: 10
                ),
                PracticeExercise(
                    type: .writing,
                    instruction: "Write about regrets using third conditional",
                    difficulty: .intermediate,
                    estimatedTime: 8
                )
            ],
            srsKeyPhrases: content.srsKeyPhrases,
            culturalNotes: content.culturalNotes,
            fluencyTechniques: content.fluencyTechniques,
            conversationScenarios: content.scenarios,
            pronunciationTips: content.pronunciationTips,
            nextLessonSuggestion: "lesson-26"
        )
    }

    // MARK: - ADVANCED LESSONS (26-30)

    static func lesson26_IdiomsExpressions(language: Language) -> DetailedLesson {
        let content = LanguageLessonContent.getContent(for: language, lessonNumber: 26)

        return DetailedLesson(
            id: "lesson-26",
            number: 26,
            title: content.title,
            subtitle: "Sound like a native speaker",
            language: language,
            level: .advanced,
            category: .culture,
            duration: 30,
            objectives: [
                "Understand common idioms and their origins",
                "Use colloquial expressions naturally",
                "Recognize and interpret figurative language",
                "Avoid literal translation mistakes",
                "Know when idioms are appropriate"
            ],
            vocabularyItems: content.vocabulary,
            grammarPoints: [
                GrammarPoint(
                    title: "Idiomatic Language Patterns",
                    explanation: content.grammarExplanation,
                    examples: content.grammarExamples,
                    commonMistakes: ["Using idioms too formally", "Mixing up similar idioms"]
                )
            ],
            dialogues: content.dialogues,
            practiceExercises: [
                PracticeExercise(
                    type: .vocabulary,
                    instruction: "Match 20 idioms to meanings",
                    difficulty: .advanced,
                    estimatedTime: 10
                ),
                PracticeExercise(
                    type: .speaking,
                    instruction: "Tell story using 5+ idioms naturally",
                    difficulty: .advanced,
                    estimatedTime: 12
                ),
                PracticeExercise(
                    type: .listening,
                    instruction: "Identify idioms in authentic conversations",
                    difficulty: .advanced,
                    estimatedTime: 8
                )
            ],
            srsKeyPhrases: content.srsKeyPhrases,
            culturalNotes: content.culturalNotes,
            fluencyTechniques: content.fluencyTechniques,
            conversationScenarios: content.scenarios,
            pronunciationTips: content.pronunciationTips,
            nextLessonSuggestion: "lesson-27"
        )
    }

    static func lesson27_CulturalTraditions(language: Language) -> DetailedLesson {
        let content = LanguageLessonContent.getContent(for: language, lessonNumber: 27)

        return DetailedLesson(
            id: "lesson-27",
            number: 27,
            title: content.title,
            subtitle: "Deep cultural understanding",
            language: language,
            level: .advanced,
            category: .culture,
            duration: 35,
            objectives: [
                "Discuss holidays and celebrations",
                "Understand cultural values and norms",
                "Navigate social etiquette",
                "Compare and contrast cultures",
                "Avoid cultural misunderstandings"
            ],
            vocabularyItems: content.vocabulary,
            grammarPoints: [
                GrammarPoint(
                    title: "Cultural Context in Language",
                    explanation: content.grammarExplanation,
                    examples: content.grammarExamples,
                    commonMistakes: ["Cultural assumptions", "Inappropriate topics"]
                )
            ],
            dialogues: content.dialogues,
            practiceExercises: [
                PracticeExercise(
                    type: .speaking,
                    instruction: "Present on cultural tradition (5 minutes)",
                    difficulty: .advanced,
                    estimatedTime: 15
                ),
                PracticeExercise(
                    type: .writing,
                    instruction: "Compare cultural practices essay",
                    difficulty: .advanced,
                    estimatedTime: 12
                ),
                PracticeExercise(
                    type: .discussion,
                    instruction: "Group discussion on cultural differences",
                    difficulty: .advanced,
                    estimatedTime: 8
                )
            ],
            srsKeyPhrases: content.srsKeyPhrases,
            culturalNotes: content.culturalNotes,
            fluencyTechniques: content.fluencyTechniques,
            conversationScenarios: content.scenarios,
            pronunciationTips: content.pronunciationTips,
            nextLessonSuggestion: "lesson-28"
        )
    }

    static func lesson28_ComplexNarrative(language: Language) -> DetailedLesson {
        let content = LanguageLessonContent.getContent(for: language, lessonNumber: 28)

        return DetailedLesson(
            id: "lesson-28",
            number: 28,
            title: content.title,
            subtitle: "Master storytelling",
            language: language,
            level: .advanced,
            category: .conversation,
            duration: 35,
            objectives: [
                "Tell extended stories with detail",
                "Use narrative tenses effectively",
                "Build suspense and engagement",
                "Incorporate direct and indirect speech",
                "Create coherent long-form narratives"
            ],
            vocabularyItems: content.vocabulary,
            grammarPoints: [
                GrammarPoint(
                    title: "Narrative Tense Combinations",
                    explanation: content.grammarExplanation,
                    examples: content.grammarExamples,
                    commonMistakes: ["Tense inconsistency", "Unclear time references"]
                )
            ],
            dialogues: content.dialogues,
            practiceExercises: [
                PracticeExercise(
                    type: .speaking,
                    instruction: "Tell 10-minute personal story with drama",
                    difficulty: .advanced,
                    estimatedTime: 20
                ),
                PracticeExercise(
                    type: .writing,
                    instruction: "Write 500-word narrative story",
                    difficulty: .advanced,
                    estimatedTime: 15
                ),
                PracticeExercise(
                    type: .listening,
                    instruction: "Summarize complex story you hear",
                    difficulty: .advanced,
                    estimatedTime: 10
                )
            ],
            srsKeyPhrases: content.srsKeyPhrases,
            culturalNotes: content.culturalNotes,
            fluencyTechniques: content.fluencyTechniques,
            conversationScenarios: content.scenarios,
            pronunciationTips: content.pronunciationTips,
            nextLessonSuggestion: "lesson-29"
        )
    }

    static func lesson29_FormalBusiness(language: Language) -> DetailedLesson {
        let content = LanguageLessonContent.getContent(for: language, lessonNumber: 29)

        return DetailedLesson(
            id: "lesson-29",
            number: 29,
            title: content.title,
            subtitle: "Professional mastery",
            language: language,
            level: .advanced,
            category: .work,
            duration: 35,
            objectives: [
                "Lead business meetings confidently",
                "Negotiate deals and contracts",
                "Give professional presentations",
                "Write formal reports and proposals",
                "Handle difficult conversations diplomatically"
            ],
            vocabularyItems: content.vocabulary,
            grammarPoints: [
                GrammarPoint(
                    title: "Formal Written and Spoken Register",
                    explanation: content.grammarExplanation,
                    examples: content.grammarExamples,
                    commonMistakes: ["Too casual for context", "Overly complex language"]
                )
            ],
            dialogues: content.dialogues,
            practiceExercises: [
                PracticeExercise(
                    type: .speaking,
                    instruction: "Deliver 5-minute business presentation",
                    difficulty: .advanced,
                    estimatedTime: 15
                ),
                PracticeExercise(
                    type: .roleplay,
                    instruction: "Negotiate business deal",
                    difficulty: .advanced,
                    estimatedTime: 12
                ),
                PracticeExercise(
                    type: .writing,
                    instruction: "Write formal business proposal",
                    difficulty: .advanced,
                    estimatedTime: 8
                )
            ],
            srsKeyPhrases: content.srsKeyPhrases,
            culturalNotes: content.culturalNotes,
            fluencyTechniques: content.fluencyTechniques,
            conversationScenarios: content.scenarios,
            pronunciationTips: content.pronunciationTips,
            nextLessonSuggestion: "lesson-30"
        )
    }

    static func lesson30_SubjectiveMood(language: Language) -> DetailedLesson {
        let content = LanguageLessonContent.getContent(for: language, lessonNumber: 30)

        return DetailedLesson(
            id: "lesson-30",
            number: 30,
            title: content.title,
            subtitle: "Master advanced grammar",
            language: language,
            level: .advanced,
            category: .grammar,
            duration: 40,
            objectives: [
                "Understand subjunctive mood usage",
                "Express doubt, desire, emotion with subjunctive",
                "Use subjunctive in dependent clauses",
                "Distinguish indicative vs subjunctive",
                "Apply advanced grammatical structures"
            ],
            vocabularyItems: content.vocabulary,
            grammarPoints: [
                GrammarPoint(
                    title: "Subjunctive Mood",
                    explanation: content.grammarExplanation,
                    examples: content.grammarExamples,
                    commonMistakes: ["Using indicative instead", "Wrong subjunctive trigger"]
                )
            ],
            dialogues: content.dialogues,
            practiceExercises: [
                PracticeExercise(
                    type: .grammar,
                    instruction: "Complete 40 subjunctive sentences",
                    difficulty: .advanced,
                    estimatedTime: 15
                ),
                PracticeExercise(
                    type: .speaking,
                    instruction: "Express wishes, doubts, and emotions",
                    difficulty: .advanced,
                    estimatedTime: 15
                ),
                PracticeExercise(
                    type: .writing,
                    instruction: "Write complex text using subjunctive",
                    difficulty: .advanced,
                    estimatedTime: 10
                )
            ],
            srsKeyPhrases: content.srsKeyPhrases,
            culturalNotes: content.culturalNotes,
            fluencyTechniques: content.fluencyTechniques,
            conversationScenarios: content.scenarios,
            pronunciationTips: content.pronunciationTips,
            nextLessonSuggestion: nil
        )
    }
}

// MARK: - Supporting Types

struct DetailedLesson: Identifiable, Codable {
    let id: String
    let number: Int
    let title: String
    let subtitle: String
    let language: Language
    let level: ProficiencyLevel
    let category: LessonCategory
    let duration: Int
    let objectives: [String]
    let vocabularyItems: [VocabularyItem]
    let grammarPoints: [GrammarPoint]
    let dialogues: [DialogueLine]
    let practiceExercises: [PracticeExercise]
    let srsKeyPhrases: [SRSPhrase]
    let culturalNotes: [String]
    let fluencyTechniques: [String]
    let conversationScenarios: [ConversationScenario]
    let pronunciationTips: [String]
    let nextLessonSuggestion: String?
}

struct SRSPhrase: Codable {
    let phrase: String
    let translation: String
    let context: String
    let difficulty: Int // 1-5
}

struct PracticeExercise: Codable {
    let type: ExerciseType
    let instruction: String
    let difficulty: ProficiencyLevel
    let estimatedTime: Int // minutes

    enum ExerciseType: String, Codable {
        case speaking
        case listening
        case writing
        case reading
        case grammar
        case vocabulary
        case pronunciation
        case roleplay
        case game
        case discussion
    }
}

struct GrammarPoint: Codable {
    let title: String
    let explanation: String
    let examples: [String]
    let commonMistakes: [String]
}

struct DialogueLine: Codable {
    let speaker: String
    let text: String
    let translation: String
}

// ConversationScenario moved to Models/ConversationScenario.swift
