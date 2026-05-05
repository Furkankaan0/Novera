import SwiftUI

enum DesignColors {
    static let primary = Color(red: 0.05, green: 0.35, blue: 0.95)
    static let secondary = Color(red: 0.12, green: 0.78, blue: 0.63)
    static let accent = Color(red: 0.52, green: 0.38, blue: 0.96)
    static let warning = Color(red: 0.97, green: 0.64, blue: 0.12)
    static let danger = Color(red: 0.94, green: 0.23, blue: 0.29)
    static let success = Color(red: 0.18, green: 0.72, blue: 0.39)
    static let navy = Color(red: 0.03, green: 0.10, blue: 0.22)
    static let orange = Color(red: 0.96, green: 0.42, blue: 0.15)
    static let teal = Color(red: 0.02, green: 0.61, blue: 0.70)
    static let backgroundLight = Color(red: 0.96, green: 0.98, blue: 1.00)
    static let backgroundDark = Color(red: 0.02, green: 0.03, blue: 0.06)
    static let cardLight = Color.white.opacity(0.86)
    static let cardDark = Color(red: 0.08, green: 0.10, blue: 0.16).opacity(0.78)
    static let glassStroke = Color.white.opacity(0.28)
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary

    static func background(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? backgroundDark : backgroundLight
    }

    static func card(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? cardDark : cardLight
    }
}

struct AppBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            DesignColors.background(colorScheme).ignoresSafeArea()
            LinearGradient(
                colors: [
                    DesignColors.primary.opacity(colorScheme == .dark ? 0.28 : 0.18),
                    DesignColors.secondary.opacity(colorScheme == .dark ? 0.12 : 0.16),
                    DesignColors.accent.opacity(colorScheme == .dark ? 0.14 : 0.12)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
    }
}

struct GlassCardModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    var cornerRadius: CGFloat = 24

    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .background(DesignColors.card(colorScheme), in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(DesignColors.glassStroke, lineWidth: 1)
            )
            .shadow(color: .black.opacity(colorScheme == .dark ? 0.28 : 0.08), radius: 24, x: 0, y: 14)
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 24) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius))
    }
}
