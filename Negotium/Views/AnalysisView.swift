import SwiftUI
import Charts

struct AnalysisView: View {
    @Environment(\.dismiss) var dismiss
    
    // Mock Chart Data
    let leverageData = [
        (turn: 1, val: 30), (turn: 2, val: 35), (turn: 3, val: 32),
        (turn: 4, val: 50), (turn: 5, val: 65), (turn: 6, val: 70)
    ]
    
    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    
                    // Header
                    VStack(spacing: 10) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(Theme.teal)
                        
                        Text("Outcome: Success")
                            .font(.title).bold()
                            .foregroundStyle(.white)
                        
                        Text("You secured the 20% raise by effectively leveraging your recent project wins.")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.gray)
                            .padding(.horizontal)
                    }
                    .padding(.top, 40)
                    
                    // Chart
                    VStack(alignment: .leading) {
                        Text("Leverage Trajectory").font(.headline).foregroundStyle(.white)
                        Chart(leverageData, id: \.turn) { item in
                            LineMark(
                                x: .value("Turn", item.turn),
                                y: .value("Leverage", item.val)
                            )
                            .foregroundStyle(Theme.purple)
                            .interpolationMethod(.catmullRom)
                            
                            AreaMark(
                                x: .value("Turn", item.turn),
                                y: .value("Leverage", item.val)
                            )
                            .foregroundStyle(LinearGradient(colors: [Theme.purple.opacity(0.5), .clear], startPoint: .top, endPoint: .bottom))
                        }
                        .frame(height: 200)
                    }
                    .padding()
                    .glass()
                    
                    // Strengths
                    AnalysisSection(title: "Key Strengths", icon: "hand.thumbsup.fill", color: Theme.teal, points: MockData.strengths)
                    
                    // Mistakes
                    AnalysisSection(title: "Critical Mistakes", icon: "exclamationmark.triangle.fill", color: .red, points: MockData.mistakes)
                    
                    // Action
                    Button(action: {
                        // In a real app, reset nav stack. Here we just pop back.
                        dismiss()
                    }) {
                        Text("Back to Dashboard")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.teal, lineWidth: 1))
                            .foregroundStyle(Theme.teal)
                    }
                    .padding(.bottom, 40)
                }
                .padding()
            }
        }
    }
}

struct AnalysisSection: View {
    let title: String, icon: String, color: Color, points: [AnalysisPoint]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: icon).foregroundStyle(color)
                Text(title).font(.headline).foregroundStyle(.white)
            }
            
            ForEach(points) { point in
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text("Turn \(point.turn)").font(.caption2).bold()
                            .padding(4).background(color.opacity(0.2)).cornerRadius(4)
                            .foregroundStyle(color)
                        Text(point.description).font(.subheadline).bold().foregroundStyle(.white)
                    }
                    if let quote = point.quote {
                        Text(quote).font(.caption).italic().foregroundStyle(.gray)
                    }
                }
                .padding(.vertical, 4)
                Divider().background(.gray.opacity(0.3))
            }
        }
        .padding()
        .glass()
    }
}
