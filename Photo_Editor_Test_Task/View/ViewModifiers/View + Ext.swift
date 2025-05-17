
import SwiftUI

// MARK: - View extension
extension View {
    func passwordToggle(
        placeholder: String,
        text: Binding<String>,
        isSecureTextVisible: Binding<Bool>
    ) -> some View {
        modifier(PasswordToggleModifier(
            placeholder: placeholder,
            text: text,
            isSecureTextVisible: isSecureTextVisible
        ))
    }
}

