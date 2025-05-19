
import SwiftUI

//MARK: - Struct which controlls scale and rotation settings
struct ScaleAndRotationSettingsView: View {
    @ObservedObject var viewModel: PhotoEditorViewModel

    var body: some View {
        Group {
            if viewModel.selectedImage != nil {
                VStack(alignment: .leading, spacing: 3) {
                    //MARK: - Scale slider
                    Text("Scale")
                    Slider(value: $viewModel.scale, in: 0.5...3.0) { _ in }

                    //MARK: - Rotation slider
                    Text("Rotation")
                    Slider(
                        value: Binding(
                            get: { viewModel.rotation.degrees },
                            set: { viewModel.rotation = .degrees($0) }
                        ),
                        in: -180...180
                    ) { _ in }
                }
                .padding(.horizontal, 20)

                //MARK: - Reset button
                Button("Reset") {
                    viewModel.resetEdits()
                }
                .padding()
            }
        }
    }
}
