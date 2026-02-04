
import SwiftUI

struct ScenariosView: View {
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Scenario Library")
                            .font(.largeTitle).bold()
                            .foregroundStyle(.white)
                        Text("Choose a simulation environment to practice.")
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .padding(.horizontal, 24)
                    
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(MockData.scenarios) { scenario in
                            NavigationLink(destination: NegotiationView(scenario: scenario)) {
                                ScenarioCard(scenario: scenario)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.top, 20)
            }
        }
    }
}

struct ScenarioCard: View {
    let scenario: Scenario
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top Row
            HStack(alignment: .top) {
                Image(systemName: scenario.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(Color(hex: scenario.color))
                    .frame(width: 44, height: 44)
                    .background(Color(hex: scenario.color).opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Spacer()
                
                Text(scenario.difficulty.rawValue.capitalized)
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.white.opacity(0.08))
                    .clipShape(Capsule())
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(16)
            
            Spacer()
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text(scenario.title)
                    .font(.subheadline).fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text(scenario.description)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 16)
            
            // Footer
            HStack {
                Image(systemName: "clock")
                Text("\(scenario.duration) min")
            }
            .font(.caption2)
            .foregroundStyle(.white.opacity(0.4))
            .padding(16)
        }
        .frame(height: 180)
        .glass()
    }
}
