import SwiftUI

@available(iOS 15.0, macOS 12.0, *)
public struct MouthView: View {
    var level: CGFloat // 0…1
    
    public init(level: CGFloat) {
        self.level = level
    }
    
    public var body: some View {
        let heightClosed: CGFloat = 6
        let heightOpen: CGFloat = 42
        let mouthHeight = heightClosed + (heightOpen - heightClosed) * level

        Capsule()
            .frame(width: 90, height: mouthHeight)
            .overlay(Capsule().stroke(.black.opacity(0.15), lineWidth: 1))
            .animation(.easeOut(duration: 0.06), value: mouthHeight)
    }
}

@available(iOS 15.0, macOS 12.0, *)
public struct TalkingTeacherView: View {
    @ObservedObject public var meter: AudioLevelMonitor
    
    public init(meter: AudioLevelMonitor) {
        self.meter = meter
    }
    
    public var body: some View {
        ZStack {
            Image("teacher_base") // your PNG without the mouth printed on it
                .resizable().scaledToFit()
            MouthView(level: meter.level)
                .offset(x: 0, y: 18)
                .clipShape(MouthMask())    // confines to lip area
        }
        .drawingGroup()
    }
}
