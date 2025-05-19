
import SwiftUI
import PencilKit

//MARK: UserImageView displays an image or message how to add it
struct UserImageView: View {
    @State private var toolPicker = PKToolPicker()
    
    @ObservedObject var viewModel: PhotoEditorViewModel
    
    var body: some View {
        Group {
            //MARK: - Image
            if let image = viewModel.selectedImage {
                ImageDrawingView(
                    image: image,
                    canvasView: viewModel.canvasView,
                    toolPicker: toolPicker,
                    isDrawingEnabled: viewModel.isDrawing,
                    scale: viewModel.scale,
                    rotation: viewModel.rotation,
                    offset: viewModel.imageOffset,
                    viewModel: viewModel,
                    onOffsetChange: { newOffset in
                        viewModel.imageOffset = newOffset
                    },
                    texts: $viewModel.texts
                )
            //MARK: - Message
            } else {
                if !viewModel.isSourceSelectorPresented {
                    VStack(spacing: 12) {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                            .foregroundStyle(.blue)
                        Text("Select image by pressing the photo icon above")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
    }
}
