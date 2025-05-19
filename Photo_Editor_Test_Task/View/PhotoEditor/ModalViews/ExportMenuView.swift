import SwiftUI

struct ExportMenuView: View {
    var onSaveToPhotos: () -> Void
    var onExport: (ExportFormat) -> Void
    var onClose: () -> Void

    @State private var showContent = false
    @State private var selectedFormat: ExportFormat = .png

    var body: some View {
        ZStack {
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

                VStack(spacing: 16) {
                    Button(action: {
                        onSaveToPhotos()
                        hideWithAnimation()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 28, height: 28)
                                .foregroundColor(.white)
                                .background(Circle().fill(Color.green).frame(width: 40, height: 40))
                            Text("Save to Photos")
                                .foregroundColor(.black)
                                .font(.body)
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    Divider()
                    HStack(spacing: 12) {
                        Button(action: {
                            onExport(selectedFormat)
                            hideWithAnimation()
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "square.and.arrow.up")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 28, height: 28)
                                    .foregroundColor(.white)
                                    .background(Circle().fill(Color.blue).frame(width: 40, height: 40))
                                Text("Export")
                                    .foregroundColor(.black)
                                    .font(.body)
                            }
                        }

                        Menu {
                            ForEach(ExportFormat.allCases, id: \.self) { format in
                                Button {
                                    selectedFormat = format
                                } label: {
                                    Text(format.rawValue)
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedFormat.rawValue)
                                    .foregroundColor(.blue)
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.blue)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }

                        Spacer()
                    }
                    .padding(.horizontal)
                }

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
            .frame(maxWidth: 300)
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
enum ExportFormat: String, CaseIterable {
    case png = "PNG"
    case jpeg = "JPEG"
    case pdf = "PDF"
}
