
import Foundation

enum ValidationResult {
    case success
    case failure(String)
}

struct ValidationService {
    
    func checkEmail(_ email: String) -> ValidationResult {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let isCorrectEmail = NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
        return isCorrectEmail ? ValidationResult.success : ValidationResult.failure("Invalid email")
    }

    func checkPassword(_ password: String) -> ValidationResult {
        guard password.count >= 6 else {
            return .failure("Password must be at least 6 characters")
        }
        let weak = ["123321", "asdfgh", "111111", "password", "qwerty", "pass123", "123123"]
        if weak.contains(password.lowercased()) {
            return .failure("Password is too weak")
        }
        return .success
    }

    func checkPasswordMatch(_ password: String, _ confirmPassword: String) -> ValidationResult {
        password == confirmPassword ? .success : .failure("Passwords do not match")
    }
    
}


