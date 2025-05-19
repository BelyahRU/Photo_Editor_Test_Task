
import SwiftUI
import PencilKit

//MARK: - PencilKit configuration
struct CanvasViewRepresentable: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var toolPicker: PKToolPicker
    var isDrawingEnabled: Bool
    var scale: CGFloat

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.drawing = canvasView.drawing 

        configureToolPicker(for: canvasView)
        canvasView.isUserInteractionEnabled = isDrawingEnabled

        applyTransform(to: canvasView)

        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.isUserInteractionEnabled = isDrawingEnabled
        isDrawingEnabled
            ? configureToolPicker(for: uiView)
            : toolPicker.setVisible(false, forFirstResponder: uiView)

        applyTransform(to: uiView)
    }

    private func configureToolPicker(for view: PKCanvasView) {
        toolPicker.setVisible(true, forFirstResponder: view)
        toolPicker.addObserver(view)
        view.becomeFirstResponder()
    }

    private func applyTransform(to view: PKCanvasView) {
        let transform = CGAffineTransform.identity
            .translatedBy(x: view.bounds.width / 2, y: view.bounds.height / 2)
            .scaledBy(x: scale, y: scale)
            .translatedBy(x: -view.bounds.width / 2, y: -view.bounds.height / 2)

        view.transform = transform
    }
}
