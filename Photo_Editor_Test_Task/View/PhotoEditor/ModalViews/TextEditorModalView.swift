
import SwiftUI

//MARK: - Custom View for creating text
struct TextEditorModalView: View {
    var selectedImage: UIImage?
    @Binding var isPresented: Bool
    @Binding var addedText: String
    @Binding var textColor: Color
    @Binding var textFontSize: CGFloat
    @Binding var textFontName: String
    @Binding var textPosition: CGSize
    @Binding var editingTextID: UUID?
    @Binding var texts: [TextElement]
    
    var body: some View {
        if isPresented {
            VStack(spacing: 12) {
                
                //MARK: - TextField
                TextField("Enter text", text: $addedText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .foregroundColor(textColor == .white ? .primary : textColor)
                    .font(.custom(textFontName, size: textFontSize))
                
                //MARK: - Font Slider
                Slider(value: $textFontSize, in: 10...60, step: 1) {
                    Text("Size")
                } minimumValueLabel: {
                    Text("10")
                } maximumValueLabel: {
                    Text("60")
                }
                .padding(.horizontal)
                
                //MARK: - Font Color picker
                ColorPicker("Text Color", selection: $textColor)
                    .padding(.horizontal)
                
                //MARK: - Font Picker
                Picker("Font", selection: $textFontName) {
                    Text("Helvetica").tag("HelveticaNeue")
                    Text("Marker").tag("MarkerFelt-Wide")
                    Text("Courier").tag("Courier")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                HStack {
                    Button("Delete") {
                        if let id = editingTextID {
                            texts.removeAll { $0.id == id }
                        }
                        reset()
                    }
                    .foregroundColor(.red)
                    
                    Spacer()
                    
                    Button("Done") {
                        saveText()
                        reset()
                    }
                }
                .padding()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground)) // Adapts to dark/light mode
                    .shadow(radius: 10)
            )
            .padding(.horizontal)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
    
    private func saveText() {
        guard !addedText.isEmpty else { return }

        if let id = editingTextID,
           let index = texts.firstIndex(where: { $0.id == id }) {
            // Обновление текста
            texts[index].text = addedText
            texts[index].color = textColor
            texts[index].fontSize = textFontSize
            texts[index].fontName = textFontName
            texts[index].position = textPosition
        } else {
            // Центр изображения по отображаемому размеру
            let screenWidth = UIScreen.main.bounds.width
            let imageHeight: CGFloat = 350

            let scaleFactor = min(
                screenWidth / (selectedImage?.size.width ?? 1),
                imageHeight / (selectedImage?.size.height ?? 1)
            )

            let displaySize = CGSize(
                width: (selectedImage?.size.width ?? 1) * scaleFactor,
                height: (selectedImage?.size.height ?? 1) * scaleFactor
            )

            let centerPosition = CGSize(
                width: displaySize.width / 2,
                height: displaySize.height / 2
            )

            let newText = TextElement(
                text: addedText,
                fontName: textFontName,
                fontSize: textFontSize,
                color: textColor,
                position: centerPosition
            )

            texts.append(newText)
        }
    }

    private func reset() {
        addedText = ""
        textColor = .white
        textFontSize = 24
        textFontName = "HelveticaNeue"
        textPosition = .zero
        editingTextID = nil
        isPresented = false
    }
}
