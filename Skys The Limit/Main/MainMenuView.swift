import SwiftUI

struct MainMenuView: View {
    @State private var isShowingTutorial = false   // <─ ADD THIS

    var body: some View {
        ZStack(alignment: .top) {

            Image("Home")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)

            VStack(alignment: .center, spacing: 30) {
                Text("Let's start!")
                    .font(.custom("SpaceMono-Regular", size: 55))
                    .foregroundColor(.white)
                    .padding(.top, 50)

                Spacer()

                VStack(alignment: .center, spacing: 50) {

                    
                    NavigationLink{
                        EquationListView()
                    }label:{
                        Text("Draw The Stars")
                            .frame(width: 350, height: 90)
                            .background(.white.opacity(0.7))
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                    }

                    NavigationLink{
                        ConstellationView()
                    }label:{
                        Text("My Galaxy")
                            .frame(width: 350, height: 90)
                            .background(.white.opacity(0.7))
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                    }
              
                    NavigationLink{
                        TutorialLevelOneView(isShowingTutorial: $isShowingTutorial)
                    }label:{
                        Text("Tutorial")
                            .frame(width: 350, height: 90)
                            .background(.white.opacity(0.7))
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                    }
                    
                }
                .font(.custom("SpaceMono-Regular", size: 45))
                .foregroundColor(.black)
                .padding(100)
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}
