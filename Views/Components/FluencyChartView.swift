import SwiftUI
import Charts

struct FluencyChartView: View {
    let metrics: FluencyMetrics

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Fluency Analysis")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)

            // Chart displaying key fluency metrics
            Chart {
                BarMark(
                    x: .value("Metric", "WPM"),
                    y: .value("Score", normalizedWPM)
                )
                .foregroundStyle(Color(hex: "007AFF"))
                .cornerRadius(8)

                BarMark(
                    x: .value("Metric", "Pronunciation"),
                    y: .value("Score", metrics.pronunciationAccuracy)
                )
                .foregroundStyle(Color(hex: "34C759"))
                .cornerRadius(8)

                BarMark(
                    x: .value("Metric", "Naturalness"),
                    y: .value("Score", metrics.naturalness)
                )
                .foregroundStyle(Color(hex: "FF9500"))
                .cornerRadius(8)

                BarMark(
                    x: .value("Metric", "Confidence"),
                    y: .value("Score", metrics.confidenceScore)
                )
                .foregroundStyle(Color(hex: "AF52DE"))
                .cornerRadius(8)
            }
            .chartYScale(domain: 0...10)
            .chartYAxis {
                AxisMarks(position: .leading, values: [0, 2.5, 5, 7.5, 10])
            }
            .frame(height: 200)
            .padding(.vertical, 8)

            // Legend
            HStack(spacing: 20) {
                LegendItem(color: Color(hex: "007AFF"), label: "Speaking Speed")
                LegendItem(color: Color(hex: "34C759"), label: "Pronunciation")
                LegendItem(color: Color(hex: "FF9500"), label: "Naturalness")
                LegendItem(color: Color(hex: "AF52DE"), label: "Confidence")
            }
            .font(.system(size: 12))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }

    // Normalize WPM to 0-10 scale (assuming 150 WPM is optimal = 10)
    private var normalizedWPM: Double {
        let optimalWPM = 150.0
        let normalized = (Double(metrics.wordsPerMinute) / optimalWPM) * 10.0
        return min(normalized, 10.0)
    }
}

struct LegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            Text(label)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    FluencyChartView(
        metrics: FluencyMetrics(
            wordsPerMinute: 120,
            pauseFrequency: 3,
            averagePauseDuration: 0.5,
            fillerWordUsage: 2,
            sentenceComplexity: 7,
            vocabularyDiversity: 8,
            pronunciationAccuracy: 8.5,
            intonationScore: 7.5,
            rhythmScore: 8.0,
            confidenceScore: 7.8,
            naturalness: 8.2,
            responseTime: 1.5,
            continuousSpeechDuration: 45.0
        )
    )
    .padding()
}
