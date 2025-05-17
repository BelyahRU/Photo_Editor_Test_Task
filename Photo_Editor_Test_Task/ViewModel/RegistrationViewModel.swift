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
    @Published var registrationErrorMessage: String? = nil
    @Published var isLoading: Bool = false
    @Published var isVerificationSent: Bool = false
    @Published var isEmailVerified = false
    @Published var verificationErrorMessage: String? = nil
    
    private let validator = Validator()

    init() {
        if let user = Auth.auth().currentUser, !user.isEmailVerified {
            self.email = user.email ?? ""
            self.isVerificationSent = true
        }
    }

    func register() {
        Task {
            // if user already registered
            if let user = Auth.auth().currentUser {
                if user.email == email && !user.isEmailVerified {
                    // user registred, but not verified email
                    registrationErrorMessage = "You have already created an account. Please verify your email."
                    isVerificationSent = true
                    return
                } else if user.email == email && user.isEmailVerified {
                    // user registered and email is verified
                    registrationErrorMessage = "Email is already verified and in use."
                    return
                }
            }
            await asyncRegistration()
        }
    }
    
    func asyncRegistration() async {
        registrationErrorMessage = nil
        
        // Validation
        guard startValidation() else {
            return
        }
        
        isLoading = true
        
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            print("User created: \(result.user.uid)")
            registrationErrorMessage = nil
            
            // start email verification
            try await result.user.sendEmailVerification()

            isVerificationSent = true
            print("Verification email sent to \(result.user.email ?? "")")
        } catch {
            registrationErrorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func checkEmailVerification() {
        Task {
            guard let user = Auth.auth().currentUser else { return }
            try? await user.reload()
            if user.isEmailVerified {
                isEmailVerified = true
                isVerificationSent = false // --> show MainView
                verificationErrorMessage = nil
            } else {
                verificationErrorMessage = "Email is not verified yet. Please try again."
            }
        }
    }

    // MARK: - Validation
    private func startValidation() -> Bool {
        
        // сhecking email
        switch validator.checkEmail(email) {
        case .failure(let message):
            registrationErrorMessage = message
            return false
        case .success: break
        }
        
        // сhecking password
        switch validator.checkPassword(password) {
        case .failure(let message):
            registrationErrorMessage = message
            return false
        case .success: break
        }
        
        // сhecking password match
        switch validator.checkPasswordMatch(password, confirmPassword) {
        case .failure(let message):
            registrationErrorMessage = message
            return false
        case .success: break
        }
        
        return true
    }
}
