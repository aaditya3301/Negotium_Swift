import SwiftUI

// 1. The Glassmorphic Background Modifier
struct GlassModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

extension View {
    func glass() -> some View {
        modifier(GlassModifier())
    }
}

// 2. Gradient Primary Button
struct PrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if let icon = icon { Image(systemName: icon) }
                Text(title).fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(colors: [Theme.purple, Theme.teal], startPoint: .leading, endPoint: .trailing)
            )
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(color: Theme.teal.opacity(0.4), radius: 8, x: 0, y: 4)
        }
    }
}

// 3. Simple Progress Bar
struct CustomProgressBar: View {
    var value: Double // 0.0 to 1.0
    var color: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.1))
                Capsule()
                    .fill(color)
                    .frame(width: geometry.size.width * value)
                    .animation(.spring(), value: value)
            }
        }
        .frame(height: 6)
    }
}
