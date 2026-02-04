import SwiftUI

struct Theme {
    static let teal = Color(hex: "14b8a6")
    static let purple = Color(hex: "a855f7")
    static let amber = Color(hex: "f59e0b")
    static let bg = Color.black
    
    static let mainGradient = LinearGradient(
        colors: [Color.black, Color(hex: "0f172a")],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let orbGradient = AngularGradient(
        colors: [Theme.purple.opacity(0.3), Theme.teal.opacity(0.3), Theme.purple.opacity(0.3)],
        center: .center
    )
}

// Helper for Hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
