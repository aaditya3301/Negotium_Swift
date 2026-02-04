import Foundation

enum Difficulty: String, CaseIterable {
    case beginner, medium, advanced, hard
}

struct Scenario: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let duration: Int
    let difficulty: Difficulty
    let color: String // Hex
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
}

struct AnalysisPoint: Identifiable {
    let id = UUID()
    let turn: Int
    let description: String
    let quote: String?
}

// Sample Data
struct MockData {
    static let scenarios = [
        Scenario(title: "Annual Salary Raise", description: "Negotiate a 20% raise with your manager.", icon: "dollarsign.circle", duration: 15, difficulty: .medium, color: "14b8a6"),
        Scenario(title: "Promotion Discussion", description: "Transition from Senior Dev to Lead.", icon: "briefcase", duration: 20, difficulty: .medium, color: "a855f7"),
        Scenario(title: "Client Rate Increase", description: "Convince a legacy client to accept new rates.", icon: "person.2", duration: 18, difficulty: .hard, color: "f59e0b"),
        Scenario(title: "Entry-Level Offer", description: "First job offer negotiation.", icon: "doc.text", duration: 12, difficulty: .beginner, color: "06b6d4"),
        Scenario(title: "Project Timeline", description: "Push back on an impossible deadline.", icon: "clock", duration: 10, difficulty: .advanced, color: "ef4444"),
        Scenario(title: "Vendor Contract", description: "Negotiate software licensing costs.", icon: "shippingbox", duration: 14, difficulty: .medium, color: "14b8a6")
    ]
    
    static let initialMessages = [
        ChatMessage(content: "Hello. I understand you wanted to discuss your compensation today. What's on your mind?", isUser: false, timestamp: Date())
    ]
    
    static let strengths = [
        AnalysisPoint(turn: 2, description: "Strong active listening", quote: "\"I understand budget is a concern...\""),
        AnalysisPoint(turn: 5, description: "Effective framing of value", quote: "delivered 30% revenue increase")
    ]
    
    static let mistakes = [
        AnalysisPoint(turn: 3, description: "Anchored too low", quote: "I was hoping for maybe 5%"),
        AnalysisPoint(turn: 7, description: "Apologized unnecessarily", quote: "Sorry to ask for this")
    ]
}
