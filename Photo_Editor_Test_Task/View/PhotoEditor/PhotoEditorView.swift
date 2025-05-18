
import SwiftUI
import PencilKit

struct PhotoEditorView: View {
    @StateObject private var viewModel = PhotoEditorViewModel()
    @State private var canvasView = PKCanvasView()
    @State private var toolPicker = PKToolPicker()
    
    var body: some View {
        VStack {
            userImage
            
            sourceButtons
            
            scaleAndRotationSettings
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarTitle("Photo Editor", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    withAnimation {
                        viewModel.isDrawing.toggle()
                    }
                }) {
                    Image(systemName: viewModel.isDrawing ? "pencil.circle.fill" : "pencil")
                        .imageScale(.large)
                }
            }
        }
        // Sheet for Gallery
        .sheet(isPresented: Binding(get: {
                    viewModel.isPickerPresented && viewModel.pickerSource == .photoLibrary
                }, set: { newValue in
                    viewModel.isPickerPresented = newValue
                })) {
                    ImagePicker(sourceType: .photoLibrary) { image in
                        viewModel.selectedImage = image
                    }
                }
        // Fullscreen cover for Camera
        .fullScreenCover(isPresented: Binding(get: {
            viewModel.isPickerPresented && viewModel.pickerSource == .camera
        }, set: { newValue in
            viewModel.isPickerPresented = newValue
        })) {
            ImagePicker(sourceType: .camera) { image in
                viewModel.selectedImage = image
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}



private extension PhotoEditorView {
    
    var userImage: some View {
        Group {
            if let image = viewModel.selectedImage {
                ImageDrawingView(
                    image: image,
                    canvasView: canvasView,
                    toolPicker: toolPicker,
                    isDrawingEnabled: viewModel.isDrawing,
                    scale: viewModel.scale,
                    rotation: viewModel.rotation,
                    offset: viewModel.imageOffset,
                    onOffsetChange: { newOffset in
                        viewModel.imageOffset = newOffset
                    }
                )
            } else {
                Text("Select Image")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
    }


    
    var sourceButtons: some View {
        VStack {
            Button("Take a photo") {
                viewModel.openPicker(source: .camera)
            }
            Button("Photo from gallery") {
                viewModel.openPicker(source: .photoLibrary)
            }
        }
    }
    
    var scaleAndRotationSettings: some View {
        Group {
            if viewModel.selectedImage != nil {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Scale")
                    
                    Slider(value: $viewModel.scale, in: 0.5...3.0) {}
                }
                .padding(.horizontal, 20)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Rotation")
                    
                    Slider(value: Binding(
                        get: { viewModel.rotation.degrees },
                        set: { viewModel.rotation = .degrees($0) }
                    ), in: -180...180) {}
                }
                .padding(.horizontal, 20)

                HStack {
                    Button("Reset") {
                        viewModel.resetEdits()
                    }

                }
                .padding()
            }
        }
    }
}


