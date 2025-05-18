
import SwiftUI
import FirebaseAuth

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

