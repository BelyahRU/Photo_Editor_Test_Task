
import Foundation

//MARK: - Errros of verification
enum VerificationError: LocalizedError {
    case emailNotVerifiedYet
    case networkError(String)
    
    var errorDescription: String? {
        switch self {
        case .emailNotVerifiedYet:
            return "Email is not verified yet. Please check your inbox."
        case .networkError(let message):
            return "Network error: \(message)"
        }
    }
}
