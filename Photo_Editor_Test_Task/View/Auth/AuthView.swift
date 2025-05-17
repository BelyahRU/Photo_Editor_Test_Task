
import SwiftUI
import GoogleSignInSwift

//MARK: Auth View authenticates users via Firebase
struct AuthView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var showPassword = false

    //MARK: - Content
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                VStack(spacing: 16) {
                    header
                    
                    emailTF
                    
                    passwordTF
                    
                    errorMessage
                    
                    loginButtonSection
                    
                    navigationLinks
                    
                    Spacer()
                }
                .padding()
                .overlay {
                    if viewModel.isResetPasswordPresented {
                        Color.black.opacity(0.4).ignoresSafeArea()
                    }
                }
                
                if viewModel.isResetPasswordPresented {
                    passwordResetModalView
                }
            }
            .navigationTitle("Login")
        }
    }
}

// MARK: - Private Views
private extension AuthView {
    var header: some View {
        Text("Sign in to your account")
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

    // custom View Modifier
    var passwordTF: some View {
        Text("")
            .passwordToggle(
                placeholder: "Password",
                text: $viewModel.password,
                isSecureTextVisible: $showPassword
            )
    }

    var errorMessage: some View {
        Group {
            if let error = viewModel.authError {
                Text(error.errorDescription ?? "Unknown error")
                    .foregroundColor(.red)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    var loginButtonSection: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Signing in...")
            } else {
                VStack(spacing: 12) {
                    signInButton
                    googleSignInButton
                }
            }
        }
    }
    
    var signInButton: some View {
        Button {
            viewModel.login()
        } label: {
            Label("Sign In", systemImage: "arrow.right")
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(.blue)
    }

    // Button from GoogleSignInSwift lib
    var googleSignInButton: some View {
        GoogleSignInButton {
            if let rootVC = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first?.windows.first?.rootViewController {
                
                viewModel.loginWithGoogle(presenting: rootVC)
            }
        }
        .frame(height: 48)
    }

    // navigation
    var navigationLinks: some View {
        VStack {
            // --> RegistrationView()
            NavigationLink(destination: RegistrationView()) {
                Text("Don't have an account? Register")
                    .foregroundColor(.blue)
                    .padding(.top)
            }
            
            // --> PasswordResetView()
            Button {
                viewModel.isResetPasswordPresented = true
            } label: {
                Text("Forgot password?")
                    .foregroundColor(.blue)
            }
        }
    }

    // modal view for resetting password
    // this view shows from bottom to center
    var passwordResetModalView: some View {
        PasswordResetView {
            withAnimation {
                viewModel.isResetPasswordPresented = false
            }
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.easeInOut(duration: 0.3), value: viewModel.isResetPasswordPresented)
    }
}
