import SwiftUI

struct ContentView: View {
    var body: some View {
        // This NavigationView is the engine that makes all NavigationLinks work.
        NavigationView {
            // It starts by showing the WelcomeView.
            WelcomeView()
        }
        // This style is important for making navigation work consistently on iPad.
        .navigationViewStyle(.stack)
    }
}
