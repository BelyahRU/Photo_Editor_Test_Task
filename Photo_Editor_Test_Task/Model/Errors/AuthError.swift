
import Foundation

enum AuthError: LocalizedError, Equatable {
    case invalidEmail
    case weakPassword
    case wrongPassword
    case userNotFound
    case emailNotVerified
    case networkError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Invalid email address."
        case .weakPassword:
            return "Password is too short or weak."
        case .wrongPassword:
            return "Wrong password."
        case .userNotFound:
            return "No account found with this email."
        case .emailNotVerified:
            return "Please verify your email before logging in."
        case .networkError(let description):
            return "Something went wrong: \(description)"
        }
    }
}
