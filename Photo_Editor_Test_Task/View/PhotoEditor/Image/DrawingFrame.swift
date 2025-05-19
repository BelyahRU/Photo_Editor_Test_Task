
import SwiftUI

//MARK: - DrawingFrame is structure that creates the blue frame in the image
struct DrawingFrame<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .clipShape(Rectangle())
            .overlay(
                Rectangle()
                    .stroke(Color.accentColor, lineWidth: 3)
            )
            .contentShape(Rectangle())
    }
}
