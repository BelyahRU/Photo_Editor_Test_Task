
import SwiftUI
import FirebaseAuth

class AppStateService: ObservableObject {
    
    static let shared = AppStateService()
    
    private init() {}
    
    @Published var isLoggedIn: Bool = Auth.auth().currentUser != nil
}
