
import SwiftUI

struct DashboardView: View {
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Command Center")
                                    .font(.title2).fontWeight(.bold) // FIXED: Changed .weight to .fontWeight
                                    .foregroundStyle(.white)
                                Text("Welcome back, Agent")
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.6))
                            }
                            Spacer()
                            Circle()
                                .fill(LinearGradient(colors: [Theme.teal, Theme.purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 44, height: 44)
                                .overlay(Text("TK").font(.subheadline).bold().foregroundStyle(.white))
                                .shadow(color: Theme.purple.opacity(0.4), radius: 8)
                        }
                        
                        // Stats Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            StatCard(title: "Overall Score", value: "85%", icon: "chart.line.uptrend.xyaxis", color: Theme.teal)
                            StatCard(title: "Sessions", value: "12", icon: "target", color: Theme.purple)
                            StatCard(title: "Hours", value: "4.5", icon: "clock", color: Theme.amber)
                            StatCard(title: "Scenarios", value: "6/8", icon: "building.2", color: .cyan)
                        }
                        
                        // Hero Action
                        NavigationLink(destination: ScenariosView()) {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "bolt.fill")
                                            .font(.caption2)
                                        Text("RECOMMENDED")
                                            .font(.caption).fontWeight(.bold)
                                            .tracking(1)
                                    }
                                    .foregroundStyle(Theme.teal)
                                    
                                    Text("Start New Simulation")
                                        .font(.title3).fontWeight(.semibold)
                                        .foregroundStyle(.white)
                                    
                                    Text("Continue your training in the Salary Negotiation module.")
                                        .font(.subheadline)
                                        .foregroundStyle(.white.opacity(0.7))
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(2)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.white.opacity(0.3))
                            }
                            .padding(20)
                            .glass()
                        }
                        
                        // Recent Activity
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Recent Activity")
                                .font(.headline)
                                .foregroundStyle(.white)
                            
                            ScrollView(.vertical, showsIndicators: false) {
                                VStack(spacing: 12) {
                                    ActivityRow(title: "Scenario Completed", subtitle: "Annual Salary Raise • Score 82%", time: "2h ago")
                                    ActivityRow(title: "Account Created", subtitle: "Welcome to Negotium", time: "1d ago")
                                    ActivityRow(title: "Practice Session", subtitle: "Vendor Contract • Score 65%", time: "2d ago")
                                    ActivityRow(title: "Login", subtitle: "Web Dashboard", time: "3d ago")
                                }
                            }
                            .frame(height: 200)
                        }
                    }
                    .padding(24)
                }
            }
        }
    }
}

struct StatCard: View {
    let title: String, value: String, icon: String, color: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(color)
                    .padding(8)
                    .background(color.opacity(0.1))
                    .clipShape(Circle())
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .padding(16)
        .glass()
    }
}

struct ActivityRow: View {
    let title: String, subtitle: String, time: String
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Circle()
                .fill(Theme.surface)
                .frame(width: 40, height: 40)
                .overlay(Image(systemName: "list.bullet").font(.caption).foregroundStyle(Theme.teal))
                .overlay(Circle().stroke(.white.opacity(0.1), lineWidth: 1))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline).fontWeight(.medium)
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }
            Spacer()
            Text(time)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.3))
        }
        .padding(12)
        .glass()
    }
}
