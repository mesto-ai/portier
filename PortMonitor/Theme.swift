import SwiftUI

// Mesto AI Design System - Dark & Light Mode Support
struct MestoTheme {
    // Shared dark mode state
    static var isDark: Bool = true

    // Background Colors
    static var bg: Color { isDark ? Color(hex: "#0a0e1a") : Color(hex: "#f8f9fb") }
    static var surface: Color { isDark ? Color(hex: "#111827") : Color(hex: "#ffffff") }
    static var surfaceHover: Color { isDark ? Color(hex: "#1f1f24") : Color(hex: "#f0f1f3") }

    // Border Colors
    static var border: Color { isDark ? Color(hex: "#1e293b") : Color(hex: "#e2e5ea") }
    static var borderHover: Color { isDark ? Color(hex: "#334155") : Color(hex: "#cbd0d8") }

    // Text Colors
    static var text: Color { isDark ? Color(hex: "#e4e7eb") : Color(hex: "#111827") }
    static var textMuted: Color { isDark ? Color(hex: "#8b92a0") : Color(hex: "#6b7280") }
    static var textDim: Color { isDark ? Color(hex: "#64748b") : Color(hex: "#9ca3af") }

    // Accent Colors (same for both modes)
    static let accent = Color(hex: "#0066FF")
    static let accentMid = Color(hex: "#00CCFF")
    static let accentEnd = Color(hex: "#8A2BE2")
    static var accentHover: Color { isDark ? Color(hex: "#3385ff") : Color(hex: "#0052cc") }

    // Semantic Colors
    static let success = Color(hex: "#22c55e")
    static let error = Color(hex: "#ef4444")
    static let warning = Color(hex: "#f59e0b")

    // Category Colors
    static let green = Color(hex: "#22c55e")
    static let yellow = Color(hex: "#f59e0b")
    static let orange = Color(hex: "#fc6d26")
    static let red = Color(hex: "#ef4444")
    static let blue = Color(hex: "#0066FF")
    static let cyan = Color(hex: "#00CCFF")
    static let purple = Color(hex: "#8A2BE2")

    // Gradient
    static let mestoGradient = LinearGradient(
        colors: [accent, accentMid, accentEnd],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let mestoGradientDiagonal = LinearGradient(
        colors: [accent, accentMid, accentEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Radius
    static let radius: CGFloat = 8
    static let radiusLg: CGFloat = 12

    static func categoryColor(_ name: String) -> Color {
        switch name {
        case "green": return green
        case "yellow": return yellow
        case "orange": return orange
        case "red": return red
        case "blue": return blue
        case "cyan": return cyan
        case "purple": return purple
        default: return textMuted
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
