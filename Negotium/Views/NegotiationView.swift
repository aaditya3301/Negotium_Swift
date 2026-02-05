import SwiftUI
import Combine

struct NegotiationView: View {
    let scenario: Scenario
    
    @State private var messages: [ChatMessage] = [
        ChatMessage(
            content: "Hello. I understand you wanted to discuss the terms. What is on your mind?",
            isUser: false,
            timestamp: Date()
        )
    ]
    
    @State private var inputText: String = ""
    @State private var leverage: Double = 0.5
    @State private var patience: Double = 0.8
    @State private var showAnalysis = false
    @State private var sessionID: String? = nil // Tracks DB session
    
    // Timer Logic
    @State private var timeRemaining: Int = 900 // 15 minutes
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Helper to format time
    func timeString(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            
            // Background Glow
            Circle()
                .fill(Theme.teal.opacity(0.05))
                .frame(width: 300, height: 300)
                .blur(radius: 100)
                .offset(x: -100, y: -200)
            
            VStack(spacing: 0) {
                // 1. Top Bar
                HStack(alignment: .center, spacing: 16) {
                    MetricPill(label: "Leverage", value: leverage, color: Theme.teal)
                    MetricPill(label: "Patience", value: patience, color: Theme.purple)
                    Spacer()
                    Button { showAnalysis = true } label: {
                        Text("End")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white.opacity(0.8))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.05))
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color.white.opacity(0.1), lineWidth: 1))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
                .overlay(Rectangle().frame(height: 1).foregroundColor(.white.opacity(0.05)), alignment: .bottom)
                
                // 2. Chat Area
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            Color.clear.frame(height: 20)
                            ForEach(messages) { msg in
                                ChatRow(message: msg)
                                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                            }
                            Color.clear.frame(height: 20)
                        }
                        .padding(.horizontal, 16)
                        .id("ChatBottom")
                    }
                    .onChange(of: messages.count) { _ in
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            proxy.scrollTo("ChatBottom", anchor: .bottom)
                        }
                    }
                }
                
                // 3. Input Bar
                HStack(spacing: 12) {
                    TextField("Type your response...", text: $inputText)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(Color.white.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .overlay(RoundedRectangle(cornerRadius: 24).stroke(.white.opacity(0.1), lineWidth: 1))
                        .foregroundStyle(.white)
                        .onSubmit { sendMessage() }
                    
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.black)
                            .frame(width: 40, height: 40)
                            .background(inputText.isEmpty ? Color.white.opacity(0.2) : Theme.teal)
                            .clipShape(Circle())
                    }
                    .disabled(inputText.isEmpty)
                }
                .padding(16)
                .background(Theme.bg.opacity(0.95))
            }
        }
        .navigationDestination(isPresented: $showAnalysis) {
            // FIX: Pass the sessionID to AnalysisView.
            // If sessionID is nil (user ended early), pass empty string or handle it
            if let id = sessionID {
                AnalysisView(sessionID: id).navigationBarBackButtonHidden(true)
            } else {
                 // Fallback if no session was started (e.g. just viewed page)
                 AnalysisView(sessionID: "").navigationBarBackButtonHidden(true)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text(scenario.title).font(.headline).foregroundStyle(.white)
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                        Text(timeString(time: timeRemaining)).monospacedDigit()
                    }
                    .font(.caption2)
                    .foregroundStyle(timeRemaining < 60 ? .red : .gray)
                }
            }
        }
        .onReceive(timer) { _ in
            if timeRemaining > 0 { timeRemaining -= 1 }
        }
    }
    
    func sendMessage() {
        guard !inputText.isEmpty else { return }
        let newMsg = ChatMessage(content: inputText, isUser: true, timestamp: Date())
        
        withAnimation {
            messages.append(newMsg)
            inputText = ""
        }
        
        Task {
            do {
                // FIXED: Now passing 'sessionID' correctly
                let response = try await NetworkManager.shared.sendToAI(
                    scenario: scenario.title,
                    messages: messages,
                    leverage: leverage,
                    sessionID: sessionID
                )
                
                DispatchQueue.main.async {
                    let aiMsg = ChatMessage(content: response.opponent_reply, isUser: false, timestamp: Date())
                    
                    withAnimation {
                        messages.append(aiMsg)
                        leverage = response.new_leverage
                        patience = max(0.0, patience - 0.05)
                        self.sessionID = response.session_id // Update Session ID
                    }
                }
            } catch {
                print("Error: \(error)")
            }
        }
    }
}

// Subcomponents (ChatRow, MetricPill)
struct ChatRow: View {
    let message: ChatMessage
    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            if !message.isUser {
                Circle().fill(LinearGradient(colors: [Theme.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing)).frame(width: 30, height: 30).overlay(Image(systemName: "brain.head.profile").font(.system(size: 14)).foregroundStyle(.white))
            } else { Spacer() }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.body).lineSpacing(4)
                    .padding(.horizontal, 14).padding(.vertical, 10)
                    .background(message.isUser ? Theme.teal : Color(hex: "1F2937"))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .mask(RoundedCorner(radius: 18, corners: message.isUser ? [.topLeft, .topRight, .bottomLeft] : [.topLeft, .topRight, .bottomRight]))
            }
            .frame(maxWidth: 260, alignment: message.isUser ? .trailing : .leading)
            
            if message.isUser {
                Circle().fill(Color(hex: "2d2d2d")).frame(width: 30, height: 30).overlay(Text("TK").font(.system(size: 10, weight: .bold)).foregroundStyle(Theme.teal)).overlay(Circle().stroke(Theme.teal.opacity(0.3), lineWidth: 1))
            } else { Spacer() }
        }
    }
}

struct MetricPill: View {
    let label: String, value: Double, color: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label.uppercased()).font(.system(size: 9, weight: .bold)).foregroundStyle(.gray)
                Spacer()
                Text("\(Int(value * 100))%").font(.system(size: 9, weight: .bold)).foregroundStyle(color)
            }
            CustomProgressBar(value: value, color: color).frame(width: 70)
        }
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
