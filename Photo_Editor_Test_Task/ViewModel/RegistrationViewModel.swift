
import Foundation
import SwiftUI
import Combine
import FirebaseAuth

@MainActor
final class RegistrationViewModel: ObservableObject {
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    
    //MARK: - States
    @Published var registrationErrorMessage: String? = nil //message
    @Published var isLoading: Bool = false
    
    func register() {
        Task {
            await asyncRestration()
        }
    }
    
    func asyncRestration() async {
        registrationErrorMessage = nil
        
        if !startValidation() {
            return
        }
        
        isLoading = true
        
        do {
            let methods = try await Auth.auth().fetchSignInMethods(forEmail: email)
            
            if !methods.isEmpty {
                registrationErrorMessage = "Email is already registered"
                isLoading = false
                return
            }
            
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            print("User created: \(result.user.uid)")
            registrationErrorMessage = nil
            isLoading = false
        } catch {
            registrationErrorMessage = error.localizedDescription
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
