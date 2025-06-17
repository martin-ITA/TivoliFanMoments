import SwiftUI

struct ZoomableView<Content: View>: View {
    let content: Content
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .scaleEffect(scale)
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        scale = max(1, lastScale * value)
                    }
                    .onEnded { _ in
                        lastScale = max(1, scale)
                    }
            )
    }
}
