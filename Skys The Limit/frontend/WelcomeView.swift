import SwiftUI

struct WelcomeView: View {
    var body: some View {
        // Note: There is NO NavigationView here. It inherits it from ContentView.
        ZStack {
            Image("Space")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Spacer()
                Text("Welcome to")
                    .font(.custom("SpaceMono-Regular", size: 35))
                    .foregroundColor(.white)
                Text("Sky's The Limit")
                    .font(.custom("SpaceMono-Regular", size: 50))
                    .foregroundColor(.white)
                Spacer()
                Image("Comet")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 35))
                Spacer()

                // This link will now work because ContentView provides the NavigationView.
                NavigationLink(destination: MainMenuView()) {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 80, height: 80)
                        .background(Color.white)
                        .cornerRadius(20)
                }
                Spacer()
            }
            .navigationBarHidden(true)
        }
    }
}
