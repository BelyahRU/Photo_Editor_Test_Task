
import SwiftUI
import PencilKit

//MARK: - The main view in the application, collects image(filter + draw + text + image)
struct ImageDrawingView: View {
    // MARK: - Inputs
    var image: UIImage
    var canvasView: PKCanvasView
    var toolPicker: PKToolPicker
    var isDrawingEnabled: Bool
    var scale: CGFloat
    var rotation: Angle
    var offset: CGSize
    var viewModel: PhotoEditorViewModel
    var onOffsetChange: (CGSize) -> Void

    @Binding var texts: [TextElement]

    var body: some View {
        GeometryReader { geo in
            let containerSize = geo.size
            let imageSize = image.size

            // Calculates how the image should scale inside container
            let scaleFactor = min(
                containerSize.width / imageSize.width,
                containerSize.height / imageSize.height
            )

            let displaySize = CGSize(
                width: imageSize.width * scaleFactor * scale,
                height: imageSize.height * scaleFactor * scale
            )

            let imageOrigin = CGPoint(
                x: (containerSize.width - displaySize.width) / 2,
                y: (containerSize.height - displaySize.height) / 2
            )

            ZStack {
                // Base image frame
                DrawingFrame {
                    Color.clear
                        .frame(width: displaySize.width, height: displaySize.height)
                }
                .overlay {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: displaySize.width, height: displaySize.height)
                }

                // Drawing overlay
                DrawingFrame {
                    CanvasViewRepresentable(
                        canvasView: .constant(canvasView),
                        toolPicker: .constant(toolPicker),
                        isDrawingEnabled: isDrawingEnabled,
                        scale: scale
                    )
                    .frame(width: displaySize.width, height: displaySize.height)
                    .zIndex(10)
                }

                // Text overlays
                ForEach($texts) { $text in
                    textView(for: $text, in: imageOrigin)
                }
            }
            .offset(offset)
            .simultaneousGesture(
                dragToPanGesture(enabled: !isDrawingEnabled && !viewModel.isDraggingTextNow),
                including: .all
            )
            .rotationEffect(rotation)
            .frame(maxWidth: .infinity, maxHeight: 350, alignment: .center)
            .clipped()
        }
        .frame(height: 350)
    }
}


private extension ImageDrawingView {
    // Builds the text overlay view with drag and double tap edit
    @ViewBuilder
    func textView(for text: Binding<TextElement>, in imageOrigin: CGPoint) -> some View {
        let displayX = text.wrappedValue.position.width * scale
        let displayY = text.wrappedValue.position.height * scale

        Text(text.wrappedValue.text)
            .font(.custom(text.wrappedValue.fontName, size: text.wrappedValue.fontSize * scale))
            .foregroundColor(text.wrappedValue.color)
            .padding(4)
            .background(Color.black.opacity(0.3))
            .cornerRadius(6)
            .position(x: imageOrigin.x + displayX, y: imageOrigin.y + displayY)
            .zIndex(1000)
            .gesture(editGesture(for: text.wrappedValue))
            .gesture(dragGesture(for: text, origin: imageOrigin))
    }

    // Double-tap to edit text
    func editGesture(for text: TextElement) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                viewModel.editingTextID = text.id
                viewModel.addedText = text.text
                viewModel.textColor = text.color
                viewModel.textFontSize = text.fontSize
                viewModel.textFontName = text.fontName
                viewModel.textPosition = text.position
                viewModel.isTextEditing = true
            }
    }

    // Drag gesture for text repositioning
    func dragGesture(for text: Binding<TextElement>, origin: CGPoint) -> some Gesture {
        DragGesture()
            .onChanged { value in
                let relativeX = value.location.x - origin.x
                let relativeY = value.location.y - origin.y
                text.wrappedValue.position = CGSize(width: relativeX, height: relativeY)
                viewModel.isDraggingTextNow = true
            }
            .onEnded { value in
                let relativeX = value.location.x - origin.x
                let relativeY = value.location.y - origin.y
                text.wrappedValue.position = CGSize(width: relativeX, height: relativeY)
                viewModel.isDraggingTextNow = false
            }
    }

    // Drag gesture to move the entire image
    func dragToPanGesture(enabled: Bool) -> some Gesture {
        DragGesture()
            .onChanged { value in
                if enabled {
                    onOffsetChange(value.translation)
                }
            }
            .onEnded { value in
                if enabled {
                    onOffsetChange(value.translation)
                }
            }
    }
}
