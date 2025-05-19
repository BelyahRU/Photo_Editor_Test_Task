
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

extension PhotoEditorViewModel {
    /// Фактический размер, в котором отображается изображение на экране
    var displayedImageSize: CGSize {
        guard let selectedImage = selectedImage else { return .zero }
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight: CGFloat = 350 // фиксированная высота, как в ImageDrawingView

        let scaleFactor = min(
            screenWidth / selectedImage.size.width,
            screenHeight / selectedImage.size.height
        )

        return CGSize(
            width: selectedImage.size.width * scaleFactor * scale,
            height: selectedImage.size.height * scaleFactor * scale
        )
    }

    func renderEditedImage(canvasView: PKCanvasView, imageSize: CGSize, scale: CGFloat) -> UIImage? {
        guard let baseImage = selectedImage else { return nil }

        let outputSize = CGSize(width: baseImage.size.width * scale, height: baseImage.size.height * scale)
        let displayHeight: CGFloat = 350
        let screenWidth = UIScreen.main.bounds.width

        let scaleFactor = min(screenWidth / baseImage.size.width, displayHeight / baseImage.size.height)

        let displaySize = CGSize(
            width: baseImage.size.width * scaleFactor * scale,
            height: baseImage.size.height * scaleFactor * scale
        )

        let ratioX = outputSize.width / displaySize.width
        let ratioY = outputSize.height / displaySize.height

        let renderer = UIGraphicsImageRenderer(size: outputSize)
        return renderer.image { context in
            let cgContext = context.cgContext
            cgContext.saveGState()

            baseImage.draw(in: CGRect(origin: .zero, size: outputSize))

            let canvasImage = canvasView.drawing.image(from: canvasView.bounds, scale: 1.0)
            canvasImage.draw(in: CGRect(origin: .zero, size: outputSize))

            for text in texts {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center

                let scaledFontSize = text.fontSize * ratioY
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont(name: text.fontName, size: scaledFontSize) ?? UIFont.systemFont(ofSize: scaledFontSize),
                    .foregroundColor: UIColor(text.color),
                    .paragraphStyle: paragraphStyle
                ]

                let attributedString = NSAttributedString(string: text.text, attributes: attributes)
                let textSize = attributedString.size()

                let drawRect = CGRect(
                    origin: CGPoint(
                        x: text.position.width * ratioX - textSize.width / 2,
                        y: text.position.height * ratioY - textSize.height / 2
                    ),
                    size: textSize
                )

                print("drawRect:", drawRect)
                attributedString.draw(in: drawRect)
            }

            cgContext.restoreGState()
        }
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

