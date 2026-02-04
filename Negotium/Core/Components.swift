
import SwiftUI

// Refined Glassmorphism: Smoother border, better shadow
struct GlassModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.08), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 5)
    }
}

extension View {
    func glass() -> some View {
        modifier(GlassModifier())
    }
}

// Refined Button: Better typography and haptic feel
struct PrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon { Image(systemName: icon).font(.headline) }
                Text(title).font(.headline).fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(colors: [Theme.purple, Theme.teal], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: Theme.teal.opacity(0.3), radius: 10, x: 0, y: 5)
            .contentShape(Rectangle())
        }
    }
}

struct CustomProgressBar: View {
    var value: Double
    var color: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.1))
                Capsule()
                    .fill(color)
                    .frame(width: max(0, min(geometry.size.width * value, geometry.size.width)))
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: value)
            }
        }
        .frame(height: 6)
    }
}
