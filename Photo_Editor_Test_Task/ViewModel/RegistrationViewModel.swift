import Foundation
import SwiftUI
import Combine
import FirebaseAuth

@MainActor
final class RegistrationViewModel: ObservableObject {
    
    // MARK: - User data
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    
    // MARK: - States
    @Published var isLoading: Bool = false
    @Published var isVerificationSent: Bool = false
    @Published var isEmailVerified = false
    
    //MARK: - Errors
    @Published var registrationError: RegistrationError?
    @Published var verificationError: VerificationError?
    
    private var appState = AppStateService.shared
    
    private let validator = ValidationService()

    init() {
        if let user = Auth.auth().currentUser, !user.isEmailVerified {
            self.email = user.email ?? ""
            self.isVerificationSent = true
        }
    }

    func register() {
        Task {
            // Is the user already registered?
            if let user = Auth.auth().currentUser {
                // email is registred but not verified
                if user.email == email && !user.isEmailVerified {
                    registrationError = .emailIsNotVerified
                    isVerificationSent = true
                    return
                // email is registred and verified
                } else if user.email == email && user.isEmailVerified {
                    registrationError = .emailAlreadyInUse
                    return
                }
            }

            await asyncRegistration()
        }
    }

    private func asyncRegistration() async {
        registrationError = nil
        
        // starting validation
        if let validationError = startValidation() {
            registrationError = validationError
            isLoading = false
            return
        }

        isLoading = true

        do {
            // trying auth
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            print("User created: \(result.user.uid)")

            // trying email verification
            try await result.user.sendEmailVerification()
            isVerificationSent = true
            print("Verification email sent to \(result.user.email ?? "")")
        } catch let error as NSError {
            switch error.code {
            case AuthErrorCode.emailAlreadyInUse.rawValue:
                registrationError = .emailAlreadyInUse
            default:
                registrationError = .networkError(error.localizedDescription)
            }
        } catch {
            registrationError = .networkError(error.localizedDescription)
        }

        isLoading = false
    }
    
    //MARK: - Email Verification
    func checkEmailVerification() {
        Task {
            guard let user = Auth.auth().currentUser else { return }
            do {
                try await user.reload()
                if user.isEmailVerified {
                    isEmailVerified = true
                    isVerificationSent = false
                    verificationError = nil
                    appState.isLoggedIn = true
                } else {
                    verificationError = .emailNotVerifiedYet
                }
            } catch {
                verificationError = .networkError(error.localizedDescription)
            }
        }
    }

    // MARK: - Validation
    private func startValidation() -> RegistrationError? {

        // checking email
        switch validator.checkEmail(email) {
            case .failure:
                return .invalidEmail
            case .success: break
        }

        // checking password
        switch validator.checkPassword(password) {
            case .failure:
                return .weakPassword
            case .success: break
        }

        // checking passwords match
        switch validator.checkPasswordMatch(password, confirmPassword) {
            case .failure:
                return .passwordsDontMatch
            case .success: break
        }

        // checking empty fields
        if email.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            return .emptyFields
        }

        return nil
    }
}
