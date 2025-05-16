import SwiftUI


struct EmailVerificationView: View {
    let email: String
    @Binding var errorMessage: String?
    let onVerifiedPressed: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "envelope.circle.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.blue)

            Text("Confirm your email")
                .font(.title)
                .bold()
            
            VStack(spacing: 8) {
                Text("We’ve sent a verification email to:")
                Text(email)
                    .font(.body)
                    .foregroundColor(.gray)
            }
            .multilineTextAlignment(.center)

            Text("After clicking the link in the email, tap the button below.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // red error with verification
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }

            Button(action: onVerifiedPressed) {
                Text("I Verified Email")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Email Verification")
    }
}
