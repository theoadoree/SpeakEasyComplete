import SwiftUI
import Combine

struct FluencyChallengesView: View {
    @State private var selectedChallenge: ChallengeType?
    @State private var showResults = false
    @State private var challengeResults: ChallengeResults?
    @StateObject private var gameEngine = FluencyGameEngine()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Daily Challenge Header
                    DailyChallengeCard()
                        .padding(.horizontal)

                    // Challenge Categories
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Fluency Games")
                            .font(.system(size: 24, weight: .bold))
                            .padding(.horizontal)

                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(ChallengeType.allCases, id: \.self) { challenge in
                                ChallengeCard(
                                    challenge: challenge,
                                    isLocked: !challenge.isUnlocked,
                                    action: {
                                        selectedChallenge = challenge
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Leaderboard Section
                    LeaderboardSection()
                        .padding(.horizontal)
                        .padding(.top, 10)
                }
                .padding(.vertical, 20)
            }
            .background(Color(hex: "F2F2F7"))
            .navigationTitle("Challenges")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedChallenge) { challenge in
                ChallengeGameView(
                    challengeType: challenge,
                    gameEngine: gameEngine,
                    onComplete: { results in
                        challengeResults = results
                        showResults = true
                    }
                )
            }
            .sheet(isPresented: $showResults) {
                if let results = challengeResults {
                    ChallengeResultsView(results: results) {
                        showResults = false
                        challengeResults = nil
                    }
                }
            }
        }
    }
}

// MARK: - Daily Challenge Card
struct DailyChallengeCard: View {
    @State private var timeRemaining = "23:45:12"

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(Color(hex: "FF9500"))
                        Text("Daily Challenge")
                            .font(.system(size: 20, weight: .bold))
                    }

                    Text("Speed Speaking Marathon")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)

                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 12))
                        Text(timeRemaining)
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(Color(hex: "007AFF"))
                }

                Spacer()

                // Reward Badge
                VStack {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 30))
                        .foregroundColor(Color(hex: "FFD700"))
                    Text("500 XP")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(hex: "FF9500"))
                }
                .padding()
                .background(
                    Circle()
                        .fill(Color(hex: "FFF9E6"))
                )
            }

            Button(action: {}) {
                Text("Start Challenge")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "FF9500"), Color(hex: "FF6200")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color(hex: "FF9500").opacity(0.2), radius: 10, y: 5)
        )
    }
}

// MARK: - Challenge Card
struct ChallengeCard: View {
    let challenge: ChallengeType
    let isLocked: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isLocked ? Color.gray.opacity(0.2) : challenge.color.opacity(0.2))
                        .frame(width: 60, height: 60)

                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                    } else {
                        Image(systemName: challenge.icon)
                            .font(.system(size: 28))
                            .foregroundColor(challenge.color)
                    }
                }

                // Title
                Text(challenge.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isLocked ? .gray : .black)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                // Difficulty
                HStack(spacing: 2) {
                    ForEach(0..<3) { index in
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(
                                index < challenge.difficulty ?
                                Color(hex: "FFD700") : Color.gray.opacity(0.3)
                            )
                    }
                }

                // Best Score
                if !isLocked {
                    Text("Best: \(challenge.bestScore)")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                } else {
                    Text("Unlock at Lv.\(challenge.requiredLevel)")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
            )
        }
        .disabled(isLocked)
    }
}

// MARK: - Challenge Game View
struct ChallengeGameView: View {
    let challengeType: ChallengeType
    @ObservedObject var gameEngine: FluencyGameEngine
    let onComplete: (ChallengeResults) -> Void

    @State private var currentRound = 1
    @State private var score = 0
    @State private var timeRemaining = 60.0
    @State private var isPlaying = false
    @State private var gameTimer: Timer?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [challengeType.color.opacity(0.1), Color.white],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 24) {
                    // Game Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Round \(currentRound)")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            Text("Score: \(score)")
                                .font(.system(size: 24, weight: .bold))
                        }

                        Spacer()

                        // Timer
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                                .frame(width: 60, height: 60)

                            Circle()
                                .trim(from: 0, to: CGFloat(timeRemaining / 60))
                                .stroke(challengeType.color, lineWidth: 4)
                                .frame(width: 60, height: 60)
                                .rotationEffect(Angle(degrees: -90))
                                .animation(.linear(duration: 0.5), value: timeRemaining)

                            Text("\(Int(timeRemaining))")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(challengeType.color)
                        }
                    }
                    .padding(.horizontal)

                    // Game Content
                    gameContent
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    // Controls
                    if !isPlaying {
                        Button(action: startGame) {
                            Text("Start Game")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(challengeType.color)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle(challengeType.title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }

    @ViewBuilder
    private var gameContent: some View {
        switch challengeType {
        case .speedSpeaking:
            SpeedSpeakingGame(
                score: $score,
                onRoundComplete: nextRound
            )
        case .tongueTwitters:
            TongueTwisterGame(
                score: $score,
                onRoundComplete: nextRound
            )
        case .wordChain:
            WordChainGame(
                score: $score,
                onRoundComplete: nextRound
            )
        case .rapidFireQA:
            RapidFireQAGame(
                score: $score,
                onRoundComplete: nextRound
            )
        case .shadowSpeaking:
            ShadowSpeakingGame(
                score: $score,
                onRoundComplete: nextRound
            )
        case .storyBuilder:
            StoryBuilderGame(
                score: $score,
                onRoundComplete: nextRound
            )
        }
    }

    private func startGame() {
        isPlaying = true
        timeRemaining = 60
        score = 0
        currentRound = 1

        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 0.1
            } else {
                endGame()
            }
        }
    }

    private func nextRound() {
        currentRound += 1
        // Add bonus time for completing round
        timeRemaining = min(60, timeRemaining + 10)
    }

    private func endGame() {
        gameTimer?.invalidate()
        isPlaying = false

        let results = ChallengeResults(
            challengeType: challengeType,
            score: score,
            roundsCompleted: currentRound,
            accuracy: Double.random(in: 75...95),
            wordsPerMinute: Double.random(in: 100...150),
            fluencyBonus: calculateFluencyBonus()
        )

        onComplete(results)
    }

    private func calculateFluencyBonus() -> Int {
        let baseBonus = score / 10
        let speedBonus = currentRound * 5
        return baseBonus + speedBonus
    }
}

// MARK: - Mini Games

struct SpeedSpeakingGame: View {
    @Binding var score: Int
    let onRoundComplete: () -> Void
    @State private var currentPhrase = "The quick brown fox jumps over the lazy dog"
    @State private var isRecording = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Speak as fast as you can!")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.gray)

            Text(currentPhrase)
                .font(.system(size: 20))
                .multilineTextAlignment(.center)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "F2F2F7"))
                )

            Button(action: toggleRecording) {
                Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(isRecording ? Color(hex: "FF3B30") : Color(hex: "007AFF"))
            }

            if isRecording {
                Text("Recording...")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }

    private func toggleRecording() {
        isRecording.toggle()
        if !isRecording {
            // Process recording
            score += 10
            onRoundComplete()
        }
    }
}

struct TongueTwisterGame: View {
    @Binding var score: Int
    let onRoundComplete: () -> Void

    let twisters = [
        "She sells seashells by the seashore",
        "Peter Piper picked a peck of pickled peppers",
        "How much wood would a woodchuck chuck"
    ]

    @State private var currentTwister = 0
    @State private var isRecording = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Master the Tongue Twister!")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.gray)

            Text(twisters[currentTwister])
                .font(.system(size: 22, weight: .medium))
                .multilineTextAlignment(.center)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "FFE6E6"))
                )

            // Speed indicator
            HStack {
                Image(systemName: "tortoise.fill")
                    .foregroundColor(.gray)
                Slider(value: .constant(0.5))
                    .disabled(true)
                Image(systemName: "hare.fill")
                    .foregroundColor(Color(hex: "34C759"))
            }
            .padding(.horizontal)

            Button(action: toggleRecording) {
                HStack {
                    Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                    Text(isRecording ? "Stop" : "Start")
                }
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 16)
                .background(isRecording ? Color(hex: "FF3B30") : Color(hex: "34C759"))
                .cornerRadius(12)
            }
        }
        .padding()
    }

    private func toggleRecording() {
        isRecording.toggle()
        if !isRecording {
            score += 15
            currentTwister = (currentTwister + 1) % twisters.count
            onRoundComplete()
        }
    }
}

struct WordChainGame: View {
    @Binding var score: Int
    let onRoundComplete: () -> Void

    @State private var currentWord = "Apple"
    @State private var userInput = ""
    @State private var wordChain: [String] = ["Apple"]
    @State private var feedback = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Continue the Word Chain!")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.gray)

            // Word chain display
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(wordChain, id: \.self) { word in
                        Text(word)
                            .font(.system(size: 16, weight: .medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color(hex: "007AFF").opacity(0.1))
                            )
                    }
                }
            }
            .padding(.horizontal)

            Text("Next word must start with: \(String(currentWord.last!).uppercased())")
                .font(.system(size: 16))
                .foregroundColor(Color(hex: "007AFF"))

            TextField("Enter word...", text: $userInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button(action: submitWord) {
                Text("Submit")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 120)
                    .padding(.vertical, 12)
                    .background(Color(hex: "007AFF"))
                    .cornerRadius(8)
            }

            if !feedback.isEmpty {
                Text(feedback)
                    .font(.system(size: 14))
                    .foregroundColor(feedback.contains("Correct") ? Color(hex: "34C759") : Color(hex: "FF3B30"))
            }
        }
        .padding()
    }

    private func submitWord() {
        if userInput.lowercased().first == currentWord.lowercased().last {
            wordChain.append(userInput)
            currentWord = userInput
            userInput = ""
            feedback = "Correct! +5 points"
            score += 5

            if wordChain.count % 5 == 0 {
                onRoundComplete()
            }
        } else {
            feedback = "Word must start with \(String(currentWord.last!).uppercased())"
        }
    }
}

struct RapidFireQAGame: View {
    @Binding var score: Int
    let onRoundComplete: () -> Void

    let questions = [
        "What's your favorite color?",
        "Where are you from?",
        "What do you do for fun?",
        "What's your favorite food?"
    ]

    @State private var currentQuestion = 0
    @State private var timePerQuestion = 5.0
    @State private var isAnswering = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Answer Quickly!")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.gray)

            // Question
            Text(questions[currentQuestion])
                .font(.system(size: 22, weight: .medium))
                .multilineTextAlignment(.center)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "E8F5FF"))
                )

            // Timer bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: "007AFF"))
                        .frame(width: geometry.size.width * (timePerQuestion / 5), height: 8)
                        .animation(.linear(duration: 0.1), value: timePerQuestion)
                }
            }
            .frame(height: 8)
            .padding(.horizontal)

            Button(action: recordAnswer) {
                Image(systemName: isAnswering ? "stop.circle.fill" : "mic.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(isAnswering ? Color(hex: "FF3B30") : Color(hex: "007AFF"))
            }

            Text("Tap to answer")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding()
        .onAppear {
            startTimer()
        }
    }

    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if timePerQuestion > 0 {
                timePerQuestion -= 0.1
            } else {
                timer.invalidate()
                nextQuestion()
            }
        }
    }

    private func recordAnswer() {
        isAnswering.toggle()
        if !isAnswering {
            score += Int(timePerQuestion * 2) // Bonus for speed
            nextQuestion()
        }
    }

    private func nextQuestion() {
        currentQuestion = (currentQuestion + 1) % questions.count
        timePerQuestion = 5.0
        if currentQuestion == 0 {
            onRoundComplete()
        }
        startTimer()
    }
}

struct ShadowSpeakingGame: View {
    @Binding var score: Int
    let onRoundComplete: () -> Void

    @State private var isPlaying = false
    @State private var isRecording = false
    @State private var currentText = "The weather today is absolutely beautiful"

    var body: some View {
        VStack(spacing: 20) {
            Text("Shadow the Speaker!")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.gray)

            Text(currentText)
                .font(.system(size: 18))
                .multilineTextAlignment(.center)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "F2F2F7"))
                )

            // Audio controls
            HStack(spacing: 30) {
                Button(action: playAudio) {
                    VStack {
                        Image(systemName: isPlaying ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                            .font(.system(size: 30))
                            .foregroundColor(Color(hex: "007AFF"))
                        Text("Listen")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }

                Button(action: toggleRecording) {
                    VStack {
                        Image(systemName: isRecording ? "mic.fill" : "mic")
                            .font(.system(size: 30))
                            .foregroundColor(isRecording ? Color(hex: "FF3B30") : Color(hex: "34C759"))
                        Text(isRecording ? "Recording" : "Shadow")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
            }

            // Visual feedback
            if isRecording {
                HStack(spacing: 4) {
                    ForEach(0..<5) { index in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(hex: "34C759"))
                            .frame(width: 4, height: CGFloat.random(in: 10...40))
                            .animation(
                                Animation.easeInOut(duration: 0.3)
                                    .repeatForever()
                                    .delay(Double(index) * 0.1),
                                value: isRecording
                            )
                    }
                }
                .frame(height: 40)
            }
        }
        .padding()
    }

    private func playAudio() {
        isPlaying = true
        // Simulate audio playing
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isPlaying = false
        }
    }

    private func toggleRecording() {
        isRecording.toggle()
        if !isRecording {
            score += 20
            onRoundComplete()
        }
    }
}

struct StoryBuilderGame: View {
    @Binding var score: Int
    let onRoundComplete: () -> Void

    @State private var storyPrompt = "Once upon a time, there was a..."
    @State private var userStory = ""
    @State private var wordCount = 0
    @State private var isRecording = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Continue the Story!")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.gray)

            Text(storyPrompt)
                .font(.system(size: 16))
                .italic()
                .multilineTextAlignment(.leading)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "FFF9E6"))
                )

            // Word counter
            HStack {
                Text("Words spoken:")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                Text("\(wordCount)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "007AFF"))
                Spacer()
                Text("Goal: 50 words")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: "34C759"))
                        .frame(width: geometry.size.width * (CGFloat(min(wordCount, 50)) / 50), height: 8)
                        .animation(.spring(), value: wordCount)
                }
            }
            .frame(height: 8)
            .padding(.horizontal)

            Button(action: toggleRecording) {
                HStack {
                    Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.system(size: 24))
                    Text(isRecording ? "Stop Story" : "Start Story")
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.vertical, 16)
                .background(isRecording ? Color(hex: "FF3B30") : Color(hex: "AF52DE"))
                .cornerRadius(12)
            }
        }
        .padding()
    }

    private func toggleRecording() {
        isRecording.toggle()
        if isRecording {
            // Start recording and counting words
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                if isRecording {
                    wordCount += Int.random(in: 2...5)
                    if wordCount >= 50 {
                        timer.invalidate()
                        isRecording = false
                        score += 25
                        onRoundComplete()
                    }
                } else {
                    timer.invalidate()
                }
            }
        }
    }
}

// MARK: - Leaderboard Section
struct LeaderboardSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Weekly Leaderboard")
                    .font(.system(size: 20, weight: .bold))
                Spacer()
                Text("See All")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "007AFF"))
            }

            VStack(spacing: 12) {
                LeaderboardRow(rank: 1, name: "You", score: 2450, isCurrentUser: true)
                LeaderboardRow(rank: 2, name: "Alex Chen", score: 2380, isCurrentUser: false)
                LeaderboardRow(rank: 3, name: "Maria Garcia", score: 2210, isCurrentUser: false)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        )
    }
}

struct LeaderboardRow: View {
    let rank: Int
    let name: String
    let score: Int
    let isCurrentUser: Bool

    var rankColor: Color {
        switch rank {
        case 1: return Color(hex: "FFD700")
        case 2: return Color(hex: "C0C0C0")
        case 3: return Color(hex: "CD7F32")
        default: return Color.gray
        }
    }

    var body: some View {
        HStack {
            // Rank badge
            Text("#\(rank)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(rankColor)
                .frame(width: 40)

            // Name
            Text(name)
                .font(.system(size: 16, weight: isCurrentUser ? .semibold : .regular))
                .foregroundColor(isCurrentUser ? Color(hex: "007AFF") : .black)

            Spacer()

            // Score
            Text("\(score) pts")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            isCurrentUser ?
            Color(hex: "007AFF").opacity(0.05) :
                Color.clear
        )
        .cornerRadius(8)
    }
}

// MARK: - Challenge Results View
struct ChallengeResultsView: View {
    let results: ChallengeResults
    let onDismiss: () -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Score display
                VStack(spacing: 16) {
                    Text("Challenge Complete!")
                        .font(.system(size: 28, weight: .bold))

                    Text("\(results.score)")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(Color(hex: "007AFF"))

                    Text("Points Earned")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                .padding(.top, 40)

                // Stats
                VStack(spacing: 16) {
                    ChallengeStatRow(label: "Rounds", value: "\(results.roundsCompleted)")
                    ChallengeStatRow(label: "Accuracy", value: "\(Int(results.accuracy))%")
                    ChallengeStatRow(label: "Speed", value: "\(Int(results.wordsPerMinute)) WPM")
                    ChallengeStatRow(label: "Fluency Bonus", value: "+\(results.fluencyBonus)")
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(hex: "F2F2F7"))
                )
                .padding(.horizontal)

                Spacer()

                Button(action: onDismiss) {
                    Text("Continue")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "007AFF"))
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .navigationBarHidden(true)
        }
    }
}

struct ChallengeStatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 16))
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black)
        }
    }
}

// MARK: - Supporting Types
enum ChallengeType: String, CaseIterable, Identifiable {
    case speedSpeaking = "Speed Speaking"
    case tongueTwitters = "Tongue Twisters"
    case wordChain = "Word Chain"
    case rapidFireQA = "Rapid Fire Q&A"
    case shadowSpeaking = "Shadow Speaking"
    case storyBuilder = "Story Builder"

    var id: String { rawValue }

    var title: String { rawValue }

    var icon: String {
        switch self {
        case .speedSpeaking: return "speedometer"
        case .tongueTwitters: return "mouth.fill"
        case .wordChain: return "link"
        case .rapidFireQA: return "bolt.fill"
        case .shadowSpeaking: return "person.2.fill"
        case .storyBuilder: return "book.fill"
        }
    }

    var color: Color {
        switch self {
        case .speedSpeaking: return Color(hex: "007AFF")
        case .tongueTwitters: return Color(hex: "FF3B30")
        case .wordChain: return Color(hex: "34C759")
        case .rapidFireQA: return Color(hex: "FF9500")
        case .shadowSpeaking: return Color(hex: "AF52DE")
        case .storyBuilder: return Color(hex: "5AC8FA")
        }
    }

    var difficulty: Int {
        switch self {
        case .speedSpeaking: return 2
        case .tongueTwitters: return 3
        case .wordChain: return 1
        case .rapidFireQA: return 2
        case .shadowSpeaking: return 3
        case .storyBuilder: return 2
        }
    }

    var requiredLevel: Int {
        switch self {
        case .wordChain: return 1
        case .speedSpeaking, .rapidFireQA, .storyBuilder: return 3
        case .tongueTwitters, .shadowSpeaking: return 5
        }
    }

    var isUnlocked: Bool {
        // Check user level
        return true // Placeholder
    }

    var bestScore: Int {
        // Get from storage
        return Int.random(in: 100...500)
    }
}

struct ChallengeResults {
    let challengeType: ChallengeType
    let score: Int
    let roundsCompleted: Int
    let accuracy: Double
    let wordsPerMinute: Double
    let fluencyBonus: Int
}

class FluencyGameEngine: ObservableObject {
    @Published var currentGame: ChallengeType?
    @Published var gameState: GameState = .idle

    enum GameState {
        case idle
        case playing
        case paused
        case completed
    }
}

#Preview {
    FluencyChallengesView()
}