import SwiftUI

struct MainMenuView: View {
    @State private var isShowingTutorial = false   // <─ ADD THIS

    var body: some View {
        ZStack(alignment: .top) {

            Image("Home")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 30) {
                Text("Let's start!")
                    .font(.custom("SpaceMono-Regular", size: 45))
                    .foregroundColor(.white)
                    .padding(.top, 50)

                Spacer()

                VStack(alignment: .leading, spacing: 50) {

                    
                    NavigationLink{
                        EquationListView()
                    }label:{
                        Text("Draw The Stars")
                            .padding(20)
                            .background(.white.opacity(0.7))
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                    }

                    NavigationLink{
                        ConstellationView()
                    }label:{
                        Text("My Galaxy")
                            .padding(20)
                            .background(.white.opacity(0.7))
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                    }
              
                    NavigationLink{
                        TutorialLevelOneView(isShowingTutorial: $isShowingTutorial)
                    }label:{
                        Text("Tutorial")
                            .padding(20)
                            .background(.white.opacity(0.7))
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                    }
                    
                }
                .font(.custom("SpaceMono-Regular", size: 45))
                .foregroundColor(.black)

                Spacer()
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}
