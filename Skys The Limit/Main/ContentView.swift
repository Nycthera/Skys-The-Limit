import SwiftUI
import TipKit

struct ContentView: View {
    var body: some View {
        // This NavigationView is the engine that makes all NavigationLinks work.
        NavigationView {
            // It starts by showing the WelcomeView.
            MainMenuView()
                .task {
                    try? Tips.configure([
                        .datastoreLocation(.applicationDefault)
                    ])
                    
//                    //this is for testing tips make sure to remove later so th tip does not repeatedly appear everthing you restart the app
//                    try? Tips.resetDatastore()
//                    try? Tips.showAllTipsForTesting()
                }
        }

        .navigationBarHidden(true)
        .navigationViewStyle(.stack)
        .navigationBarBackButtonHidden(true)
        .navigationViewStyle(.stack)
    }
}
