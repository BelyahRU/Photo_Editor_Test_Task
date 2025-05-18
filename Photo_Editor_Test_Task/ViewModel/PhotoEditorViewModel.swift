
import SwiftUI
import FirebaseAuth
import CoreImage
import CoreImage.CIFilterBuiltins

class PhotoEditorViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var scale: CGFloat = 1.0 // масштаб
    @Published var rotation: Angle = .zero // поворот
    @Published var imageOffset: CGSize = .zero
    var imageSize: CGSize {
        selectedImage?.size ?? .zero
    }
    
    @Published var isSourceSelectorPresented = false

    //MARK: - PencilKit
    @Published var isDrawing = false
    
    
    //MARK: - UIImagePickerController
    @Published var isPickerPresented = false
    @Published var pickerSource: UIImagePickerController.SourceType = .photoLibrary
    
    
    
    private var appState = AppStateService.shared
    
    private let context = CIContext()
    let availableFilters: [(name: String, filter: CIFilter)] = [
        ("Sepia", CIFilter.sepiaTone()),
        ("Mono", CIFilter.photoEffectMono()),
        ("Noir", CIFilter.photoEffectNoir()),
        ("Invert", CIFilter.colorInvert()),
        ("Fade", CIFilter.photoEffectFade())
    ]

        
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

    //set standart rotation and scale
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

