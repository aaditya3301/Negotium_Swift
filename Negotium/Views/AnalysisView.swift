
import SwiftUI
import Charts

struct AnalysisView: View {
    @Environment(\.dismiss) var dismiss
    
    let leverageData = [
        (turn: 1, val: 30), (turn: 2, val: 35), (turn: 3, val: 32),
        (turn: 4, val: 50), (turn: 5, val: 65), (turn: 6, val: 70)
    ]
    
    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(Theme.teal)
                            .shadow(color: Theme.teal.opacity(0.5), radius: 10)
                        
                        VStack(spacing: 8) {
                            Text("Negotiation Successful")
                                .font(.title2).bold()
                                .foregroundStyle(.white)
                            
                            Text("You secured the 20% raise by effectively leveraging your recent project wins.")
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.white.opacity(0.7))
                                .padding(.horizontal, 20)
                        }
                    }
                    .padding(.top, 40)
                    
                    // Chart
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
                    
                    // New Skill Weakness Section (Prominent Placement)
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "wrench.and.screwdriver.fill").foregroundStyle(Theme.amber)
                            Text("Skill Gaps Detected").font(.headline).foregroundStyle(.white)
                        }
                        
                        VStack(spacing: 12) {
                            SkillGapCard(skill: "Next.js", reason: "Struggled with SSR concepts during technical discussion.")
                            SkillGapCard(skill: "AWS Cloud", reason: "Unsure about deployment architecture costs.")
                        }
                    }
                    .padding(20)
                    .glass()
                    
                    // Strengths & Mistakes
                    AnalysisSection(title: "Key Strengths", icon: "hand.thumbsup.fill", color: Theme.teal, points: MockData.strengths)
                    AnalysisSection(title: "Critical Mistakes", icon: "exclamationmark.triangle.fill", color: .red, points: MockData.mistakes)
                    
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
}

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
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(points.enumerated()), id: \.offset) { index, point in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Turn \(point.turn)")
                                    .font(.system(size: 10, weight: .bold))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(color.opacity(0.15))
                                    .cornerRadius(4)
                                    .foregroundStyle(color)
                                Text(point.description)
                                    .font(.subheadline).fontWeight(.medium)
                                    .foregroundStyle(.white.opacity(0.9))
                            }
                            if let quote = point.quote {
                                Text(quote)
                                    .font(.caption).italic()
                                    .foregroundStyle(.white.opacity(0.5))
                                    .padding(.leading, 4)
                            }
                        }
                        .padding(.vertical, 12)
                        
                        if index < points.count - 1 {
                            Divider().background(.white.opacity(0.1))
                        }
                    }
                }
            }
            .frame(height: 140)
        }
        .padding(20)
        .glass()
    }
}
