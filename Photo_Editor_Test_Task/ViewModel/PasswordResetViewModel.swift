
import Foundation
import FirebaseAuth

@MainActor
final class PasswordResetViewModel: ObservableObject {
    
    //MARK: - User data
    @Published var email: String = ""
    
    //MARK: - Responces
    @Published var error: AuthError?
    @Published var successMessage: String?

    private let validator = ValidationService()

    func sendReset() {
        error = nil
        successMessage = nil

        guard startValidation(email) else { return }

        Task {
            do {
                try await Auth.auth().sendPasswordReset(withEmail: self.email)
                await MainActor.run {
                    self.successMessage = "Password reset email sent to \(self.email)"
                    self.email = ""
                }
            } catch {
                await MainActor.run {
                    self.error = .networkError(error.localizedDescription)
                }
            }
        }
    }
    
    private func startValidation(_ userEmail: String) -> Bool {
        switch validator.checkEmail(userEmail) {
        case .failure:
            error = .invalidEmail
            return false
        case .success:
            return true
        }
    }
}

