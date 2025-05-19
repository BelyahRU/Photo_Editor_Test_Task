
import SwiftUI
import PencilKit

struct PhotoEditorView: View {
    
    @StateObject private var viewModel = PhotoEditorViewModel()
    @State private var isFilterSelectorPresented = false
    
    
    var body: some View {
        ZStack {
            VStack {
                UserImageView(viewModel: viewModel)

                ScaleAndRotationSettingsView(viewModel: viewModel)
            }
            .navigationBarTitle("Photo Editor")
            .toolbar {
                ToolbarView(
                    isExportMenuPresented: $viewModel.isExportMenuPresented,
                    isTextEditing: $viewModel.isTextEditing,
                    isFilterSelectorPresented: $isFilterSelectorPresented,
                    isSourceSelectorPresented: $viewModel.isSourceSelectorPresented,
                    showLogoutAlert: $viewModel.showLogoutAlert,
                    isDrawing: $viewModel.isDrawing
                )
            }
            .fullScreenCover(isPresented: $viewModel.isPickerPresented) {
                Group {
                    switch viewModel.pickerSource {
                    case .photoLibrary:
                        ImagePicker(sourceType: .photoLibrary) { image in
                            viewModel.selectedImage = image
                        }

                    case .camera:
                        ImagePicker(sourceType: .camera) { image in
                            viewModel.selectedImage = image
                        }
                    default:
                        EmptyView()
                    }
                }
                .edgesIgnoringSafeArea(.all)
            }
            .alert("Are you sure you want to log out?", isPresented: $viewModel.showLogoutAlert) {
                Button("Log Out", role: .destructive) {
                    viewModel.logOut()
                }
                Button("Cancel", role: .cancel) { }
            }


            sourceModalView
            filtersModalView
            textEditorModalView
            exportModalView
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarBackButtonHidden(true)
    }
}

private extension PhotoEditorView {
    
    //MARK: - FilterSelectorView
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
    
    //MARK: - SourceSelectorModalView
    var sourceModalView: some View {
        Group {
            if viewModel.isSourceSelectorPresented {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                SourceSelectorModalView(
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
    
    //MARK: - TextEditorModalView
    var textEditorModalView: some View {
        TextEditorModalView(
            selectedImage: viewModel.selectedImage,
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
    
    //MARK: - ExportMenuView
    var exportModalView: some View {
        Group {
            if viewModel.isExportMenuPresented {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                ExportMenuView(
                    onSaveToPhotos: {
                        if let image = viewModel.renderEditedImage(
                            canvasView: viewModel.canvasView,
                            imageSize: viewModel.imageSize,
                            scale: viewModel.scale
                        ) {
                            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                        }
                    },
                    onExport: { format in
                        if let image = viewModel.renderEditedImage(
                            canvasView: viewModel.canvasView,
                            imageSize: viewModel.imageSize,
                            scale: viewModel.scale
                        ) {
                            let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let rootVC = windowScene.windows.first?.rootViewController {
                                rootVC.present(activityVC, animated: true)
                            }
                        }
                    },
                    onClose: {
                        viewModel.isExportMenuPresented = false
                    }
                )
            } else {
                EmptyView()
            }
        }
    }


}

