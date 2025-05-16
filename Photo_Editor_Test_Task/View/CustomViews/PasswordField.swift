
import SwiftUI

struct PasswordField: View {
    let title: String
    @Binding var text: String
    @Binding var isSecureTextVisible: Bool

    var body: some View {
        HStack {
            if isSecureTextVisible {
                TextField(title, text: $text)
            } else {
                SecureField(title, text: $text)
            }

            Button(action: {
                isSecureTextVisible.toggle()
            }) {
                Image(systemName: isSecureTextVisible ? "eye.slash" : "eye")
                    .foregroundColor(.gray)
            }
        }
        .textFieldStyle(RoundedBorderTextFieldStyle())
    }
}
