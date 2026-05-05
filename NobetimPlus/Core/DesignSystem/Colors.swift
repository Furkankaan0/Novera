import SwiftUI

enum DesignColors {
    static let primary = Color(red: 0.12, green: 0.39, blue: 1.00)
    static let secondary = Color(red: 0.10, green: 0.90, blue: 0.72)
    static let accent = Color(red: 0.58, green: 0.32, blue: 1.00)
    static let warning = Color(red: 1.00, green: 0.68, blue: 0.18)
    static let danger = Color(red: 0.98, green: 0.22, blue: 0.36)
    static let success = Color(red: 0.18, green: 0.82, blue: 0.44)
    static let navy = Color(red: 0.03, green: 0.08, blue: 0.24)
    static let orange = Color(red: 1.00, green: 0.48, blue: 0.17)
    static let teal = Color(red: 0.05, green: 0.70, blue: 0.82)

    static let cinematicVoid = Color(red: 0.03, green: 0.01, blue: 0.10)
    static let cinematicMidnight = Color(red: 0.04, green: 0.05, blue: 0.18)
    static let cinematicRoyal = Color(red: 0.18, green: 0.05, blue: 0.72)
    static let cinematicViolet = Color(red: 0.48, green: 0.16, blue: 1.00)
    static let cinematicInk = Color(red: 0.06, green: 0.07, blue: 0.16)

    static let backgroundLight = Color(red: 0.95, green: 0.97, blue: 1.00)
    static let backgroundDark = cinematicVoid
    static let cardLight = Color.white.opacity(0.84)
    static let cardDark = Color(red: 0.08, green: 0.07, blue: 0.18).opacity(0.74)
    static let glassStroke = Color.white.opacity(0.24)
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary

    static func background(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? backgroundDark : backgroundLight
    }

    static func card(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? cardDark : cardLight
    }
}

struct CinematicBackground: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animate = false

    var body: some View {
        ZStack {
            baseGradient
            glowLayer
            vignette
        }
        .ignoresSafeArea()
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }

    private var baseGradient: some View {
        LinearGradient(
            colors: colorScheme == .dark
                ? [DesignColors.cinematicVoid, DesignColors.cinematicMidnight, Color(red: 0.10, green: 0.02, blue: 0.30)]
                : [Color(red: 0.98, green: 0.99, blue: 1.00), Color(red: 0.90, green: 0.94, blue: 1.00), Color(red: 0.95, green: 0.91, blue: 1.00)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var glowLayer: some View {
        ZStack {
            CinematicGlow(color: DesignColors.cinematicRoyal, size: 360)
                .offset(x: animate ? -110 : -180, y: animate ? -220 : -130)
            CinematicGlow(color: DesignColors.accent, size: 300)
                .offset(x: animate ? 180 : 130, y: animate ? -70 : -150)
            CinematicGlow(color: DesignColors.secondary, size: 260)
                .offset(x: animate ? 120 : 190, y: animate ? 360 : 280)
            CinematicGlow(color: DesignColors.primary, size: 220)
                .offset(x: animate ? -210 : -140, y: animate ? 230 : 330)
        }
        .opacity(colorScheme == .dark ? 0.78 : 0.42)
        .blur(radius: reduceMotion ? 44 : 34)
        .allowsHitTesting(false)
    }

    private var vignette: some View {
        RadialGradient(
            colors: [
                Color.clear,
                (colorScheme == .dark ? Color.black : Color.white).opacity(colorScheme == .dark ? 0.36 : 0.22)
            ],
            center: .center,
            startRadius: 160,
            endRadius: 620
        )
    }
}

private struct CinematicGlow: View {
    var color: Color
    var size: CGFloat

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [color.opacity(0.95), color.opacity(0.24), .clear],
                    center: .center,
                    startRadius: 4,
                    endRadius: size / 2
                )
            )
            .frame(width: size, height: size)
    }
}

struct AppBackground: View {
    var body: some View {
        CinematicBackground()
    }
}

struct GlassCardModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    var cornerRadius: CGFloat = 24

    func body(content: Content) -> some View {
        content
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .background(DesignColors.card(colorScheme), in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(colorScheme == .dark ? 0.34 : 0.70),
                                DesignColors.accent.opacity(0.22),
                                DesignColors.primary.opacity(0.16)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .shadow(color: DesignColors.accent.opacity(colorScheme == .dark ? 0.18 : 0.08), radius: 20, x: 0, y: 12)
            .shadow(color: .black.opacity(colorScheme == .dark ? 0.26 : 0.08), radius: 18, x: 0, y: 10)
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 24) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius))
    }
}
