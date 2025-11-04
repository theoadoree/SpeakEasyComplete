//
//  LearnView.swift
//  SpeakEasy
//
//  Created by Claude on 2025-11-01.
//

import SwiftUI

struct LearnView: View {
    @State private var selectedCategory: ContentCategory = .lessons
    @State private var searchText = ""
    @State private var showingMusicConnect = false
    @EnvironmentObject var appState: AppState

    enum ContentCategory: String, CaseIterable {
        case lessons = "Lessons"
        case stories = "Stories"
        case music = "Music"
        case videos = "Videos"
        case grammar = "Grammar"
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)

                    TextField("Search content...", text: $searchText)

                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(10)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                .padding()

                // Category Filter (Horizontal Scroll)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(ContentCategory.allCases, id: \.self) { category in
                            CategoryChip(
                                category: category,
                                isSelected: selectedCategory == category,
                                action: { selectedCategory = category }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 10)

                // Content Area
                ScrollView {
                    Group {
                        switch selectedCategory {
                        case .lessons:
                            LessonsContentView()
                        case .stories:
                            StoriesContentView()
                        case .music:
                            MusicContentView(showingConnect: $showingMusicConnect)
                        case .videos:
                            VideosContentView()
                        case .grammar:
                            GrammarReferenceView()
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Learn")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingMusicConnect) {
                MusicServiceConnectView()
            }
        }
    }
}

struct CategoryChip: View {
    let category: LearnView.ContentCategory
    let isSelected: Bool
    let action: () -> Void

    var icon: String {
        switch category {
        case .lessons: return "graduationcap.fill"
        case .stories: return "book.fill"
        case .music: return "music.note"
        case .videos: return "play.rectangle.fill"
        case .grammar: return "textformat"
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(category.rawValue)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color(.secondarySystemBackground))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

#Preview {
    LearnView()
        .environmentObject(AppState())
}
