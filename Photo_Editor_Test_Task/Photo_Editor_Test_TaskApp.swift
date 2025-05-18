
import SwiftUI
import FirebaseCore
import GoogleSignIn
import GoogleSignInSwift

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }
}

@main
struct Photo_Editor_Test_TaskApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var appState = AppStateService.shared

    var body: some Scene {
        WindowGroup {
            NavigationView {
                if appState.isLoggedIn {
                    PhotoEditorView()
                        .environmentObject(appState)
                } else {
                    
                    AuthView()
                        .environmentObject(appState)
                }
            }
        }
    }
}
