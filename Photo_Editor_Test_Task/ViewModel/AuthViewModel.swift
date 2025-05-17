import Foundation
import SwiftUI
import Combine
import FirebaseAuth

@MainActor
final class AuthViewModel: ObservableObject {
    
    //MARK: - User data
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var loginErrorMessage: String? = nil
    
    //MARK: - States
    @Published var isLoading: Bool = false
    @Published var isSignedIn: Bool = false
    
    private let validator = Validator()

    func login() {
        Task {
            if !startValidation() {
                return
            }
            await asyncLogin()
        }
    }
    
    func asyncLogin() async {
        loginErrorMessage = nil
        isLoading = true
        
        do {
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            
            if !authResult.user.isEmailVerified {
                loginErrorMessage = "Please verify your email before logging in."
                isLoading = false
                return
            }
            
            print("User logged in: \(authResult.user.uid)")
            loginErrorMessage = nil
            self.isSignedIn = true // --> show MainView
        } catch {
            loginErrorMessage = error.localizedDescription
        }
        
        isLoading = false
    }

    // MARK: - Validation
    
    private func startValidation() -> Bool {
        switch validator.checkEmail(email) {
        case .failure(let message):
            loginErrorMessage = message
            return false
        case .success: break
        }
        
        switch validator.checkPassword(password) {
        case .failure(let message):
            loginErrorMessage = message
            return false
        case .success: break
        }
        
        return true
    }
}
