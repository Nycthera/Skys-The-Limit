import SwiftUI
import TipKit

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Draw the stars", systemImage: "scribble.variable") {
                DrawStarsMainView()
            }
            
            Tab("My Galaxy", systemImage: "square.grid.2x2" ) {
                MyConstellationView()
            }
        }
    }
}
