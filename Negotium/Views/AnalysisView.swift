import SwiftUI
import Charts

struct AnalysisView: View {
    let sessionID: String // We need the ID to fetch data
    @Environment(\.dismiss) var dismiss
    
    @State private var analysis: AnalysisResponse?
    @State private var isLoading = true
    
    // Placeholder chart data (backend doesn't store per-turn leverage yet, so we keep this visual)
    let leverageData = [
        (turn: 1, val: 30), (turn: 2, val: 35), (turn: 3, val: 32),
        (turn: 4, val: 50), (turn: 5, val: 65), (turn: 6, val: 70)
    ]
    
    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            
            if isLoading {
                ProgressView("Analyzing Negotiation...")
                    .tint(.white)
                    .foregroundStyle(.white)
            } else if let data = analysis {
                ScrollView {
                    VStack(spacing: 30) {
                        
                        // Header
                        VStack(spacing: 16) {
                            Image(systemName: data.outcome == "Success" ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                                .font(.system(size: 64))
                                .foregroundStyle(data.outcome == "Success" ? Theme.teal : Theme.amber)
                                .shadow(color: (data.outcome == "Success" ? Theme.teal : Theme.amber).opacity(0.5), radius: 10)
                            
                            VStack(spacing: 8) {
                                Text("Negotiation \(data.outcome)")
                                    .font(.title2).bold()
                                    .foregroundStyle(.white)
                                
                                Text(data.summary)
                                    .font(.body)
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(.white.opacity(0.7))
                                    .padding(.horizontal, 20)
                            }
                        }
                        .padding(.top, 40)
                        
                        // Chart (Visual Only)
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Leverage Trajectory").font(.headline).foregroundStyle(.white)
                            Chart(leverageData, id: \.turn) { item in
                                LineMark(x: .value("Turn", item.turn), y: .value("Leverage", item.val))
                                    .foregroundStyle(Theme.purple)
                                    .interpolationMethod(.catmullRom)
                                    .lineStyle(StrokeStyle(lineWidth: 3))
                                
                                AreaMark(x: .value("Turn", item.turn), y: .value("Leverage", item.val))
                                    .foregroundStyle(LinearGradient(colors: [Theme.purple.opacity(0.3), .clear], startPoint: .top, endPoint: .bottom))
                            }
                            .frame(height: 180)
                            .chartYAxis { AxisMarks(position: .leading) }
                            .chartXAxis { AxisMarks(position: .bottom) }
                        }
                        .padding(20)
                        .glass()
                        
                        // Skill Gaps (Real Data)
                        if !data.skill_gaps.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "wrench.and.screwdriver.fill").foregroundStyle(Theme.amber)
                                    Text("Skill Gaps Detected").font(.headline).foregroundStyle(.white)
                                }
                                
                                VStack(spacing: 12) {
                                    ForEach(data.skill_gaps, id: \.self) { skill in
                                        SkillGapCard(skill: skill, reason: "Detected based on your transcript analysis.")
                                    }
                                }
                            }
                            .padding(20)
                            .glass()
                        }
                        
                        // Strengths & Mistakes (Real Data)
                        AnalysisSection(title: "Key Strengths", icon: "hand.thumbsup.fill", color: Theme.teal, points: data.strengths)
                        AnalysisSection(title: "Critical Mistakes", icon: "exclamationmark.triangle.fill", color: .red, points: data.mistakes)
                        
                        // Action
                        Button(action: { dismiss() }) {
                            Text("Return to Dashboard")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.teal, lineWidth: 1))
                                .foregroundStyle(Theme.teal)
                        }
                        .padding(.bottom, 40)
                    }
                    .padding(24)
                }
            }
        }
        .task {
            do {
                analysis = try await NetworkManager.shared.fetchAnalysis(sessionID: sessionID)
                isLoading = false
            } catch {
                print("Error fetching analysis: \(error)")
                isLoading = false
            }
        }
    }
}

// MARK: - Subcomponents

struct SkillGapCard: View {
    let skill: String
    let reason: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(skill)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text(reason)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            
            // ✅ Navigation Link to Learn View
            NavigationLink(destination: LearnSkillView(skillName: skill)) {
                Text("Learn")
                    .font(.caption).bold()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Theme.amber)
                    .foregroundStyle(.black)
                    .clipShape(Capsule())
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.03))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.05), lineWidth: 1))
    }
}

struct AnalysisSection: View {
    let title: String, icon: String, color: Color, points: [AnalysisPoint]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon).foregroundStyle(color)
                Text(title).font(.headline).foregroundStyle(.white)
            }
            
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(points.enumerated()), id: \.offset) { index, point in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(point.point)
                            .font(.subheadline).fontWeight(.bold)
                            .foregroundStyle(color)
                        Text(point.explanation)
                            .font(.subheadline).fontWeight(.medium)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    .padding(.vertical, 12)
                    
                    if index < points.count - 1 {
                        Divider().background(.white.opacity(0.1))
                    }
                }
            }
        }
        .padding(20)
        .glass()
    }
}
