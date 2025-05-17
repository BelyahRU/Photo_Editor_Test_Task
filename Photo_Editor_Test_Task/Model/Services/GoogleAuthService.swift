import Foundation
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift

final class GoogleAuthService {
    static let shared = GoogleAuthService()

    func signIn(presenting viewController: UIViewController) async throws -> AuthDataResult {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw NSError(domain: "MissingClientID", code: -1)
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // call it from main thread(some errors will if we do it in other thread)
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async {
                GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { result, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }

                    guard let idToken = result?.user.idToken?.tokenString,
                          let accessToken = result?.user.accessToken.tokenString else {
                        continuation.resume(throwing: NSError(domain: "MissingTokens", code: -1))
                        return
                    }

                    let credential = GoogleAuthProvider.credential(
                        withIDToken: idToken,
                        accessToken: accessToken
                    )

                    Auth.auth().signIn(with: credential) { authResult, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else if let authResult = authResult {
                            continuation.resume(returning: authResult)
                        } else {
                            continuation.resume(throwing: NSError(domain: "UnknownError", code: -1))
                        }
                    }
                }
            }
        }
    }
}

