import SwiftUI

struct PasswordResetView: View {
    @StateObject private var viewModel = PasswordResetViewModel()
    var onClose: () -> Void

    @State private var showContent = false

    var body: some View {
        ZStack {
            VStack {
                VStack(spacing: 16) {
                    resetYourPasswordLabel
                    
                    emailTF

                    errorMessage

                    successMessage

                    actionButtons
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
            // i dont know why, but view is lower then center
            .position(CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2 - 200))
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


private extension PasswordResetView {
    
    var resetYourPasswordLabel: some View {
        Text("Reset your password")
            .font(.title3)
            .bold()
            .foregroundColor(.black)
    }
    
    var emailTF: some View {
        Group {
            if viewModel.successMessage == nil {
                TextField("Email", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
    }
    
    // showing when we have some errors
    var errorMessage: some View {
        Group {
            if let error = viewModel.error {
                Text(error.errorDescription ?? "Unknown error")
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    // showing when email sended
    var successMessage: some View {
        Group {
            if let success = viewModel.successMessage {
                Text(success)
                    .foregroundColor(.green)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    var actionButtons: some View {
        // if reset email sended --> show only 'Cancel'
        // else --> show 'Cancel' and 'Send'
        Group {
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
                // Big 'Cancel' Button
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
    }
}
