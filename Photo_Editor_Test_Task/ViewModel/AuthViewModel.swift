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
    @Published var authError: AuthError?
    
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
        authError = nil
        isLoading = true

        do {
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)

            if !authResult.user.isEmailVerified {
                authError = .emailNotVerified
                isLoading = false
                return
            }

            print("User logged in: \(authResult.user.uid)")
            isSignedIn = true
        } catch let error as NSError {
            switch error.code {
            case AuthErrorCode.userNotFound.rawValue:
                authError = .userNotFound
            case AuthErrorCode.wrongPassword.rawValue:
                authError = .wrongPassword
            case AuthErrorCode.invalidEmail.rawValue:
                authError = .invalidEmail
            default:
                authError = .networkError(error.localizedDescription)
            }
        }

        isLoading = false
    }

    
    // MARK: - Google Login
    func loginWithGoogle(presenting: UIViewController) {
        Task {
            await MainActor.run {
                isLoading = true
                authError = nil
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
                        authError = .networkError("This account has been disabled.")
                    case AuthErrorCode.networkError.rawValue:
                        authError = .networkError("Network error occurred.")
                    default:
                        authError = .networkError(error.localizedDescription)
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
            authError = .invalidEmail
            return false
        case .success: break
        }

        switch validator.checkPassword(password) {
        case .failure:
            authError = .weakPassword
            return false
        case .success: break
        }

        return true
    }

}
