
import SwiftUI
import Foundation

struct EmailVerificationView: View {
    var email: String
    @Binding var error: VerificationError?
    var onVerifiedPressed: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            emailImage

            confirmYourEmailLabel
            
            usersEmail

            noticeLabel

            // red error with verification
            errorMessage

            userVerifiedButton

            Spacer()
        }
        .padding()
        .navigationTitle("Email Verification")
    }
}

// MARK: - Private Views
private extension EmailVerificationView {
    var emailImage: some View {
        Image(systemName: "envelope.circle.fill")
            .resizable()
            .frame(width: 80, height: 80)
            .foregroundColor(.blue)
    }
    
    var confirmYourEmailLabel: some View {
        Text("Confirm your email")
            .font(.title)
            .bold()
    }
    
    var usersEmail: some View {
        VStack(spacing: 8) {
            Text("We’ve sent a verification email to:")
            Text(email)
                .font(.body)
                .foregroundColor(.gray)
        }
        .multilineTextAlignment(.center)
    }
    
    var noticeLabel: some View {
        Text("After clicking the link in the email, tap the button below.")
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }
    
    var errorMessage: some View {
        Group {
            if let error = error {
                Text(error.errorDescription ?? "Unknown error")
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    var userVerifiedButton: some View {
        Button(action: onVerifiedPressed) {
            Text("I Verified Email")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
    }
}
