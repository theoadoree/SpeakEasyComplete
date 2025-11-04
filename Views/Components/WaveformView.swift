import SwiftUI

/// Audio waveform visualization
/// Displays animated bars representing audio levels
struct WaveformView: View {
    let level: Float

    var body: some View {
        GeometryReader { geo in
            let bars = 24
            let w = geo.size.width / CGFloat(bars)
            HStack(spacing: 2) {
                ForEach(0..<bars, id: \.self) { i in
                    let falloff = 1 - CGFloat(i) / CGFloat(bars)
                    let h = max(2, CGFloat(level) * geo.size.height * falloff)
                    RoundedRectangle(cornerRadius: 2)
                        .frame(width: w - 2, height: h)
                        .foregroundStyle(.accent.opacity(0.85))
                        .frame(maxHeight: .infinity, alignment: .center)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .background(Color.secondary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    VStack(spacing: 20) {
        WaveformView(level: 0.3)
            .frame(height: 60)

        WaveformView(level: 0.7)
            .frame(height: 60)

        WaveformView(level: 1.0)
            .frame(height: 60)
    }
    .padding()
}
