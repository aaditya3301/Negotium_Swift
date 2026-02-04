import SwiftUI

struct DashboardView: View {
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Command Center")
                                    .font(.largeTitle).bold()
                                    .foregroundStyle(.white)
                                Text("Welcome back, Agent")
                                    .foregroundStyle(.gray)
                            }
                            Spacer()
                            Circle()
                                .fill(Theme.teal)
                                .frame(width: 40, height: 40)
                                .overlay(Text("TK").font(.caption).bold())
                        }
                        
                        // Stats Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            StatCard(title: "Overall Score", value: "85%", icon: "chart.line.uptrend.xyaxis", color: Theme.teal)
                            StatCard(title: "Sessions", value: "12", icon: "target", color: Theme.purple)
                            StatCard(title: "Hours", value: "4.5", icon: "clock", color: Theme.amber)
                            StatCard(title: "Scenarios", value: "6/8", icon: "building.2", color: .cyan)
                        }
                        
                        // Hero Action
                        NavigationLink(destination: ScenariosView()) {
                            HStack {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        Image(systemName: "bolt.fill")
                                        Text("RECOMMENDED")
                                    }
                                    .font(.caption).bold()
                                    .foregroundStyle(Theme.teal)
                                    
                                    Text("Start New Simulation")
                                        .font(.title3).bold()
                                        .foregroundStyle(.white)
                                    
                                    Text("Continue your training in the Salary Negotiation module.")
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                        .multilineTextAlignment(.leading)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                            .padding()
                            .glass()
                        }
                        
                        // Activity Feed
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Recent Activity").font(.headline).foregroundStyle(.white)
                            ActivityRow(title: "Scenario Completed", subtitle: "Annual Salary Raise • Score 82%", time: "2h ago")
                            ActivityRow(title: "Account Created", subtitle: "Welcome to Negotium", time: "1d ago")
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

// Subcomponents for Dashboard
struct StatCard: View {
    let title: String, value: String, icon: String, color: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            // FIX IS HERE: Changed .font(.25) to .font(.system(size: 25))
            Text(value)
                .font(.system(size: 25))
                .bold()
                .foregroundStyle(.white)
            
            Text(title).font(.caption).foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .glass()
    }
}

struct ActivityRow: View {
    let title: String, subtitle: String, time: String
    var body: some View {
        HStack {
            Circle().fill(Theme.teal.opacity(0.2)).frame(width: 40, height: 40)
                .overlay(Image(systemName: "list.bullet").font(.caption).foregroundStyle(Theme.teal))
            VStack(alignment: .leading) {
                Text(title).font(.subheadline).bold().foregroundStyle(.white)
                Text(subtitle).font(.caption).foregroundStyle(.gray)
            }
            Spacer()
            Text(time).font(.caption2).fontDesign(.monospaced).foregroundStyle(.gray)
        }
        .padding()
        .glass()
    }
}
