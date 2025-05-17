import SwiftUI

struct PasswordResetView: View {
    @StateObject private var viewModel = PasswordResetViewModel()
    var onClose: () -> Void

    @State private var showContent = false

    var body: some View {
        ZStack {
            // Всплывающее окно
            VStack {
                VStack(spacing: 16) {
                    Text("Reset your password")
                        .font(.title3)
                        .bold()

                    // Скрываем поле email после успеха
                    if viewModel.successMessage == nil {
                        TextField("Email", text: $viewModel.email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    if let error = viewModel.error {
                        Text(error.errorDescription ?? "Unknown error")
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }

                    if let success = viewModel.successMessage {
                        Text(success)
                            .foregroundColor(.green)
                            .multilineTextAlignment(.center)
                    }

                    if viewModel.successMessage == nil {
                        HStack {
                            Button("Cancel") {
                                hideWithAnimation()
                            }
                            .foregroundColor(.red)

                            Spacer()

                            Button("Send") {
                                viewModel.sendReset()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    } else {
                        // Только большая кнопка Cancel
                        Button("Close") {
                            hideWithAnimation()
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(radius: 10)
                .frame(maxWidth: 320)
                .padding(.horizontal)
                .offset(y: showContent ? 0 : UIScreen.main.bounds.height / 2)
                .opacity(showContent ? 1 : 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .position(CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2 - 300))
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                withAnimation(.easeOut(duration: 0.35)) {
                    showContent = true
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
