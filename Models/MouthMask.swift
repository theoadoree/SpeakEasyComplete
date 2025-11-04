import SwiftUI

@available(iOS 15.0, macOS 12.0, *)
public struct MouthMask: Shape {
    public init() {}
    
    public func path(in rect: CGRect) -> Path {
        Path(roundedRect: CGRect(x: rect.midX-55, y: rect.midY+5, width: 110, height: 60),
             cornerSize: .init(width: 28, height: 28))
    }
}
