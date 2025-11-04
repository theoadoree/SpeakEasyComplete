//
//  VideosContentView.swift
//  SpeakEasy
//
//  Created by Claude on 2025-11-01.
//

import SwiftUI

struct VideosContentView: View {
    @State private var selectedCategory: VideoCategory = .all
    @State private var videos: [LearningVideo] = []

    enum VideoCategory: String, CaseIterable {
        case all = "All"
        case lessons = "Lessons"
        case culture = "Culture"
        case grammar = "Grammar"
        case pronunciation = "Pronunciation"
        case conversation = "Conversations"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Category filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(VideoCategory.allCases, id: \.self) { category in
                        CategoryButton(
                            category: category,
                            isSelected: selectedCategory == category,
                            action: { selectedCategory = category }
                        )
                    }
                }
            }

            // Videos list
            VStack(alignment: .leading, spacing: 16) {
                Text("Learning Videos")
                    .font(.headline)

                ForEach(filteredVideos) { video in
                    VideoCard(video: video)
                }
            }
        }
        .onAppear {
            loadVideos()
        }
    }

    private func loadVideos() {
        videos = sampleVideos()
    }

    private var filteredVideos: [LearningVideo] {
        if selectedCategory == .all {
            return videos
        }
        return videos.filter { $0.category == selectedCategory.rawValue }
    }

    private func sampleVideos() -> [LearningVideo] {
        [
            LearningVideo(
                id: "1",
                title: "Spanish Pronunciation Guide",
                description: "Master the sounds of Spanish with native speakers",
                duration: "12:45",
                category: "Pronunciation",
                level: "Beginner",
                thumbnailColor: .blue,
                views: 12500
            ),
            LearningVideo(
                id: "2",
                title: "Ordering Food in a Restaurant",
                description: "Real-life conversation examples",
                duration: "8:30",
                category: "Conversations",
                level: "Intermediate",
                thumbnailColor: .green,
                views: 8900
            ),
            LearningVideo(
                id: "3",
                title: "Past Tense Explained",
                description: "Understand preterite vs imperfect",
                duration: "15:20",
                category: "Grammar",
                level: "Intermediate",
                thumbnailColor: .orange,
                views: 15200
            ),
            LearningVideo(
                id: "4",
                title: "Day of the Dead Traditions",
                description: "Learn about Día de los Muertos",
                duration: "10:15",
                category: "Culture",
                level: "All Levels",
                thumbnailColor: .purple,
                views: 20100
            ),
            LearningVideo(
                id: "5",
                title: "Essential Travel Phrases",
                description: "Everything you need for your trip",
                duration: "18:00",
                category: "Lessons",
                level: "Beginner",
                thumbnailColor: .red,
                views: 25300
            )
        ]
    }
}

struct CategoryButton: View {
    let category: VideosContentView.VideoCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(category.rawValue)
                .font(.subheadline)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.secondarySystemBackground))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(10)
        }
    }
}

struct LearningVideo: Identifiable {
    let id: String
    let title: String
    let description: String
    let duration: String
    let category: String
    let level: String
    let thumbnailColor: Color
    let views: Int
}

struct VideoCard: View {
    let video: LearningVideo
    @State private var showingPlayer = false

    var body: some View {
        Button(action: { showingPlayer = true }) {
            VStack(spacing: 0) {
                // Thumbnail
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [video.thumbnailColor, video.thumbnailColor.opacity(0.7)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(height: 180)

                    VStack {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)

                        Text(video.duration)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(6)
                    }
                }

                // Video info
                VStack(alignment: .leading, spacing: 8) {
                    Text(video.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)

                    Text(video.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)

                    HStack {
                        Label(video.level, systemImage: "chart.bar.fill")
                            .font(.caption2)
                            .foregroundColor(.blue)

                        Spacer()

                        Label("\(formatViews(video.views)) views", systemImage: "eye.fill")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(12)
            }
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
        .sheet(isPresented: $showingPlayer) {
            VideoPlayerView(video: video)
        }
    }

    private func formatViews(_ views: Int) -> String {
        if views >= 1000 {
            return String(format: "%.1fK", Double(views) / 1000.0)
        }
        return "\(views)"
    }
}

struct VideoPlayerView: View {
    let video: LearningVideo
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Video player placeholder
                ZStack {
                    Rectangle()
                        .fill(Color.black)
                        .frame(height: 250)

                    VStack {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)

                        Text("Video player coming soon")
                            .foregroundColor(.white)
                            .font(.caption)
                    }
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Title and stats
                        VStack(alignment: .leading, spacing: 8) {
                            Text(video.title)
                                .font(.title2)
                                .fontWeight(.bold)

                            HStack {
                                Text(video.category)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(6)

                                Text(video.level)
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                Spacer()

                                Text("\(formatViews(video.views)) views")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()

                        Divider()

                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("About")
                                .font(.headline)

                            Text(video.description)
                                .foregroundColor(.secondary)
                        }
                        .padding()

                        // Actions
                        HStack(spacing: 16) {
                            ActionButton(icon: "plus", text: "Save", action: {})
                            ActionButton(icon: "square.and.arrow.up", text: "Share", action: {})
                            ActionButton(icon: "text.bubble", text: "Notes", action: {})
                        }
                        .padding()
                    }
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

    private func formatViews(_ views: Int) -> String {
        if views >= 1000 {
            return String(format: "%.1fK", Double(views) / 1000.0)
        }
        return "\(views)"
    }
}

struct ActionButton: View {
    let icon: String
    let text: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                Text(text)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
        }
    }
}

#Preview {
    VideosContentView()
}
