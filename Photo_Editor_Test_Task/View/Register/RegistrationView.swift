
import SwiftUI

struct RegistrationView: View {
    @StateObject private var viewModel = RegistrationViewModel()
    
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    
    var body: some View {
        NavigationView {
            
            VStack(spacing: 16) {
                Text("Create your account")
                    .font(.title)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)
                
                TextField("Email", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                PasswordField(
                    title: "Password",
                    text: $viewModel.password,
                    isSecureTextVisible: $showPassword
                )
                PasswordField(
                    title: "Confirm Password",
                    text: $viewModel.confirmPassword,
                    isSecureTextVisible: $showConfirmPassword
                )
                
                if let error = viewModel.registrationErrorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }
                
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
                
                NavigationLink(destination: MainView(), isActive: $viewModel.isEmailVerified) {
                    EmptyView()
                }
                
                
                NavigationLink(destination: EmailVerificationView(
                    email: viewModel.email,
                    errorMessage: $viewModel.verificationErrorMessage,
                    onVerifiedPressed: {
                        viewModel.checkEmailVerification()
                    }
                ), isActive: $viewModel.isVerificationSent) {
                    EmptyView()
                }
                .onChange(of: viewModel.isVerificationSent) { isSent in
                    if !isSent {
                        // пользователь вернулся обратно
                        viewModel.isLoading = false
                    }
                }


            }
            .padding()
            .navigationTitle("Registration")
        }
    }
}

