import SwiftUI
import PencilKit

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
                DrawingFrame {
                    Color.clear
                        .frame(width: displaySize.width, height: displaySize.height)
                }
                .overlay {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: displaySize.width, height: displaySize.height)
                }

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

                ForEach($texts) { $text in
                    let displayX = text.position.width * scale
                    let displayY = text.position.height * scale

                    Text(text.text)
                        .font(.custom(text.fontName, size: text.fontSize * scale))
                        .foregroundColor(text.color)
                        .padding(4)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(6)
                        .position(x: imageOrigin.x + displayX, y: imageOrigin.y + displayY)
                        .zIndex(1000)
                        .gesture(
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
                        )
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let relativeX = (value.location.x - imageOrigin.x)
                                    let relativeY = (value.location.y - imageOrigin.y)

                                    text.position = CGSize(width: relativeX, height: relativeY)
                                    viewModel.isDraggingTextNow = true
                                }
                                .onEnded { value in
                                    let relativeX = (value.location.x - imageOrigin.x)
                                    let relativeY = (value.location.y - imageOrigin.y)

                                    text.position = CGSize(width: relativeX, height: relativeY)
                                    viewModel.isDraggingTextNow = false
                                }
                        )
                }
            }
            .offset(offset)
            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        if !isDrawingEnabled && !viewModel.isDraggingTextNow {
                            onOffsetChange(value.translation)
                        }
                    }
                    .onEnded { value in
                        if !isDrawingEnabled && !viewModel.isDraggingTextNow {
                            onOffsetChange(value.translation)
                        }
                    },
                including: .all
            )
            .rotationEffect(rotation)
            .frame(maxWidth: .infinity, maxHeight: 350, alignment: .center)
            .clipped()
        }
        .frame(height: 350)
    }
}
