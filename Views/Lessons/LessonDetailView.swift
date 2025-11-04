import SwiftUI
import AVFoundation

struct LessonDetailView: View {
    let lesson: Lesson
    @StateObject private var autoVoiceService = AutoVoiceService.shared
    @StateObject private var openAIService = OpenAIService.shared
    @State private var selectedScenario: ConversationScenario?
    @State private var showingPractice = false
    @State private var showingSettings = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Lesson Header
                        LessonHeaderCard(lesson: lesson)
                            .padding(.horizontal)

                        // Fluency Techniques Section - commented out as lesson doesn't have this property
                        /*
                        if !lesson.fluencyTechniques.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Fluency Techniques")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.black)
                                    .padding(.horizontal)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(lesson.fluencyTechniques, id: \.name) { technique in
                                            TechniqueCard(technique: technique)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        */

                        // Scenarios Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Practice Scenarios")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.black)

                                Spacer()

                                Button(action: { showingSettings = true }) {
                                    Image(systemName: "gearshape.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.horizontal)

                            VStack(spacing: 12) {
                                ForEach(lesson.scenarios, id: \.id) { scenario in
                                    ScenarioCard(scenario: scenario) {
                                        selectedScenario = scenario
                                        showingPractice = true
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }

                        // Learning Points Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("What You'll Learn")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal)

                            VStack(spacing: 12) {
                                // Vocabulary - commented out as lesson doesn't have vocabularyFocus
                                /*
                                if !lesson.vocabularyFocus.isEmpty {
                                    LearningPointRow(
                                        icon: "textformat",
                                        title: "Vocabulary",
                                        items: lesson.vocabularyFocus
                                    )
                                }
                                */

                                // Grammar - commented out as lesson doesn't have grammarPoints
                                /*
                                if !lesson.grammarPoints.isEmpty {
                                    LearningPointRow(
                                        icon: "text.book.closed",
                                        title: "Grammar",
                                        items: lesson.grammarPoints
                                    )
                                }
                                */

                                // Cultural Notes - commented out as lesson doesn't have culturalNotes
                                /*
                                if !lesson.culturalNotes.isEmpty {
                                    LearningPointRow(
                                        icon: "globe",
                                        title: "Cultural Context",
                                        items: lesson.culturalNotes
                                    )
                                }
                                */
                            }
                            .padding(.horizontal)
                        }

                        // Skills Development
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Skills Development")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    // Lesson doesn't have skills property - show default skills
                                    ForEach([LanguageSkill.speaking, LanguageSkill.listening], id: \.self) { skill in
                                        SkillBadge(skill: skill)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.bottom, 100)
                    }
                    .padding(.top)
                }

                // Floating Start Button
                VStack {
                    Spacer()

                    Button(action: {
                        if let firstScenario = lesson.scenarios.first {
                            selectedScenario = firstScenario
                            showingPractice = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "mic.fill")
                                .font(.system(size: 20))

                            Text("Start Practice")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [.blue, .blue.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: Color.blue.opacity(0.3), radius: 10, y: 5)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.gray.opacity(0.6))
                }
            )
        }
        .fullScreenCover(item: $selectedScenario) { scenario in
            ConversationPracticeView(lesson: lesson, scenario: scenario)
        }
        .sheet(isPresented: $showingSettings) {
            AutoVoiceSettingsView()
        }
    }
}

// MARK: - Lesson Header Card
struct LessonHeaderCard: View {
    let lesson: Lesson

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                // Lesson Number Badge
                ZStack {
                    Circle()
                        .fill(lesson.category.color)
                        .frame(width: 50, height: 50)

                    Text("1")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(lesson.title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)

                    HStack(spacing: 8) {
                        Label("\(lesson.duration) min", systemImage: "clock.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)

                        Text("•")
                            .foregroundColor(.gray)

                        Text(lesson.category.rawValue)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(lesson.category.color)
                    }
                }

                Spacer()
            }

            Text(lesson.description)
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .fixedSize(horizontal: false, vertical: true)

            // Progress and Stats
            if lesson.completionRate > 0 {
                HStack(spacing: 20) {
                    StatItem(
                        label: "Progress",
                        value: "\(Int(lesson.completionRate * 100))%",
                        color: .green
                    )

                    if let bestScore = lesson.bestScore {
                        StatItem(
                            label: "Best Score",
                            value: "\(bestScore)",
                            color: .blue
                        )
                    }

                    StatItem(
                        label: "Fluency",
                        value: String(format: "%.1f", lesson.fluencyScore),
                        color: .orange
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        )
    }
}

// MARK: - Stat Item
struct StatItem: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(color)

            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Technique Card
struct TechniqueCard: View {
    let technique: FluencyTechnique

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: techniqueIcon)
                    .font(.system(size: 16))
                    .foregroundColor(.blue)

                Text(technique.rawValue)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
            }

            Text(technique.description)
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .lineLimit(2)

            // targetWPM property doesn't exist on FluencyTechnique - commented out
            /*
            if let targetWPM = technique.targetWPM {
                HStack {
                    Image(systemName: "speedometer")
                        .font(.system(size: 10))
                    Text("\(targetWPM) WPM")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(Color(hex: "34C759"))
            }
            */
        }
        .padding(12)
        .frame(width: 200)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        )
    }

    var techniqueIcon: String {
        // Use the icon from the technique enum
        return technique.icon
    }
}

// MARK: - Scenario Card
struct ScenarioCard: View {
    let scenario: ConversationScenario
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(scenario.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)

                        Text(scenario.context)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }

                    Spacer()

                    Image(systemName: "mic.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.blue)
                }

                HStack(spacing: 16) {
                    Label("You: \(scenario.roleYouPlay)", systemImage: "person.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)

                    if scenario.autoVoiceEnabled {
                        Label("Auto Voice", systemImage: "mic.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.green)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Learning Point Row
struct LearningPointRow: View {
    let icon: String
    let title: String
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.blue)

                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(items, id: \.self) { item in
                        Text(item)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemGray6))
                            )
                    }
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        )
    }
}

// MARK: - Skill Badge
struct SkillBadge: View {
    let skill: LanguageSkill

    var skillColor: Color {
        switch skill {
        case .speaking: return .blue
        case .listening: return .green
        case .reading: return .orange
        case .writing: return .cyan
        case .vocabulary: return .purple
        case .grammar: return .red
        }
    }

    var body: some View {
        Text(skill.rawValue)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(skillColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(skillColor.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(skillColor, lineWidth: 1)
                    )
            )
    }
}

#Preview {
    LessonDetailView(lesson: Lesson.getAllLessons().first!)
}