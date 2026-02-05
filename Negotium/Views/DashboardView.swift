import SwiftUI

struct DashboardView: View {
    // State for Real Data
    @State private var sessions: [SavedSession] = []
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    
    // Computed Stats from Real Data
    var totalSessions: String {
        return "\(sessions.count)"
    }
    
    var hoursInvested: String {
        // Assuming avg session is 15 mins (0.25 hours)
        let hours = Double(sessions.count) * 0.25
        return String(format: "%.1f", hours)
    }
    
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
                                    .font(.title2).fontWeight(.bold)
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
                        
                        // Stats Grid (Dynamic Data)
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            StatCard(title: "Overall Score", value: "85%", icon: "chart.line.uptrend.xyaxis", color: Theme.teal)
                            StatCard(title: "Sessions", value: totalSessions, icon: "target", color: Theme.purple)
                            StatCard(title: "Hours", value: hoursInvested, icon: "clock", color: Theme.amber)
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
                        
                        // Recent Activity (Real Data)
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Recent Activity")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                Spacer()
                                if isLoading {
                                    ProgressView().tint(.white)
                                }
                            }
                            
                            // Error Message Display
                            if let error = errorMessage {
                                Text(error)
                                    .font(.caption)
                                    .foregroundStyle(.red)
                                    .padding(.bottom, 8)
                            }
                            
                            ScrollView(.vertical, showsIndicators: false) {
                                VStack(spacing: 12) {
                                    if sessions.isEmpty && !isLoading {
                                        Text("No sessions found. Start negotiating!")
                                            .font(.caption)
                                            .foregroundStyle(.white.opacity(0.5))
                                            .padding()
                                    } else {
                                        // Dynamic List from MongoDB
                                        ForEach(sessions) { session in
                                            NavigationLink(destination: AnalysisView(sessionID: session.id)) {
                                                ActivityRow(
                                                    title: session.scenario,
                                                    subtitle: "Leverage: \(Int(session.leverage * 100))%",
                                                    time: formatDate(session.timestamp)
                                                )
                                            }
                                        }
                                    }
                                }
                            }
                            .frame(height: 200)
                        }
                    }
                    .padding(24)
                }
            }
            .onAppear {
                // Only load if we don't have data yet
                if sessions.isEmpty {
                    loadData()
                }
            }
            .refreshable {
                loadData()
            }
        }
    }
    
    // MARK: - Bulletproof Data Loading
    func loadData() {
        isLoading = true
        errorMessage = nil
        
        // Use Task.detached to prevent SwiftUI from cancelling the request if the view updates
        Task.detached(priority: .userInitiated) {
            do {
                let fetchedSessions = try await NetworkManager.shared.fetchSessions()
                
                // Update UI on Main Thread
                await MainActor.run {
                    self.sessions = fetchedSessions
                    self.isLoading = false
                }
            } catch {
                // Ignore "Cancelled" errors (-999) because they are harmless
                if (error as NSError).code == -999 {
                    print("⚠️ Request cancelled (ignoring)")
                    return
                }
                
                print("❌ Failed to fetch sessions: \(error)")
                await MainActor.run {
                    self.errorMessage = "Failed to load history."
                    self.isLoading = false
                }
            }
        }
    }
    
    // Helper to format ISO date string
    func formatDate(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: isoString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "MMM d, h:mm a"
            return displayFormatter.string(from: date)
        }
        return "Just now"
    }
}

// Subcomponents
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
            
            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.3))
        }
        .padding(12)
        .glass()
    }
}
