import SwiftUI

struct ExportMenuView: View {
    var onSaveToPhotos: () -> Void
    var onExport: (ExportFormat) -> Void
    var onClose: () -> Void

    @State private var showContent = false

    var body: some View {
        ZStack {
            // Прозрачный фон для закрытия по клику
            Color.clear
                .ignoresSafeArea()
                .onTapGesture {
                    hideWithAnimation()
                }

            VStack(spacing: 20) {
                Text("Export Options")
                    .font(.title3)
                    .bold()
                    .padding(.top)

                // Сохранить в фотоальбом
                HStack(spacing: 16) {
                    Button(action: {
                        onSaveToPhotos()
                        hideWithAnimation()
                    }) {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 36, height: 36)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .clipShape(Circle())
                        Text("Save to Photos")
                            .foregroundColor(.black)
                            .font(.subheadline)
                    }
                }

                // Экспорт (поделись, отправь в соцсети)
                HStack(spacing: 16) {
                    Button(action: {
                        onExport(.png)
                        hideWithAnimation()
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 36, height: 36)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .clipShape(Circle())
                        Text("Export")
                            .foregroundColor(.black)
                            .font(.subheadline)
                    }
                }

                // Кнопка отмены
                Button("Cancel") {
                    hideWithAnimation()
                }
                .foregroundColor(.red)
                .padding(.top, 10)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 10)
            .padding(.horizontal)
            .offset(y: showContent ? 0 : UIScreen.main.bounds.height / 2)
            .opacity(showContent ? 1 : 0)
            .animation(.easeOut(duration: 0.35), value: showContent)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    withAnimation {
                        showContent = true
                    }
                }
            }
        }
    }

    private func hideWithAnimation() {
        withAnimation(.easeIn(duration: 0.3)) {
            showContent = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onClose()
        }
    }
}

// MARK: - Типы экспорта
enum ExportFormat: String {
    case png = "PNG"
    case jpeg = "JPEG"
    case pdf = "PDF"
}
