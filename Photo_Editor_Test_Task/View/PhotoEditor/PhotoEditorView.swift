

import SwiftUI
import PencilKit

struct PhotoEditorView: View {
    
    
    @StateObject private var viewModel = PhotoEditorViewModel()
    @State private var canvasView = PKCanvasView()
    @State private var toolPicker = PKToolPicker()
    @State private var showLogoutAlert = false

    
    var body: some View {
        ZStack {
            VStack {
                userImage

                scaleAndRotationSettings
            }
            .navigationBarTitle("Photo Editor")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            showLogoutAlert = true
                            
                        }) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .imageScale(.large)
                                .foregroundStyle(.red)
                        }
                    }
                
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        withAnimation {
                            viewModel.isSourceSelectorPresented = true
                        }
                    }) {
                        Image(systemName: "photo")
                            .imageScale(.large)
                    }
                }
            }
            .fullScreenCover(isPresented: Binding(get: {
                    viewModel.isPickerPresented && viewModel.pickerSource == .photoLibrary
                }, set: { newValue in
                    viewModel.isPickerPresented = newValue
                })) {
                    ImagePicker(sourceType: .photoLibrary) { image in
                        viewModel.selectedImage = image
                    }
                    .edgesIgnoringSafeArea(.all)
                }
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
            .alert("Are you sure you want to log out?", isPresented: $showLogoutAlert) {
                Button("Log Out", role: .destructive) {
                    viewModel.logOut()
                }
                Button("Cancel", role: .cancel) { }
            }

            // Здесь добавляем наше кастомное меню
            if viewModel.isSourceSelectorPresented {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                BottomSourceSelectorView(
                    onSelectGallery: {
                        viewModel.openPicker(source: .photoLibrary)
                        withAnimation {
                            viewModel.isSourceSelectorPresented = false
                        }
                    },
                    onSelectCamera: {
                        viewModel.openPicker(source: .camera)
                        withAnimation {
                            viewModel.isSourceSelectorPresented = false
                        }
                    },
                    onClose: {
                        withAnimation {
                            viewModel.isSourceSelectorPresented = false
                        }
                    }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))

            }
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarBackButtonHidden(true)
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
    
    var scaleAndRotationSettings: some View {
        Group {
            if viewModel.selectedImage != nil {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Scale")
                    
                    Slider(value: $viewModel.scale, in: 0.5...3.0) {}
                }
                .padding(.horizontal, 20)

                VStack(alignment: .leading, spacing: 3) {
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

