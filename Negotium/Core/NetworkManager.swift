import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "http://localhost:8000" // Ensure this matches your Python port
    
    // 1. Send Message to AI
    func sendToAI(scenario: String, messages: [ChatMessage], leverage: Double, sessionID: String?) async throws -> APIResponse {
        guard let url = URL(string: "\(baseURL)/negotiate") else { throw URLError(.badURL) }
        
        let apiHistory = messages.map { APIMessage(role: $0.isUser ? "user" : "assistant", content: $0.content) }
        
        let payload = APIRequest(
            scenario: scenario,
            history: apiHistory,
            current_leverage: leverage,
            session_id: sessionID
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(payload)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(APIResponse.self, from: data)
    }
    
    // 2. Fetch Session History
    func fetchSessions() async throws -> [SavedSession] {
        guard let url = URL(string: "\(baseURL)/sessions") else { throw URLError(.badURL) }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(SessionListResponse.self, from: data)
        return response.sessions
    }
    
    // 3. Fetch Full Analysis
    // 3. Fetch Full Analysis (Updated for better error handling)
        func fetchAnalysis(sessionID: String) async throws -> AnalysisResponse {
            guard let url = URL(string: "\(baseURL)/analyze/\(sessionID)") else { throw URLError(.badURL) }
            
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // Check if the server said "OK" (200)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                let errorText = String(data: data, encoding: .utf8) ?? "Unknown Error"
                print("❌ Server Error (\(httpResponse.statusCode)): \(errorText)")
                throw URLError(.badServerResponse)
            }
            
            return try JSONDecoder().decode(AnalysisResponse.self, from: data)
        }
}
