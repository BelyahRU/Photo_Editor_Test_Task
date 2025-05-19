import SwiftUI

struct SourceSelectorModalView: View {
    var onSelectGallery: () -> Void
    var onSelectCamera: () -> Void
    var onClose: () -> Void

    @State private var showContent = false

    var body: some View {
        ZStack {
            // Прозрачный фон с возможностью закрытия
            Color.clear
                .ignoresSafeArea()
                .onTapGesture {
                    hideWithAnimation()
                }

            VStack(spacing: 20) {
                Text("Choose a source")
                    .font(.title3)
                    .bold()
                    .padding(.top)

                HStack(spacing: 40) {
                    VStack(spacing: 8) {
                        Button(action: {
                            onSelectGallery()
                            hideWithAnimation()
                        }) {
                            Image(systemName: "photo.on.rectangle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 36, height: 36)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .clipShape(Circle())
                        }

                        Text("Gallery")
                            .foregroundColor(.black)
                            .font(.subheadline)
                    }

                    VStack(spacing: 8) {
                        Button(action: {
                            onSelectCamera()
                            hideWithAnimation()
                        }) {
                            Image(systemName: "camera")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 36, height: 36)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .clipShape(Circle())
                        }

                        Text("Camera")
                            .foregroundColor(.black)
                            .font(.subheadline)
                    }
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
