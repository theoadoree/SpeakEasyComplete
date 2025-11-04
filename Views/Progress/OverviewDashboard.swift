//
//  OverviewDashboard.swift
//  SpeakEasy
//
//  Created by Claude on 2025-11-01.
//

import SwiftUI
import Charts

struct OverviewDashboard: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var analyticsManager: AnalyticsManager
    @State private var selectedTimeRange: TimeRange = .week

    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"

        var days: Int {
            switch self {
            case .week: return 7
            case .month: return 30
            case .year: return 365
            }
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            // Time Range Selector
            Picker("Time Range", selection: $selectedTimeRange) {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(SegmentedPickerStyle())

            // Daily Activity Streak Chart
            DailyStreakChart(
                data: analyticsManager.getDailyActivity(for: selectedTimeRange),
                goal: appState.dailyGoal
            )

            // Vocabulary Growth Curve
            VocabularyGrowthChart(
                data: analyticsManager.getVocabularyGrowth(for: selectedTimeRange)
            )

            // Time Distribution Pie Chart
            TimeDistributionChart(
                data: analyticsManager.getTimeDistribution(for: selectedTimeRange)
            )

            // Accuracy Trend Line
            AccuracyTrendChart(
                data: analyticsManager.getAccuracyTrends(for: selectedTimeRange)
            )

            // Weekly Summary Stats
            WeeklySummaryStats(stats: analyticsManager.getWeeklyStats())
        }
    }
}

struct DailyStreakChart: View {
    let data: [DailyActivityData]
    let goal: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Daily Activity")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()

                if let currentStreak = data.last?.streak {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("\(currentStreak) day streak")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                    }
                }
            }

            if #available(iOS 16.0, *) {
                Chart(data) { day in
                    BarMark(
                        x: .value("Day", day.date, unit: .day),
                        y: .value("Minutes", day.minutes)
                    )
                    .foregroundStyle(gradientForMinutes(day.minutes))
                    .cornerRadius(4)

                    // Goal line
                    RuleMark(y: .value("Goal", goal))
                        .foregroundStyle(.red.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                }
                .frame(height: 180)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { _ in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.weekday(.narrow), centered: true)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            } else {
                Text("Chart requires iOS 16+")
                    .foregroundColor(.secondary)
                    .frame(height: 180)
            }

            // Legend
            HStack(spacing: 16) {
                LegendItem(color: .blue, text: "Minutes studied")
                LegendItem(color: .red, text: "Daily goal: \(goal) min")
            }
            .font(.caption)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    func gradientForMinutes(_ minutes: Int) -> LinearGradient {
        let intensity = min(Double(minutes) / Double(goal * 2), 1.0)
        return LinearGradient(
            gradient: Gradient(colors: [
                Color.blue.opacity(0.4 + intensity * 0.6),
                Color.purple.opacity(0.4 + intensity * 0.6)
            ]),
            startPoint: .bottom,
            endPoint: .top
        )
    }
}

struct VocabularyGrowthChart: View {
    let data: [VocabularyGrowthData]

    var totalWords: Int {
        data.last?.cumulativeWords ?? 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Vocabulary Growth")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()

                Text("\(totalWords) words")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.green.opacity(0.15))
                    .foregroundColor(.green)
                    .cornerRadius(8)
            }

            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(data) { point in
                        LineMark(
                            x: .value("Date", point.date),
                            y: .value("Words", point.cumulativeWords)
                        )
                        .foregroundStyle(Color.blue)
                        .interpolationMethod(.catmullRom)
                        .lineStyle(StrokeStyle(lineWidth: 3))

                        AreaMark(
                            x: .value("Date", point.date),
                            y: .value("Words", point.cumulativeWords)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue.opacity(0.3), .clear]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)
                    }

                    // Milestone markers
                    ForEach(data.filter { $0.isMilestone }) { milestone in
                        PointMark(
                            x: .value("Date", milestone.date),
                            y: .value("Words", milestone.cumulativeWords)
                        )
                        .foregroundStyle(.orange)
                        .symbolSize(100)
                    }
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.month(.abbreviated).day(), centered: true)
                    }
                }
            } else {
                Text("Chart requires iOS 16+")
                    .foregroundColor(.secondary)
                    .frame(height: 200)
            }

            // Status breakdown
            HStack(spacing: 12) {
                StatusBadge(color: .green, label: "New", count: data.last?.newWords ?? 0)
                StatusBadge(color: .orange, label: "Learning", count: data.last?.learningWords ?? 0)
                StatusBadge(color: .blue, label: "Known", count: data.last?.knownWords ?? 0)
                StatusBadge(color: .purple, label: "Mastered", count: data.last?.masteredWords ?? 0)
            }
            .font(.caption)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct TimeDistributionChart: View {
    let data: [TimeDistributionData]

    var totalMinutes: Int {
        data.reduce(0) { $0 + $1.minutes }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Time Distribution")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()

                Text("\(totalMinutes) min total")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 20) {
                // Pie Chart
                if #available(iOS 16.0, *) {
                    Chart(data) { item in
                        SectorMark(
                            angle: .value("Time", item.minutes),
                            innerRadius: .ratio(0.6),
                            angularInset: 2
                        )
                        .foregroundStyle(by: .value("Activity", item.activity))
                        .cornerRadius(4)
                    }
                    .frame(width: 150, height: 150)
                    .chartLegend(.hidden)
                } else {
                    Text("Chart requires iOS 16+")
                        .foregroundColor(.secondary)
                        .frame(width: 150, height: 150)
                }

                // Legend with percentages
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(data) { item in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(colorForActivity(item.activity))
                                .frame(width: 10, height: 10)

                            Text(item.activity)
                                .font(.caption)
                                .frame(minWidth: 80, alignment: .leading)

                            Spacer()

                            Text("\(item.percentage)%")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)

                            Text("(\(item.minutes)m)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    func colorForActivity(_ activity: String) -> Color {
        switch activity {
        case "Conversation": return .blue
        case "Lessons": return .orange
        case "Music": return .purple
        case "Practice": return .green
        case "Review": return .red
        default: return .gray
        }
    }
}

struct AccuracyTrendChart: View {
    let data: [AccuracyData]
    @State private var selectedFilter: FilterType = .all

    enum FilterType: String, CaseIterable {
        case all = "All"
        case conversation = "Conversation"
        case grammar = "Grammar"
        case vocabulary = "Vocabulary"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Accuracy Trends")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()

                Menu {
                    ForEach(FilterType.allCases, id: \.self) { filter in
                        Button(filter.rawValue) {
                            selectedFilter = filter
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(selectedFilter.rawValue)
                            .font(.caption)
                        Image(systemName: "chevron.down")
                            .font(.caption2)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                }
            }

            if #available(iOS 16.0, *) {
                Chart(data) { point in
                    LineMark(
                        x: .value("Day", point.date),
                        y: .value("Accuracy", point.accuracy)
                    )
                    .foregroundStyle(Color.green)
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 2))

                    PointMark(
                        x: .value("Day", point.date),
                        y: .value("Accuracy", point.accuracy)
                    )
                    .foregroundStyle(Color.green)
                    .symbolSize(40)

                    // Average line
                    if let avgAccuracy = data.map({ $0.accuracy }).average {
                        RuleMark(y: .value("Average", avgAccuracy))
                            .foregroundStyle(.gray.opacity(0.5))
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [3]))
                    }
                }
                .frame(height: 150)
                .chartYScale(domain: 0...100)
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if let intValue = value.as(Int.self) {
                                Text("\(intValue)%")
                            }
                        }
                    }
                }
            } else {
                Text("Chart requires iOS 16+")
                    .foregroundColor(.secondary)
                    .frame(height: 150)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct WeeklySummaryStats: View {
    let stats: WeeklyStats

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("This Week's Summary")
                .font(.title2)
                .fontWeight(.bold)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                SummaryStatCard(
                    title: "Total Time",
                    value: "\(stats.totalMinutes) min",
                    icon: "clock.fill",
                    color: .blue
                )

                SummaryStatCard(
                    title: "Words Learned",
                    value: "\(stats.wordsLearned)",
                    icon: "book.fill",
                    color: .green
                )

                SummaryStatCard(
                    title: "Lessons Done",
                    value: "\(stats.lessonsCompleted)",
                    icon: "checkmark.circle.fill",
                    color: .orange
                )

                SummaryStatCard(
                    title: "Reviews",
                    value: "\(stats.reviewsCompleted)",
                    icon: "arrow.triangle.2.circlepath",
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct SummaryStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// Helper Views
struct LegendItem: View {
    let color: Color
    let text: String

    var body: some View {
        HStack(spacing: 6) {
            Rectangle()
                .fill(color)
                .frame(width: 16, height: 3)
                .cornerRadius(1.5)

            Text(text)
                .foregroundColor(.secondary)
        }
    }
}

struct StatusBadge: View {
    let color: Color
    let label: String
    let count: Int

    var body: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            Text("\(count)")
                .font(.caption)
                .fontWeight(.semibold)

            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// Extension for calculating average
extension Array where Element == Int {
    var average: Double? {
        guard !isEmpty else { return nil }
        return Double(reduce(0, +)) / Double(count)
    }
}

#Preview {
    OverviewDashboard()
        .environmentObject(AppState())
        .environmentObject(AnalyticsManager())
}
