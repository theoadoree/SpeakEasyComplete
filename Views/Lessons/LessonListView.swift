import SwiftUI

struct LessonListView: View {
    @StateObject private var viewModel = LessonListViewModel()
    @State private var selectedCategory: LessonCategory? = nil
    @State private var searchText = ""
    @State private var showingLessonDetail = false
    @State private var selectedLesson: Lesson?

    var filteredLessons: [Lesson] {
        var lessons = viewModel.lessons

        if let category = selectedCategory {
            lessons = lessons.filter { $0.category == category }
        }

        if !searchText.isEmpty {
            lessons = lessons.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }

        return lessons
    }

    var overallProgress: Double {
        guard !viewModel.lessons.isEmpty else { return 0 }
        let totalProgress = viewModel.lessons.reduce(0) { $0 + $1.completionRate }
        return totalProgress / Double(viewModel.lessons.count)
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header with progress
                        HeaderView(progress: overallProgress, totalLessons: viewModel.lessons.count)
                            .padding(.horizontal)
                            .padding(.top)

                        // Search Bar
                        SearchBar(text: $searchText)
                            .padding(.horizontal)

                        // Category Filter
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                CategoryChip(
                                    title: "All",
                                    isSelected: selectedCategory == nil,
                                    color: .blue
                                ) {
                                    withAnimation(.spring()) {
                                        selectedCategory = nil
                                    }
                                }

                                ForEach(LessonCategory.allCases, id: \.self) { category in
                                    CategoryChip(
                                        title: category.rawValue,
                                        isSelected: selectedCategory == category,
                                        color: category.color,
                                        icon: category.icon
                                    ) {
                                        withAnimation(.spring()) {
                                            selectedCategory = category
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }

                        // Lessons Grid
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            ForEach(filteredLessons) { lesson in
                                LessonCard(lesson: lesson) {
                                    selectedLesson = lesson
                                    showingLessonDetail = true
                                }
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(item: $selectedLesson) { lesson in
            LessonDetailView(lesson: lesson)
        }
    }
}

// MARK: - Header View
struct HeaderView: View {
    let progress: Double
    let totalLessons: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Progress")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)

                    Text("\(Int(progress * 100))% Complete • \(totalLessons) Lessons")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }

                Spacer()

                // Streak Badge
                VStack {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.orange)

                    Text("5 Day")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.orange)
                }
                .padding(12)
                .background(
                    Circle()
                        .fill(Color.orange.opacity(0.1))
                )
            }

            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 12)

                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [.blue, .green],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 12)
                        .animation(.spring(), value: progress)
                }
            }
            .frame(height: 12)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        )
    }
}

// MARK: - Search Bar
struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)

            TextField("Search lessons...", text: $text)
                .foregroundColor(.black)

            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
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

// MARK: - Category Chip
struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    var icon: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                }
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : color)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? color : color.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(color, lineWidth: isSelected ? 0 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Lesson Card
struct LessonCard: View {
    let lesson: Lesson
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                // Header with icon and number
                HStack {
                    ZStack {
                        Circle()
                            .fill(lesson.category.color.opacity(0.1))
                            .frame(width: 40, height: 40)

                        Text("1")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(lesson.category.color)
                    }

                    Spacer()

                    if lesson.completionRate > 0 {
                        Text("\(Int(lesson.completionRate * 100))%")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.green)
                    } else if !lesson.isUnlocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }

                // Title and subtitle
                VStack(alignment: .leading, spacing: 4) {
                    Text(lesson.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                        .lineLimit(1)

                    Text(lesson.description)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                // Bottom info
                HStack(spacing: 12) {
                    Label("\(lesson.duration)m", systemImage: "clock")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)

                    // Difficulty dots
                    HStack(spacing: 2) {
                        ForEach(1...5, id: \.self) { level in
                            Circle()
                                .fill(level <= 3 ? lesson.category.color : Color.gray.opacity(0.3))
                                .frame(width: 4, height: 4)
                        }
                    }

                    Spacer()
                }

                // Progress bar if started
                if lesson.completionRate > 0 {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 4)

                            RoundedRectangle(cornerRadius: 2)
                                .fill(.green)
                                .frame(width: geometry.size.width * lesson.completionRate, height: 4)
                        }
                    }
                    .frame(height: 4)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(isPressed ? 0.1 : 0.05), radius: isPressed ? 5 : 10, y: isPressed ? 2 : 5)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .opacity(lesson.isUnlocked ? 1.0 : 0.7)
        }
        .buttonStyle(PlainButtonStyle())
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
        }
        .disabled(!lesson.isUnlocked)
    }
}

// MARK: - Lesson View Model
class LessonListViewModel: ObservableObject {
    @Published var lessons: [Lesson] = []

    init() {
        loadLessons()
    }

    func loadLessons() {
        // Load lessons - in production, would load user progress from storage
        lessons = Lesson.getAllLessons()
    }
}

// Helper extension for UI state
extension Lesson {
    var isUnlocked: Bool {
        return true // For demo, all lessons are unlocked
    }

    var completionRate: Double {
        return isCompleted ? 1.0 : 0.0
    }

    var bestScore: Int? {
        return nil // Would come from user progress data
    }

    var fluencyScore: Double {
        return 0.0 // Would come from user progress data
    }
}

#Preview {
    LessonListView()
}