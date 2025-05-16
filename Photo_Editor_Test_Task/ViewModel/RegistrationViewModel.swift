
import Foundation
import SwiftUI
import Combine
import FirebaseAuth

@MainActor
final class RegistrationViewModel: ObservableObject {
    
    //MARK: - User data
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    
    //MARK: - States
    @Published var registrationErrorMessage: String? = nil
    @Published var isLoading: Bool = false
    @Published var isVerificationSent: Bool = false
    @Published var isEmailVerified = false
    @Published var verificationErrorMessage: String? = nil
    
    
    init() {
        if let user = Auth.auth().currentUser, !user.isEmailVerified {
            self.email = user.email ?? ""
            self.isVerificationSent = true
        }
    }

    func register() {
        Task {
            // если уже есть текущий пользователь
            if let user = Auth.auth().currentUser {
                if user.email == email && !user.isEmailVerified {
                    // пользователь уже зарегистрирован, но не подтвердил email
                    registrationErrorMessage = "You have already created an account. Please verify your email."
                    isVerificationSent = true
                    return
                } else if user.email == email && user.isEmailVerified {
                    // пользователь зарегестрирован и email подтвержден
                    registrationErrorMessage = "Email is already verified and in use."
                    return
                }
            }
            await asyncRegistration()
        }
    }
    
    
    func asyncRegistration() async {
        registrationErrorMessage = nil
        
        if !startValidation() {
            return
        }
        
        isLoading = true
        
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            print("User created: \(result.user.uid)")
            registrationErrorMessage = nil
            
            try await result.user.sendEmailVerification()

            isVerificationSent = true
            print("Verification email sent to \(result.user.email ?? "")")
        } catch {
            registrationErrorMessage = error.localizedDescription
        }
    }
    
    func checkEmailVerification() {
        Task {
            guard let user = Auth.auth().currentUser else { return }
            try? await user.reload()
            if user.isEmailVerified {
                isEmailVerified = true
                isVerificationSent = false // переход в MainContentView
                verificationErrorMessage = nil
            } else {
                verificationErrorMessage = "Email is not verified yet. Please try again."
            }
        }
    }

    
    private func startValidation() -> Bool {
        if !checkEmail(email) {
            registrationErrorMessage = "Invalid email"
            return false
        }
        
        if password != confirmPassword {
            registrationErrorMessage = "Password don't match"
            return false
        }
        
        if !checkStrongPassword(password) {
            registrationErrorMessage = "Password is too simple or less then 6 characters"
            return false
        }
        
        return true
    }
    
    private func checkEmail(_ userEmail: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: userEmail)
    }
    
    private func checkStrongPassword(_ password: String) -> Bool {
        guard password.count >= 6 else { return false } // password less then 6 characters
        let weakPass = ["123321", "asdfgh", "111111", "password", "qwerty", "pass123"]
        return !weakPass.contains(password.lowercased())
    }
}
