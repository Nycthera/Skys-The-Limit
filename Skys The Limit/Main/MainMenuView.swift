import SwiftUI

struct MainMenuView: View {
    var body: some View {
        ZStack(alignment: .top) {
            
//            Image("Home")
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//                .edgesIgnoringSafeArea(.all)
            
            GalaxyBackground()
                .ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 60) {
                Text("Let's start!")
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .padding(50)
                
                Image("Meteor")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
                NavigationLink(destination:  EquationListView()) {
                    Text("Draw The Stars")
                }
                .foregroundStyle(.white)
                .font(.largeTitle)
               
                
                NavigationLink(destination:  ConstellationView()) {
                    Text("My Galaxy")
                }
                .foregroundStyle(.white)
                .font(.largeTitle)
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}


struct GalaxyBackground: View {
    @State private var starAnimate = false
    @State private var starDrift = false
    @State private var fogShift = false
    @State private var fieldSpin = false

    var body: some View {
        ZStack {

            // this is the dark fade outer rhim like you know the camera setting
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.black
                ]),
                center: .center,
                startRadius: 50,
                endRadius: 900
            )
            .ignoresSafeArea()

            // the sparkly stars
            ZStack {
                ZStack {
                    ForEach(0..<120) { _ in
                        Circle()
                            .fill(Color.white.opacity(Double.random(in: 0.4...1)))
                            .frame(width: CGFloat.random(in: 2...6))
                            .position(
                                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                                y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                            )
                            .blur(radius: CGFloat.random(in: 2...6))
                            .opacity(starDrift ? Double.random(in: 0.2...1) : Double.random(in: 0.4...1))
                            .animation(
                                .easeInOut(duration: Double.random(in: 2...4))
                                .repeatForever(autoreverses: true),
                                value: starDrift
                            )
                    }
                }
                .blendMode(.screen)

                // smal sharp stars

                ZStack {
                    ForEach(0..<200) { _ in
                        Circle()
                            .fill(Color.white.opacity(Double.random(in: 0.1...1)))
                            .frame(width: CGFloat.random(in: 1...3))
                            .position(
                                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                                y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                            )
                            .offset(
                                x: starDrift ? CGFloat.random(in: -10...10) : 0,
                                y: starDrift ? CGFloat.random(in: -10...10) : 0
                            )
                            .animation(
                                .easeInOut(duration: Double.random(in: 3...6))
                                .repeatForever(autoreverses: true),
                                value: starDrift
                            )
                    }
                }
                .blendMode(.screen)
            }
            .ignoresSafeArea()
            .onAppear {
                starAnimate = true
                starDrift = true
                fogShift = true
                fieldSpin = true
            }
            .blendMode(.screen)
        }

    }
}

//#Preview {
//    MainMenuView()
//}
