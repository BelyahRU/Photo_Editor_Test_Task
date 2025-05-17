
import SwiftUI

//MARK: - Registration View handles user registration via Firebase
struct RegistrationView: View {
    @StateObject private var viewModel = RegistrationViewModel()
    
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    
    var body: some View {
        VStack(spacing: 16) {
            header
            
            emailTF
            
            // custom View Modifier
            passwordTF

            // custom View Modifier
            confirmPasswordTF
            
            errorMessage
            
            createAccountButton
            
            navigationLinks
        }
        .padding(.bottom, 150)
        .padding(.horizontal, 20)
        .navigationTitle("Registration")
    }
    
}

// MARK: - Private Views
private extension RegistrationView {
    var header: some View {
        Text("Create your account")
            .font(.title)
            .fontWeight(.medium)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 8)
    }
    
    var emailTF: some View {
        TextField("Email", text: $viewModel.email)
            .keyboardType(.emailAddress)
            .autocapitalization(.none)
            .textFieldStyle(RoundedBorderTextFieldStyle())
    }
    
    var passwordTF: some View {
        Text("")
            .passwordToggle(placeholder: "Password", text: $viewModel.password, isSecureTextVisible: $showPassword)
    }
    
    var confirmPasswordTF: some View {
        Text("")
            .passwordToggle(placeholder: "Confirm Password", text: $viewModel.confirmPassword, isSecureTextVisible: $showConfirmPassword)
    }
    
    var errorMessage: some View {
        Group {
            if let error = viewModel.registrationError {
                Text(error.errorDescription ?? "Unknown error").foregroundColor(.red)
            }
        }
    }
    
    var createAccountButton: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else {
                Button {
                    viewModel.register()
                } label: {
                    Label("Create Account", systemImage: "arrow.right")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .disabled(viewModel.isLoading)
            }
        }
    }
    
    var navigationLinks: some View {
        VStack {
            NavigationLink(destination: MainView(), isActive: $viewModel.isEmailVerified) {
                EmptyView()
            }
            
            
            NavigationLink(destination: EmailVerificationView(
                email: viewModel.email,
                error: $viewModel.verificationError,
                onVerifiedPressed: {
                    viewModel.checkEmailVerification()
                }
            ), isActive: $viewModel.isVerificationSent) {
                EmptyView()
            }
            .onChange(of: viewModel.isVerificationSent) { isSent in
                if !isSent {
                    // user's back
                    viewModel.isLoading = false
                }
            }
        }
    }
}
