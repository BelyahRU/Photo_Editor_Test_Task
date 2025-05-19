
import SwiftUI
import FirebaseAuth
import CoreImage
import CoreImage.CIFilterBuiltins
import PencilKit


class PhotoEditorViewModel: ObservableObject {
    // MARK: - Image State
    @Published var selectedImage: UIImage?
    @Published var scale: CGFloat = 1.0
    @Published var rotation: Angle = .zero
    @Published var imageOffset: CGSize = .zero

    var imageSize: CGSize {
        selectedImage?.size ?? .zero
    }

    // MARK: - UI State
    @Published var isSourceSelectorPresented = false
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

    func resetEdits() {
        scale = 1.0
        rotation = .zero
        imageOffset = .zero
    }

    func logOut() {
        do {
            try Auth.auth().signOut()
            appState.isLoggedIn = false
        } catch {
            print("Error signing out: \(error)")
        }
    }
}
