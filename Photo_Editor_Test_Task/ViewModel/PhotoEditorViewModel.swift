
import SwiftUI
import FirebaseAuth
import CoreImage
import CoreImage.CIFilterBuiltins
import PencilKit
import Combine

final class PhotoEditorViewModel: ObservableObject {
    // MARK: - Image State
    @Published var selectedImage: UIImage?
    @Published var scale: CGFloat = 1.0
    @Published var rotation: Angle = .zero
    @Published var imageOffset: CGSize = .zero
    
    @Published private(set) var imageSize: CGSize = .zero
    private var cancellables = Set<AnyCancellable>()

    init() {
        $selectedImage
            .compactMap { $0?.size }
            .assign(to: \.imageSize, on: self)
            .store(in: &cancellables)
    }


    // MARK: - UI State
    @Published var isSourceSelectorPresented = false
    @Published var isFilterSelectorPresented = false
    @Published var isPickerPresented = false
    @Published var pickerSource: UIImagePickerController.SourceType = .photoLibrary
    @Published var isExportMenuPresented = false
    @Published var isDrawing = false
    @Published var showLogoutAlert = false

    // MARK: - Text Editing
    @Published var texts: [TextElement] = []
    @Published var addedText: String = "Your text"
    @Published var textColor: Color = .white
    @Published var textFontSize: CGFloat = 24
    @Published var textFontName: String = "HelveticaNeue"
    @Published var isTextEditing: Bool = false
    @Published var textPosition: CGSize = .zero
    @Published var editingTextID: UUID? = nil
    @Published var isDraggingTextNow: Bool = false

    // MARK: - Filters
    private let context = CIContext()
    let availableFilters: [(name: String, filter: CIFilter)] = [
        ("Sepia", CIFilter.sepiaTone()),
        ("Mono", CIFilter.photoEffectMono()),
        ("Noir", CIFilter.photoEffectNoir()),
        ("Invert", CIFilter.colorInvert()),
        ("Fade", CIFilter.photoEffectFade())
    ]

    // MARK: - Dependencies
    private var appState = AppStateService.shared
    
    //MARK: - Pencil
    @Published var canvasView = PKCanvasView()


    // MARK: - Actions
    func applyFilter(_ filter: CIFilter) {
        guard let originalImage = selectedImage,
              let cgImage = originalImage.cgImage else { return }

        let ciImage = CIImage(cgImage: cgImage)
        filter.setValue(ciImage, forKey: kCIInputImageKey)

        if let outputImage = filter.outputImage,
           let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            selectedImage = UIImage(cgImage: cgimg)
        }
    }

    func openPicker(source: UIImagePickerController.SourceType) {
        pickerSource = source
        isPickerPresented = true
    }

    //MARK: - Resetting settings from ScaleAndRotateSettingsView()
    func resetEdits() {
        scale = 1.0
        rotation = .zero
        imageOffset = .zero
    }

    //MARK: - Firebase logout
    func logOut() {
        do {
            try Auth.auth().signOut()
            appState.isLoggedIn = false
        } catch {
            print("Error signing out: \(error)")
        }
    }
}

//MARK: - Export
extension PhotoEditorViewModel {

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
            //MARK: - Filters saving
            let cgContext = context.cgContext
            cgContext.saveGState()

            baseImage.draw(in: CGRect(origin: .zero, size: outputSize))

            //MARK: - Canvas saving
            let canvasImage = canvasView.drawing.image(from: canvasView.bounds, scale: 1.0)
            canvasImage.draw(in: CGRect(origin: .zero, size: outputSize))

            //MARK: - Text saving
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
