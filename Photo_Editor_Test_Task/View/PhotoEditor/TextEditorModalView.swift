
import SwiftUI

struct TextEditorModalView: View {
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
                TextField("Enter text", text: $addedText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .font(.custom(textFontName, size: textFontSize)) // ← Текст того же размера, что и выбранный пользователем
                
                Slider(value: $textFontSize, in: 10...60, step: 1) {
                    Text("Size")
                } minimumValueLabel: {
                    Text("10")
                } maximumValueLabel: {
                    Text("60")
                }
                
                ColorPicker("Text Color", selection: $textColor)
                    .padding(.horizontal)
                
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
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 10)
            .padding(.horizontal)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
    
    private func saveText() {
        guard !addedText.isEmpty else { return }
        
        if let id = editingTextID,
           let index = texts.firstIndex(where: { $0.id == id }) {
            // Обновляем существующий текст
            texts[index].text = addedText
            texts[index].color = textColor
            texts[index].fontSize = textFontSize
            texts[index].fontName = textFontName
            texts[index].position = textPosition
        } else {
            // Добавляем новый текст
            let newText = TextElement(
                text: addedText,
                fontName: textFontName,
                fontSize: textFontSize,
                color: textColor,
                position: .zero
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
