
import SwiftUI

//MARK: - View Modifier allows you to hide/show the password
struct PasswordToggleModifier: ViewModifier {
    let placeholder: String
    @Binding var text: String
    @Binding var isSecureTextVisible: Bool

    func body(content: Content) -> some View {
        HStack {
            // TextFields
            Group {
                if isSecureTextVisible {
                    TextField(placeholder, text: $text) // showing when button is "eye.slash"
                } else {
                    SecureField(placeholder, text: $text) // showing when button is "eye"
                }
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())

            // eye button
            Button(action: {
                isSecureTextVisible.toggle()
            }) {
                Image(systemName: isSecureTextVisible ? "eye.slash" : "eye")
                    .foregroundColor(.gray)
            }
        }
    }
}
