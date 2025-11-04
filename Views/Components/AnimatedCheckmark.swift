import SwiftUI

struct AnimatedCheckmark: View {
    @State private var animateStroke = false
    @State private var animateCircle = false

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.green.opacity(0.3), lineWidth: 4)
                .frame(width: 100, height: 100)

            // Animated circle
            Circle()
                .trim(from: 0, to: animateCircle ? 1 : 0)
                .stroke(Color.green, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .frame(width: 100, height: 100)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.6), value: animateCircle)

            // Checkmark
            Path { path in
                path.move(to: CGPoint(x: 30, y: 50))
                path.addLine(to: CGPoint(x: 45, y: 65))
                path.addLine(to: CGPoint(x: 70, y: 35))
            }
            .trim(from: 0, to: animateStroke ? 1 : 0)
            .stroke(Color.green, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
            .animation(.easeInOut(duration: 0.4).delay(0.3), value: animateStroke)
        }
        .onAppear {
            animateCircle = true
            animateStroke = true
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        AnimatedCheckmark()
            .frame(width: 100, height: 100)

        Text("Success!")
            .font(.title)
            .fontWeight(.bold)
    }
    .padding()
}
