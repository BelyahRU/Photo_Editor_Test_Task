
import SwiftUI
import PencilKit

struct TextElement: Identifiable {
    let id = UUID()
    var text: String
    var fontName: String
    var fontSize: CGFloat
    var color: Color
    var position: CGSize
}

struct PhotoEditorView: View {
    
    @StateObject private var viewModel = PhotoEditorViewModel()
    @State private var canvasView = PKCanvasView()
    @State private var toolPicker = PKToolPicker()
    @State private var showLogoutAlert = false
    @State private var isFilterSelectorPresented = false
    
    
    var body: some View {
        ZStack {
            VStack {
                userImage

                scaleAndRotationSettings
            }
            .navigationBarTitle("Photo Editor")
            .toolbar {
                photoEditorToolbar
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


            sourceModalView
            filtersModalView
            textEditorModalView




        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarBackButtonHidden(true)
    }
}



private extension PhotoEditorView {
    
    //MARK: - Image from gallery or camera
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
                    viewModel: viewModel,
                    onOffsetChange: { newOffset in
                        viewModel.imageOffset = newOffset
                    },
                    texts: $viewModel.texts // ← вот это важно!
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
    
    //MARK: - Sliders(Scale and Rotation)
    var scaleSlider: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("Scale")
            
            Slider(value: $viewModel.scale, in: 0.5...3.0) {}
        }
        .padding(.horizontal, 20)
    }
    
    var rotationSlider: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("Rotation")
            
            Slider(value: Binding(
                get: { viewModel.rotation.degrees },
                set: { viewModel.rotation = .degrees($0) }
            ), in: -180...180) {}
        }
        .padding(.horizontal, 20)
    }
    
    var scaleAndRotationSettings: some View {
        Group {
            if viewModel.selectedImage != nil {
                scaleSlider
                rotationSlider
                HStack {
                    Button("Reset") {
                        viewModel.resetEdits()
                    }

                }
                .padding()
            }
        }
    }
    
    var filtersModalView: some View {
        Group {
            if isFilterSelectorPresented {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                FilterSelectorView(
                    filters: viewModel.availableFilters,
                    onSelectFilter: { filter in
                        viewModel.applyFilter(filter)
                    },
                    onClose: {
                        withAnimation {
                            isFilterSelectorPresented = false
                        }
                    }
                )
            }
        }
    }
    
    //MARK: Adding image(Camera or Gallery)
    var sourceModalView: some View {
        Group {
            if viewModel.isSourceSelectorPresented {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                SourceSelectorView(
                    // Gallery
                    onSelectGallery: {
                        viewModel.openPicker(source: .photoLibrary)
                        withAnimation {
                            viewModel.isSourceSelectorPresented = false
                        }
                    },
                    // Camera
                    onSelectCamera: {
                        viewModel.openPicker(source: .camera)
                        withAnimation {
                            viewModel.isSourceSelectorPresented = false
                        }
                    },
                    // Dismiss
                    onClose: {
                        withAnimation {
                            viewModel.isSourceSelectorPresented = false
                        }
                    }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))

            }
        }
    }
    
    
    //MARK: - ToolBar Content
    @ToolbarContentBuilder
    var photoEditorToolbar: some ToolbarContent {
        // Левая кнопка — Log Out
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: {
                showLogoutAlert = true
            }) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .imageScale(.large)
                    .foregroundStyle(.red)
            }
        }

        // Правая группа кнопок — Pencil и Photo
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button {
                withAnimation {
                    viewModel.isTextEditing.toggle()
                }
            } label: {
                Image(systemName: "textformat")
                    .imageScale(.large)
            }
            
            Button(action: {
                withAnimation {
                    isFilterSelectorPresented = true
                }
            }) {
                Image(systemName: "wand.and.stars")
                    .imageScale(.large)
            }


            Button(action: {
                withAnimation {
                    viewModel.isDrawing.toggle()
                }
            }) {
                Image(systemName: viewModel.isDrawing ? "pencil.circle.fill" : "pencil")
                    .imageScale(.large)
            }

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
    
    
    //MARK: - TextEditor
    var textEditorModalView: some View {
        TextEditorModalView(
            isPresented: $viewModel.isTextEditing,
            addedText: $viewModel.addedText,
            textColor: $viewModel.textColor,
            textFontSize: $viewModel.textFontSize,
            textFontName: $viewModel.textFontName,
            textPosition: $viewModel.textPosition,
            editingTextID: $viewModel.editingTextID,
            texts: $viewModel.texts
        )
    }

    func resetTextEditor() {
        viewModel.addedText = ""
        viewModel.textColor = .white
        viewModel.textFontSize = 24
        viewModel.textFontName = "HelveticaNeue"
        viewModel.textPosition = .zero
        viewModel.isTextEditing = false
        viewModel.editingTextID = nil
    }

}
