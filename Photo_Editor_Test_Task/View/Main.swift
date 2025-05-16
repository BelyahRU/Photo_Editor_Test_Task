
import SwiftUI

struct MainView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome!")
                .font(.largeTitle)
                .bold()

            Text("Your email is verified. Enjoy the app!")
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
