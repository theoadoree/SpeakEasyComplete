//
//  SkillsBreakdownView.swift
//  SpeakEasy
//
//  Created by Claude on 2025-11-01.
//

import SwiftUI
import Charts

struct SkillsBreakdownView: View {
    @StateObject private var skillsManager = SkillsManager()

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Skills Radar Chart
            SkillsRadarChart(skills: skillsManager.skillLevels)

            // Individual Skill Details
            VStack(alignment: .leading, spacing: 16) {
                Text("Skill Details")
                    .font(.title2)
                    .fontWeight(.bold)

                ForEach(skillsManager.skillLevels) { skill in
                    SkillDetailRow(skill: skill)
                }
            }

            // Skill Progress Over Time
            SkillProgressChart(data: skillsManager.progressData)

            // Recommendations
            SkillRecommendations(recommendations: skillsManager.recommendations)
        }
        .onAppear {
            skillsManager.loadSkills()
        }
    }
}

struct SkillsRadarChart: View {
    let skills: [SkillLevel]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Skill Balance")
                .font(.title2)
                .fontWeight(.bold)

            ZStack {
                // Radar Chart using Custom Drawing
                GeometryReader { geometry in
                    let center = CGPoint(
                        x: geometry.size.width / 2,
                        y: geometry.size.height / 2
                    )
                    let radius = min(geometry.size.width, geometry.size.height) / 2 - 40

                    ZStack {
                        // Grid circles
                        ForEach(1...5, id: \.self) { level in
                            RadarGridShape(
                                sides: skills.count,
                                radius: radius * CGFloat(level) / 5
                            )
                            .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                        }

                        // Axes
                        ForEach(Array(skills.enumerated()), id: \.offset) { index, skill in
                            let angle = angleForSkill(index, total: skills.count)
                            let endPoint = pointOnCircle(
                                center: center,
                                radius: radius,
                                angle: angle
                            )

                            Path { path in
                                path.move(to: center)
                                path.addLine(to: endPoint)
                            }
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)

                            // Skill labels
                            Text(skill.name)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .position(
                                    pointOnCircle(
                                        center: center,
                                        radius: radius + 25,
                                        angle: angle
                                    )
                                )
                        }

                        // Skill values polygon
                        RadarDataShape(
                            skills: skills,
                            center: center,
                            radius: radius
                        )
                        .fill(Color.blue.opacity(0.2))
                        .overlay(
                            RadarDataShape(
                                skills: skills,
                                center: center,
                                radius: radius
                            )
                            .stroke(Color.blue, lineWidth: 3)
                        )

                        // Points
                        ForEach(Array(skills.enumerated()), id: \.offset) { index, skill in
                            let angle = angleForSkill(index, total: skills.count)
                            let point = pointOnCircle(
                                center: center,
                                radius: radius * CGFloat(skill.level) / 100,
                                angle: angle
                            )

                            Circle()
                                .fill(Color.blue)
                                .frame(width: 8, height: 8)
                                .position(point)
                        }
                    }
                }
                .frame(height: 280)
            }

            // Average Score
            HStack {
                Spacer()
                VStack(spacing: 4) {
                    Text("Overall Level")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("\(skills.map { $0.level }.reduce(0, +) / max(skills.count, 1))%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    func angleForSkill(_ index: Int, total: Int) -> Double {
        return Double(index) * (360.0 / Double(total)) - 90
    }

    func pointOnCircle(center: CGPoint, radius: CGFloat, angle: Double) -> CGPoint {
        let angleInRadians = angle * .pi / 180
        return CGPoint(
            x: center.x + radius * cos(angleInRadians),
            y: center.y + radius * sin(angleInRadians)
        )
    }
}

struct RadarGridShape: Shape {
    let sides: Int
    let radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()

        for i in 0..<sides {
            let angle = (Double(i) * 360.0 / Double(sides) - 90) * .pi / 180
            let point = CGPoint(
                x: center.x + radius * cos(angle),
                y: center.y + radius * sin(angle)
            )

            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }

        path.closeSubpath()
        return path
    }
}

struct RadarDataShape: Shape {
    let skills: [SkillLevel]
    let center: CGPoint
    let radius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()

        for (index, skill) in skills.enumerated() {
            let angle = (Double(index) * 360.0 / Double(skills.count) - 90) * .pi / 180
            let distance = radius * CGFloat(skill.level) / 100
            let point = CGPoint(
                x: center.x + distance * cos(angle),
                y: center.y + distance * sin(angle)
            )

            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }

        path.closeSubpath()
        return path
    }
}

struct SkillDetailRow: View {
    let skill: SkillLevel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: skill.icon)
                    .font(.title3)
                    .foregroundColor(skill.color)
                    .frame(width: 30)

                Text(skill.name)
                    .font(.headline)

                Spacer()

                Text("\(skill.level)%")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(skill.color)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)

                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [skill.color.opacity(0.6), skill.color]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(skill.level) / 100, height: 8)
                }
                .cornerRadius(4)
            }
            .frame(height: 8)

            Text(skill.description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
    }
}

struct SkillProgressChart: View {
    let data: [SkillProgressData]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Skill Growth Over Time")
                .font(.title2)
                .fontWeight(.bold)

            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(data) { point in
                        LineMark(
                            x: .value("Date", point.date),
                            y: .value("Level", point.averageLevel)
                        )
                        .foregroundStyle(Color.blue)
                        .interpolationMethod(.catmullRom)
                        .lineStyle(StrokeStyle(lineWidth: 2))

                        PointMark(
                            x: .value("Date", point.date),
                            y: .value("Level", point.averageLevel)
                        )
                        .foregroundStyle(Color.blue)
                    }
                }
                .frame(height: 150)
                .chartYScale(domain: 0...100)
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.month(.abbreviated))
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
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

struct SkillRecommendations: View {
    let recommendations: [SkillRecommendation]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recommendations")
                .font(.title2)
                .fontWeight(.bold)

            ForEach(recommendations) { recommendation in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: recommendation.icon)
                        .font(.title3)
                        .foregroundColor(recommendation.priority == .high ? .red : .orange)
                        .frame(width: 30)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(recommendation.title)
                            .font(.headline)

                        Text(recommendation.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
    }
}

#Preview {
    SkillsBreakdownView()
}
