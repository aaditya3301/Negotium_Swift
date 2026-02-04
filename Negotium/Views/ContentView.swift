import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn = false
    
    var body: some View {
        if isLoggedIn {
            // Using TabView for structure, though main interaction is in Dashboard
            TabView {
                DashboardView()
                    .tabItem {
                        Label("Dashboard", systemImage: "command")
                    }
                
                ScenariosView()
                    .tabItem {
                        Label("Scenarios", systemImage: "list.bullet.rectangle")
                    }
            }
            .preferredColorScheme(.dark)
            .tint(Theme.teal)
        } else {
            LandingView(isLoggedIn: $isLoggedIn)
                .preferredColorScheme(.dark)
        }
    }
}
