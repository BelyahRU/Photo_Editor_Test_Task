
import SwiftUI

class PhotoEditorViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var scale: CGFloat = 1.0 // масштаб
    @Published var rotation: Angle = .zero // поворот
    
    //MARK: - UIImagePickerController
    @Published var isPickerPresented = false
    @Published var pickerSource: UIImagePickerController.SourceType = .photoLibrary
    
    func openPicker(source: UIImagePickerController.SourceType) {
        pickerSource = source
        isPickerPresented = true
    }

    //set standart rotation and scale
    func resetEdits() {
        scale = 1.0
        rotation = .zero
    }
}

