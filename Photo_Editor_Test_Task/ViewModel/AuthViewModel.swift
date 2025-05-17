import Foundation
import SwiftUI
import Combine
import FirebaseAuth
import UIKit 
import GoogleSignIn

@MainActor
final class AuthViewModel: ObservableObject {
    
    //MARK: - User data
    @Published var email: String = ""
    @Published var password: String = ""
    
    //MARK: - Error
    @Published var loginError: AuthError?
    
    //MARK: - States
    @Published var isLoading: Bool = false
    @Published var isSignedIn: Bool = false

    private let validator = ValidationService()
    
    // MARK: - Email/Password Login
    func login() {
        Task {
            if !startValidation() {
                return
            }
            await asyncLogin()
        }
    }
    
    private func asyncLogin() async {
        loginError = nil
        isLoading = true

        do {
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)

            if !authResult.user.isEmailVerified {
                loginError = .emailNotVerified
                isLoading = false
                return
            }

            print("User logged in: \(authResult.user.uid)")
            isSignedIn = true
        } catch let error as NSError {
            switch error.code {
            case AuthErrorCode.userNotFound.rawValue:
                loginError = .userNotFound
            case AuthErrorCode.wrongPassword.rawValue:
                loginError = .wrongPassword
            case AuthErrorCode.invalidEmail.rawValue:
                loginError = .invalidEmail
            default:
                loginError = .networkError(error.localizedDescription)
            }
        }

        isLoading = false
    }

    
    // MARK: - Google Login
    func loginWithGoogle(presenting: UIViewController) {
        Task {
            await MainActor.run {
                isLoading = true
                loginError = nil
            }

            do {
                let result = try await GoogleAuthService.shared.signIn(presenting: presenting)
                print("Google Sign-In: \(result.user.email ?? "")")
                await MainActor.run {
                    isSignedIn = true
                }
            } catch let error as NSError {
                await MainActor.run {
                    switch error.code {
                    case AuthErrorCode.userDisabled.rawValue:
                        loginError = .networkError("This account has been disabled.")
                    case AuthErrorCode.networkError.rawValue:
                        loginError = .networkError("Network error occurred.")
                    default:
                        loginError = .networkError(error.localizedDescription)
                    }
                }
            }

            await MainActor.run {
                isLoading = false
            }
        }
    }



    // MARK: - Validation
    private func startValidation() -> Bool {
        switch validator.checkEmail(email) {
        case .failure:
            loginError = .invalidEmail
            return false
        case .success: break
        }

        switch validator.checkPassword(password) {
        case .failure:
            loginError = .weakPassword
            return false
        case .success: break
        }

        return true
    }

}
