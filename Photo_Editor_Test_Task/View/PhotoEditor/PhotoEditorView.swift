
import SwiftUI

struct PhotoEditorView: View {
    @StateObject private var viewModel = PhotoEditorViewModel()
    
    var body: some View {
        VStack {
            userImage
            
            sourceButtons
            
            scaleAndRotationSettings
        }
        .navigationTitle("Photo Editor")
        .edgesIgnoringSafeArea(.all)
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
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(viewModel.scale) // масштаб
                    .rotationEffect(viewModel.rotation) // поворот
                    .frame(maxHeight: 400)
                    .padding()
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

                Button("Reset") {
                    viewModel.resetEdits()
                }
                .padding()
            }
        }
    }
}
