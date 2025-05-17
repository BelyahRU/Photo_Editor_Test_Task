
import SwiftUI

struct PasswordToggleModifier: ViewModifier {
    let placeholder: String
    @Binding var text: String
    @Binding var isSecureTextVisible: Bool

    func body(content: Content) -> some View {
        HStack {
            Group {
                if isSecureTextVisible {
                    TextField(placeholder, text: $text)
                } else {
                    SecureField(placeholder, text: $text)
                }
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())

            Button(action: {
                isSecureTextVisible.toggle()
            }) {
                Image(systemName: isSecureTextVisible ? "eye.slash" : "eye")
                    .foregroundColor(.gray)
            }
        }
    }
}
