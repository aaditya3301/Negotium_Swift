import Foundation
import SwiftUI

// MARK: - Enums
enum Difficulty: String, CaseIterable, Codable {
    case beginner, medium, advanced, hard
}

// MARK: - App Models
struct Scenario: Identifiable, Hashable, Codable {
    let id: UUID
    let title: String
    let description: String
    let icon: String
    let duration: Int
    let difficulty: Difficulty
    let color: String // Hex
    
    init(id: UUID = UUID(), title: String, description: String, icon: String, duration: Int, difficulty: Difficulty, color: String) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.duration = duration
        self.difficulty = difficulty
        self.color = color
    }
}

struct ChatMessage: Identifiable, Codable {
    var id: UUID = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case content, isUser, timestamp
    }
    
    // Custom Init for manual creation
    init(id: UUID = UUID(), content: String, isUser: Bool, timestamp: Date) {
        self.id = id
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
    }
}

// MARK: - API Models
struct APIRequest: Codable {
    let scenario: String
    let history: [APIMessage]
    let current_leverage: Double
    let session_id: String?
}

struct APIMessage: Codable {
    let role: String
    let content: String
}

struct APIResponse: Codable {
    let opponent_reply: String
    let coach_tip: String
    let new_leverage: Double
    let new_mood: String
    let session_id: String
}

struct SessionListResponse: Codable {
    let sessions: [SavedSession]
    let count: Int
}

struct SavedSession: Codable, Identifiable {
    let id: String
    let scenario: String
    let leverage: Double
    let timestamp: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case scenario, leverage, timestamp
    }
}

struct AnalysisResponse: Codable {
    let summary: String
    let outcome: String
    let strengths: [AnalysisPoint]
    let mistakes: [AnalysisPoint]
    let skill_gaps: [String]
    let chat_history: [APIMessage]?
}

struct AnalysisPoint: Codable, Identifiable {
    var id: String { point }
    let point: String
    let explanation: String
}
