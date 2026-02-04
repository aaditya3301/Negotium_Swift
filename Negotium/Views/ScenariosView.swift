import SwiftUI

struct ScenariosView: View {
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Scenario Library")
                        .font(.largeTitle).bold()
                        .foregroundStyle(.white)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(MockData.scenarios) { scenario in
                            NavigationLink(destination: NegotiationView(scenario: scenario)) {
                                ScenarioCard(scenario: scenario)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

struct ScenarioCard: View {
    let scenario: Scenario
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: scenario.icon)
                    .padding(8)
                    .background(Color(hex: scenario.color).opacity(0.2))
                    .cornerRadius(8)
                    .foregroundStyle(Color(hex: scenario.color))
                Spacer()
                Text(scenario.difficulty.rawValue.capitalized)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.white.opacity(0.1))
                    .cornerRadius(4)
                    .foregroundStyle(.white)
            }
            
            Text(scenario.title)
                .font(.headline)
                .foregroundStyle(.white)
                .lineLimit(1)
            
            Text(scenario.description)
                .font(.caption)
                .foregroundStyle(.gray)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            HStack {
                Image(systemName: "clock")
                Text("\(scenario.duration) min")
            }
            .font(.caption2)
            .foregroundStyle(.gray)
        }
        .padding()
        .frame(height: 160)
        .glass()
    }
}
