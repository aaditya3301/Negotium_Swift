import SwiftUI

struct LandingView: View {
    @Binding var isLoggedIn: Bool
    @State private var animate = false
    
    var body: some View {
        ZStack {
            Theme.mainGradient.ignoresSafeArea()
            
            // Background Orbs
            Circle()
                .fill(Theme.orbGradient)
                .frame(width: 300, height: 300)
                .blur(radius: 60)
                .offset(x: animate ? -100 : 100, y: animate ? -100 : 100)
                .animation(.easeInOut(duration: 5).repeatForever(autoreverses: true), value: animate)
            
            VStack(spacing: 30) {
                Spacer()
                
                // Logo Icon
                Image(systemName: "brain.head.profile")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundStyle(LinearGradient(colors: [Theme.teal, Theme.purple], startPoint: .top, endPoint: .bottom))
                    .shadow(color: Theme.teal.opacity(0.5), radius: 20)
                
                Text("NEGOTIUM")
                    .font(.system(size: 40, weight: .heavy, design: .monospaced))
                    .tracking(5)
                    .foregroundStyle(.white)
                
                Text("Negotiate with Superhuman Intelligence")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                Spacer()
                
                PrimaryButton(title: "Start Simulation", icon: "play.fill") {
                    withAnimation { isLoggedIn = true }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
        .onAppear { animate = true }
    }
}
