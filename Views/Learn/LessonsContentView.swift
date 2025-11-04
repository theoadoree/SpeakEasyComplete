//
//  LessonsContentView.swift
//  SpeakEasy
//
//  Created by Claude on 2025-11-01.
//

import SwiftUI

struct LessonsContentView: View {
    @State private var selectedPath: LearningPath = .beginner
    @State private var lessons: [LessonModule] = []

    enum LearningPath: String, CaseIterable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
        case custom = "My Path"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Path Selector
            VStack(alignment: .leading, spacing: 12) {
                Text("Learning Path")
                    .font(.headline)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(LearningPath.allCases, id: \.self) { path in
                            PathButton(
                                path: path,
                                isSelected: selectedPath == path,
                                action: { selectedPath = path }
                            )
                        }
                    }
                }
            }

            // Lessons List
            VStack(alignment: .leading, spacing: 16) {
                Text("Available Lessons")
                    .font(.headline)

                ForEach(getLessonsForPath(selectedPath)) { module in
                    LessonModuleCard(module: module)
                }
            }
        }
        .onAppear {
            loadLessons()
        }
    }

    private func loadLessons() {
        // Load lessons from data source
        lessons = sampleLessons()
    }

    private func getLessonsForPath(_ path: LearningPath) -> [LessonModule] {
        lessons.filter { $0.level == path.rawValue }
    }

    private func sampleLessons() -> [LessonModule] {
        [
            LessonModule(
                id: "1",
                title: "Greetings & Introductions",
                description: "Learn how to greet people and introduce yourself",
                level: "Beginner",
                duration: 15,
                vocabularyCount: 20,
                progress: 0.8,
                isCompleted: false,
                topics: ["Hola", "¿Cómo estás?", "Me llamo...", "Mucho gusto"]
            ),
            LessonModule(
                id: "2",
                title: "Numbers & Time",
                description: "Master numbers, dates, and telling time",
                level: "Beginner",
                duration: 20,
                vocabularyCount: 35,
                progress: 0.3,
                isCompleted: false,
                topics: ["1-100", "Days", "Months", "Time"]
            ),
            LessonModule(
                id: "3",
                title: "Food & Ordering",
                description: "Learn food vocabulary and how to order in restaurants",
                level: "Beginner",
                duration: 18,
                vocabularyCount: 40,
                progress: 0.0,
                isCompleted: false,
                topics: ["Menu items", "Ordering", "Preferences", "Paying"]
            ),
            LessonModule(
                id: "4",
                title: "Travel & Tourism",
                description: "Essential phrases for traveling in Spanish-speaking countries",
                level: "Intermediate",
                duration: 25,
                vocabularyCount: 50,
                progress: 0.0,
                isCompleted: false,
                topics: ["Airport", "Hotel", "Directions", "Transportation"]
            ),
            LessonModule(
                id: "5",
                title: "Business Spanish",
                description: "Professional vocabulary for workplace communication",
                level: "Advanced",
                duration: 30,
                vocabularyCount: 60,
                progress: 0.0,
                isCompleted: false,
                topics: ["Meetings", "Presentations", "Negotiations", "Email"]
            )
        ]
    }
}

struct PathButton: View {
    let path: LessonsContentView.LearningPath
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: iconForPath(path))
                Text(path.rawValue)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? Color.blue : Color(.secondarySystemBackground))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(10)
        }
    }

    private func iconForPath(_ path: LessonsContentView.LearningPath) -> String {
        switch path {
        case .beginner: return "star.fill"
        case .intermediate: return "star.leadinghalf.filled"
        case .advanced: return "star.circle.fill"
        case .custom: return "person.fill"
        }
    }
}

struct LessonModule: Identifiable {
    let id: String
    let title: String
    let description: String
    let level: String
    let duration: Int
    let vocabularyCount: Int
    let progress: Double
    let isCompleted: Bool
    let topics: [String]
}

struct LessonModuleCard: View {
    let module: LessonModule
    @State private var showingDetail = false

    var body: some View {
        Button(action: { showingDetail = true }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(module.title)
                            .font(.headline)
                            .foregroundColor(.primary)

                        Text(module.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    if module.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title2)
                    }
                }

                // Topics
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(module.topics, id: \.self) { topic in
                            Text(topic)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(6)
                        }
                    }
                }

                // Stats
                HStack(spacing: 16) {
                    Label("\(module.duration) min", systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Label("\(module.vocabularyCount) words", systemImage: "text.book.closed")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()
                }

                // Progress
                if module.progress > 0 {
                    ProgressView(value: module.progress)
                        .tint(.blue)

                    Text("\(Int(module.progress * 100))% complete")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
        .sheet(isPresented: $showingDetail) {
            LessonDetailView(module: module)
        }
    }
}

struct LessonDetailView: View {
    let module: LessonModule
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(module.title)
                            .font(.title)
                            .fontWeight(.bold)

                        Text(module.description)
                            .foregroundColor(.secondary)

                        HStack(spacing: 16) {
                            Label("\(module.duration) min", systemImage: "clock.fill")
                            Label("\(module.vocabularyCount) words", systemImage: "text.book.closed.fill")
                            Label(module.level, systemImage: "chart.bar.fill")
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    .padding()

                    // Topics covered
                    VStack(alignment: .leading, spacing: 12) {
                        Text("What You'll Learn")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(module.topics, id: \.self) { topic in
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text(topic)
                            }
                            .padding(.horizontal)
                        }
                    }

                    // Start button
                    Button(action: {
                        // Start lesson
                    }) {
                        Text(module.progress > 0 ? "Continue Lesson" : "Start Lesson")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding()
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
        }
    }
}

#Preview {
    LessonsContentView()
}
