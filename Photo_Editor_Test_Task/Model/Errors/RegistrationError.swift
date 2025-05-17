
import Foundation

// Errors of registration
enum RegistrationError: LocalizedError {
    case emptyFields
    case invalidEmail
    case weakPassword
    case passwordsDontMatch
    case emailAlreadyInUse
    case emailIsNotVerified
    case networkError(String)
    
    var errorDescription: String? {
        switch self {
        case .emptyFields:
            return "All fields are required."
        case .invalidEmail:
            return "Please enter a valid email address."
        case .weakPassword:
            return "Password must be at least 6 characters and not too common."
        case .passwordsDontMatch:
            return "Passwords do not match."
        case .emailAlreadyInUse:
            return "This email is already in use."
        case .emailIsNotVerified:
            return "This email is registrted but not verified"
        case .networkError(let message):
            return "Network error: \(message)"
        }
    }
}


