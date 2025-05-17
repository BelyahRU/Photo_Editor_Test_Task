
import SwiftUI
import GoogleSignInSwift

struct AuthView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var showPassword = false

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("Sign in to your account")
                    .font(.title)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)
                
                TextField("Email", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Text("")
                    .passwordToggle(
                        placeholder: "Password",
                        text: $viewModel.password,
                        isSecureTextVisible: $showPassword
                    )

                if let error = viewModel.loginError {
                    Text(error.errorDescription ?? "Unknown error")
                        .foregroundColor(.red)
                }


                if viewModel.isLoading {
                    ProgressView("Signing in...")
                } else {
                    VStack(spacing: 12) {
                        Button {
                            viewModel.login()
                        } label: {
                            Label("Sign In", systemImage: "arrow.right")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)

                        GoogleSignInButton {
                            if let rootVC = UIApplication.shared.connectedScenes
                                .compactMap({ $0 as? UIWindowScene })
                                .first?.windows.first?.rootViewController {

                                viewModel.loginWithGoogle(presenting: rootVC)
                            }
                        }
                        .frame(height: 48)
                    }
                }
                
                NavigationLink(destination: RegistrationView()) {
                    Text("Don't have an account? Register")
                        .foregroundColor(.blue)
                        .padding(.top)
                }

                Spacer()
                
                NavigationLink(
                    destination: MainView(),
                    isActive: $viewModel.isSignedIn,
                    label: EmptyView.init
                )
            }
            .padding()
            .navigationTitle("Login")
        }
    }
}
