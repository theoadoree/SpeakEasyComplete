// Views/Practice/ScenarioPracticeView.swift
import SwiftUI

struct ScenarioPracticeView: View {
    @State private var selectedCategory: ScenarioCategory = .travel
    @State private var selectedScenario: PracticeScenario?
    @State private var showingScenarioSession = false

    enum ScenarioCategory: String, CaseIterable {
        case travel = "Travel"
        case dining = "Dining"
        case shopping = "Shopping"
        case social = "Social"
        case work = "Work"
        case emergency = "Emergency"

        var icon: String {
            switch self {
            case .travel: return "airplane"
            case .dining: return "fork.knife"
            case .shopping: return "cart.fill"
            case .social: return "person.2.fill"
            case .work: return "briefcase.fill"
            case .emergency: return "cross.case.fill"
            }
        }

        var scenarios: [PracticeScenario] {
            switch self {
            case .travel:
                return [
                    PracticeScenario(
                        title: "Booking a Hotel",
                        description: "Reserve a room and ask about amenities",
                        difficulty: .beginner,
                        keyPhrases: ["Quisiera reservar...", "¿Cuánto cuesta...?", "¿Está incluido...?"],
                        situation: "You arrive at a hotel reception and want to book a room for 2 nights"
                    ),
                    PracticeScenario(
                        title: "Asking for Directions",
                        description: "Navigate using Spanish directions",
                        difficulty: .beginner,
                        keyPhrases: ["¿Dónde está...?", "¿Cómo llego a...?", "¿Está lejos?"],
                        situation: "You're lost in a Spanish city and need to find the train station"
                    ),
                    PracticeScenario(
                        title: "Airport Check-in",
                        description: "Check in for your flight and handle luggage",
                        difficulty: .intermediate,
                        keyPhrases: ["Mi vuelo sale a...", "¿Dónde facturo?", "Equipaje de mano"],
                        situation: "You're at the airport counter checking in for an international flight"
                    ),
                ]
            case .dining:
                return [
                    PracticeScenario(
                        title: "Ordering at a Restaurant",
                        description: "Order food and drinks like a local",
                        difficulty: .beginner,
                        keyPhrases: ["Me gustaría...", "Para beber...", "La cuenta, por favor"],
                        situation: "You're at a tapas bar ready to order dinner"
                    ),
                    PracticeScenario(
                        title: "Making a Reservation",
                        description: "Call to book a table at a restaurant",
                        difficulty: .intermediate,
                        keyPhrases: ["Quisiera reservar una mesa", "Para cuántas personas", "¿A qué hora?"],
                        situation: "You're calling a popular restaurant to make a dinner reservation"
                    ),
                    PracticeScenario(
                        title: "Dietary Restrictions",
                        description: "Communicate allergies and preferences",
                        difficulty: .intermediate,
                        keyPhrases: ["Soy alérgico a...", "Sin gluten", "Vegetariano"],
                        situation: "You have food allergies and need to explain them to the waiter"
                    ),
                ]
            case .shopping:
                return [
                    PracticeScenario(
                        title: "Buying Clothes",
                        description: "Shop for clothing and try things on",
                        difficulty: .beginner,
                        keyPhrases: ["¿Cuánto cuesta?", "¿Tiene en otra talla?", "Me lo llevo"],
                        situation: "You're in a clothing store looking for a new shirt"
                    ),
                    PracticeScenario(
                        title: "At the Market",
                        description: "Buy fresh produce and negotiate prices",
                        difficulty: .intermediate,
                        keyPhrases: ["Un kilo de...", "¿Cuánto es todo?", "¿Tiene más fresco?"],
                        situation: "You're shopping at a local produce market"
                    ),
                ]
            case .social:
                return [
                    PracticeScenario(
                        title: "Meeting New People",
                        description: "Introduce yourself and make small talk",
                        difficulty: .beginner,
                        keyPhrases: ["Mucho gusto", "¿De dónde eres?", "Yo soy de..."],
                        situation: "You're at a social gathering meeting Spanish speakers"
                    ),
                    PracticeScenario(
                        title: "Making Plans",
                        description: "Invite someone and coordinate schedules",
                        difficulty: .intermediate,
                        keyPhrases: ["¿Te gustaría...?", "¿Cuándo te viene bien?", "Nos vemos a las..."],
                        situation: "You want to invite a new friend to coffee"
                    ),
                ]
            case .work:
                return [
                    PracticeScenario(
                        title: "Job Interview",
                        description: "Answer common interview questions",
                        difficulty: .advanced,
                        keyPhrases: ["Mi experiencia incluye...", "Soy bueno en...", "Mis objetivos son..."],
                        situation: "You're in a job interview for a position in Spain"
                    ),
                    PracticeScenario(
                        title: "Business Meeting",
                        description: "Present ideas in a professional setting",
                        difficulty: .advanced,
                        keyPhrases: ["Me gustaría proponer...", "Según los datos...", "En conclusión..."],
                        situation: "You're presenting a project to Spanish-speaking colleagues"
                    ),
                ]
            case .emergency:
                return [
                    PracticeScenario(
                        title: "At the Doctor",
                        description: "Describe symptoms and get medical help",
                        difficulty: .intermediate,
                        keyPhrases: ["Me duele...", "Tengo fiebre", "Necesito un médico"],
                        situation: "You're not feeling well and need to see a doctor"
                    ),
                    PracticeScenario(
                        title: "Lost Items",
                        description: "Report lost belongings to authorities",
                        difficulty: .intermediate,
                        keyPhrases: ["He perdido...", "¿Dónde está la comisaría?", "Mi pasaporte"],
                        situation: "You've lost your wallet and need to report it"
                    ),
                ]
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Category Selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(ScenarioCategory.allCases, id: \.self) { category in
                        CategoryButton(
                            category: category,
                            isSelected: selectedCategory == category,
                            onTap: {
                                selectedCategory = category
                            }
                        )
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))

            Divider()

            // Scenarios List
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(selectedCategory.scenarios) { scenario in
                        ScenarioCard(
                            scenario: scenario,
                            onStart: {
                                selectedScenario = scenario
                                showingScenarioSession = true
                            }
                        )
                    }
                }
                .padding()
            }
        }
        .fullScreenCover(isPresented: $showingScenarioSession) {
            if let scenario = selectedScenario {
                ScenarioSessionView(scenario: scenario)
            }
        }
    }
}

struct CategoryButton: View {
    let category: ScenarioPracticeView.ScenarioCategory
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.title3)

                Text(category.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(width: 90, height: 70)
            .background(isSelected ? Color.blue : Color(.secondarySystemBackground))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(12)
        }
    }
}

struct ScenarioCard: View {
    let scenario: PracticeScenario
    let onStart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(scenario.title)
                        .font(.headline)

                    Text(scenario.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                DifficultyBadge(difficulty: scenario.difficulty)
            }

            // Situation
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                    .font(.caption)

                Text(scenario.situation)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(10)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)

            // Key Phrases Preview
            VStack(alignment: .leading, spacing: 6) {
                Text("Key Phrases:")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)

                ForEach(scenario.keyPhrases.prefix(3), id: \.self) { phrase in
                    Text("• \(phrase)")
                        .font(.caption)
                        .foregroundColor(.primary)
                }
            }

            // Start Button
            Button(action: onStart) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Start Practice")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8)
    }
}

struct DifficultyBadge: View {
    let difficulty: PracticeScenario.Difficulty

    var body: some View {
        Text(difficulty.rawValue)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(difficulty.color.opacity(0.2))
            .foregroundColor(difficulty.color)
            .cornerRadius(8)
    }
}

// MARK: - Scenario Session View

struct ScenarioSessionView: View {
    let scenario: PracticeScenario
    @Environment(\.dismiss) var dismiss
    @StateObject private var conversationViewModel = ConversationViewModel()
    @StateObject private var speechService = SpeechService.shared
    @State private var messageText = ""
    @State private var showingComplete = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Scenario Context Banner
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "theatermasks.fill")
                            .foregroundColor(.blue)

                        Text(scenario.title)
                            .font(.headline)

                        Spacer()

                        DifficultyBadge(difficulty: scenario.difficulty)
                    }

                    Text(scenario.situation)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGroupedBackground))

                Divider()

                // Messages Area
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            // Initial system message with key phrases
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Key Phrases to Use:")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)

                                ForEach(scenario.keyPhrases, id: \.self) { phrase in
                                    Text("💬 \(phrase)")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(6)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .padding()

                            // Conversation messages
                            ForEach(conversationViewModel.messages) { message in
                                MessageBubbleView(message: message)
                                    .id(message.id)
                            }
                        }
                        .padding()
                    }
                    .background(Color(.systemGroupedBackground))
                    .onChange(of: conversationViewModel.messages.count) { _ in
                        if let lastMessage = conversationViewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }

                // Input Area
                VStack(spacing: 12) {
                    if speechService.isRecording {
                        VoiceWaveformView()
                            .frame(height: 60)
                            .padding(.horizontal)
                    }

                    HStack(spacing: 12) {
                        TextField("Type your message...", text: $messageText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .disabled(conversationViewModel.isSending || speechService.isRecording)

                        Button(action: toggleRecording) {
                            Image(systemName: speechService.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(speechService.isRecording ? .red : .blue)
                        }

                        Button(action: sendMessage) {
                            Image(systemName: "arrow.up.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(messageText.isEmpty ? .gray : .blue)
                        }
                        .disabled(messageText.isEmpty || conversationViewModel.isSending)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                .background(Color(.systemBackground))
            }
            .navigationTitle("Role Play")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("End Session") {
                        showingComplete = true
                    }
                }
            }
        }
        .onAppear {
            startScenario()
        }
        .sheet(isPresented: $showingComplete) {
            ScenarioCompletionView(
                scenario: scenario,
                messageCount: conversationViewModel.messages.count,
                onDismiss: { dismiss() }
            )
        }
    }

    private func startScenario() {
        // Start conversation with scenario context
        conversationViewModel.startNewConversation(
            title: scenario.title,
            language: "Spanish"
        )

        // Add initial AI message to set the scene
        let initialMessage = Message(
            id: UUID(),
            content: getInitialMessage(),
            isUser: false,
            timestamp: Date(),
            language: "es"
        )

        // Add initial message via the conversation view model
        // (This would normally go through the proper API)
    }

    private func getInitialMessage() -> String {
        // Generate contextual opening based on scenario
        switch scenario.title {
        case "Booking a Hotel":
            return "¡Buenas tardes! Bienvenido al Hotel España. ¿En qué puedo ayudarle?"
        case "Ordering at a Restaurant":
            return "¡Hola! Bienvenido a nuestro restaurante. ¿Qué le gustaría tomar?"
        case "Asking for Directions":
            return "¿Sí? ¿En qué puedo ayudarle?"
        case "Meeting New People":
            return "¡Hola! No creo que nos hayamos conocido antes. ¿Cómo te llamas?"
        default:
            return "¡Hola! ¿Cómo puedo ayudarte?"
        }
    }

    private func sendMessage() {
        guard !messageText.isEmpty else { return }

        let text = messageText
        messageText = ""

        Task {
            // Create temporary user profile for the conversation
            let profile = UserProfile(
                id: UUID(),
                userId: "",
                userName: "User",
                targetLanguage: "Spanish",
                nativeLanguage: "English",
                proficiencyLevel: .intermediate
            )

            await conversationViewModel.sendMessage(text, userProfile: profile)
        }
    }

    private func toggleRecording() {
        if speechService.isRecording {
            speechService.stopRecording()

            if !speechService.recognizedText.isEmpty {
                messageText = speechService.recognizedText
                speechService.clearRecognizedText()
                sendMessage()
            }
        } else {
            do {
                try speechService.startRecording(language: "es-ES")
            } catch {
                print("Failed to start recording: \(error)")
            }
        }
    }
}

// MARK: - Scenario Completion View

struct ScenarioCompletionView: View {
    let scenario: PracticeScenario
    let messageCount: Int
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            // Success Icon
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)

            VStack(spacing: 8) {
                Text("Scenario Complete!")
                    .font(.title)
                    .fontWeight(.bold)

                Text(scenario.title)
                    .font(.headline)
                    .foregroundColor(.secondary)
            }

            // Stats
            VStack(spacing: 16) {
                StatRow(label: "Messages Sent", value: "\(messageCount)")
                StatRow(label: "Difficulty", value: scenario.difficulty.rawValue)
                StatRow(label: "Key Phrases Used", value: "\(scenario.keyPhrases.count)")
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .cornerRadius(12)

            // Feedback
            VStack(alignment: .leading, spacing: 12) {
                Text("Great job!")
                    .font(.headline)

                Text("You practiced real-world Spanish conversation. Keep practicing to build confidence!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)

            Spacer()

            // Done Button
            Button(action: onDismiss) {
                Text("Done")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding()
    }
}

struct StatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .fontWeight(.semibold)
        }
    }
}

// MARK: - Models

struct PracticeScenario: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let difficulty: Difficulty
    let keyPhrases: [String]
    let situation: String

    enum Difficulty: String {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"

        var color: Color {
            switch self {
            case .beginner: return .green
            case .intermediate: return .orange
            case .advanced: return .red
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ScenarioPracticeView()
}
