import SwiftUI

struct NegotiationView: View {
    let scenario: Scenario
    @State private var messages: [ChatMessage] = MockData.initialMessages
    @State private var inputText: String = ""
    @State private var leverage: Double = 0.5
    @State private var patience: Double = 0.8
    @State private var showAnalysis = false
    
    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 1. Top Metrics Bar
                HStack(spacing: 20) {
                    MetricPill(label: "Leverage", value: leverage, color: Theme.teal)
                    MetricPill(label: "Patience", value: patience, color: Theme.purple)
                    Spacer()
                    Button("Abort") { showAnalysis = true }
                        .font(.caption).bold()
                        .foregroundColor(.red)
                }
                .padding()
                .background(.ultraThinMaterial)
                
                // 2. Chat Area
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(messages) { msg in
                                MessageBubble(message: msg)
                            }
                        }
                        .padding()
                        .id("ChatBottom")
                    }
                    .onChange(of: messages.count) { _ in
                        withAnimation { proxy.scrollTo("ChatBottom", anchor: .bottom) }
                    }
                }
                
                // 3. Shadow Coach Tip (Dynamic)
                if leverage < 0.6 {
                    HStack {
                        Image(systemName: "lightbulb.fill").foregroundColor(Theme.amber)
                        Text("Coach: Try asking open-ended questions to discover their BATNA.")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    .padding(8)
                    .background(Theme.amber.opacity(0.2))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
                
                // 4. Input Area
                HStack {
                    TextField("Type your response...", text: $inputText)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(25)
                        .foregroundStyle(.white)
                        .onSubmit { sendMessage() }
                    
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 35))
                            .foregroundStyle(inputText.isEmpty ? .gray : Theme.teal)
                    }
                    .disabled(inputText.isEmpty)
                }
                .padding()
                .background(.ultraThinMaterial)
            }
        }
        .navigationDestination(isPresented: $showAnalysis) {
            AnalysisView()
                .navigationBarBackButtonHidden(true)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text(scenario.title).font(.headline).foregroundStyle(.white)
                    Text("Time Remaining: 14:22").font(.caption).fontDesign(.monospaced).foregroundStyle(.gray)
                }
            }
        }
    }
    
    func sendMessage() {
        guard !inputText.isEmpty else { return }
        // User Message
        let newMsg = ChatMessage(content: inputText, isUser: true, timestamp: Date())
        messages.append(newMsg)
        inputText = ""
        
        // Simulating AI "Thinking"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let aiMsg = ChatMessage(content: "That's an interesting perspective. However, considering the budget constraints we discussed earlier, how do you propose we bridge the gap?", isUser: false, timestamp: Date())
            messages.append(aiMsg)
            // Update metrics
            withAnimation {
                leverage += 0.05
                patience -= 0.1
            }
        }
    }
}

// Subcomponents for Negotiation
struct MetricPill: View {
    let label: String, value: Double, color: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased()).font(.system(size: 10)).foregroundStyle(.gray)
            CustomProgressBar(value: value, color: color)
                .frame(width: 80)
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            
            Text(message.content)
                .padding()
                .background(message.isUser ? Theme.teal.opacity(0.8) : Color.white.opacity(0.1))
                .foregroundColor(.white)
                .cornerRadius(16)
                .frame(maxWidth: 280, alignment: message.isUser ? .trailing : .leading)
            
            if !message.isUser { Spacer() }
        }
    }
}
