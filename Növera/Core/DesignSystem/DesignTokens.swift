// DesignTokens.swift
// Növera — Design System Tokens
// Premium Health-Tech: Teal/Blue + Violet accents, Liquid Glass, SF Pro

import SwiftUI

// MARK: - Color Palette
enum NoveraColors {
    // Primary: Deep Teal-Blue — health-tech premium
    static let primary = Color(hue: 0.55, saturation: 0.78, brightness: 0.88)
    static let primaryDark = Color(hue: 0.55, saturation: 0.85, brightness: 0.65)
    static let primaryLight = Color(hue: 0.55, saturation: 0.45, brightness: 0.97)

    // Accent: Violet-Purple gradient
    static let accent = Color(hue: 0.72, saturation: 0.65, brightness: 0.90)
    static let accentGreen = Color(hue: 0.42, saturation: 0.70, brightness: 0.82)

    // Gradients
    static let primaryGradient = LinearGradient(
        colors: [
            Color(hue: 0.55, saturation: 0.78, brightness: 0.90),
            Color(hue: 0.62, saturation: 0.72, brightness: 0.85)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accentGradient = LinearGradient(
        colors: [
            Color(hue: 0.72, saturation: 0.65, brightness: 0.92),
            Color(hue: 0.78, saturation: 0.60, brightness: 0.85)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let heroGradient = LinearGradient(
        colors: [
            Color(hue: 0.55, saturation: 0.75, brightness: 0.35),
            Color(hue: 0.62, saturation: 0.80, brightness: 0.20),
            Color(hue: 0.68, saturation: 0.70, brightness: 0.15)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Backgrounds
    static let backgroundLight = Color(hue: 0.57, saturation: 0.04, brightness: 0.98)
    static let backgroundDark = Color(hue: 0.62, saturation: 0.20, brightness: 0.08)
    static let backgroundSecondaryLight = Color(hue: 0.57, saturation: 0.06, brightness: 0.95)
    static let backgroundSecondaryDark = Color(hue: 0.62, saturation: 0.18, brightness: 0.12)

    // Surface / Card
    static let surfaceLight = Color.white.opacity(0.85)
    static let surfaceDark = Color(hue: 0.62, saturation: 0.25, brightness: 0.16)

    // Text
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let textTertiary = Color(UIColor.tertiaryLabel)

    // Shift Type Colors
    static let shiftDay = Color(hue: 0.55, saturation: 0.65, brightness: 0.85)       // Day shift: teal
    static let shiftNight = Color(hue: 0.68, saturation: 0.60, brightness: 0.72)     // Night: violet
    static let shiftOncall = Color(hue: 0.08, saturation: 0.70, brightness: 0.90)    // On-call: amber
    static let shiftHoliday = Color(hue: 0.35, saturation: 0.65, brightness: 0.80)   // Holiday: green
    static let shiftOvertime = Color(hue: 0.95, saturation: 0.65, brightness: 0.85)  // Overtime: rose

    // Semantic
    static let success = Color(hue: 0.38, saturation: 0.65, brightness: 0.78)
    static let warning = Color(hue: 0.10, saturation: 0.80, brightness: 0.95)
    static let error = Color(hue: 0.02, saturation: 0.75, brightness: 0.85)
    static let info = Color(hue: 0.57, saturation: 0.65, brightness: 0.88)
}

// MARK: - Typography
enum NoveraFonts {
    static func largeTitle(_ weight: Font.Weight = .bold) -> Font {
        .system(size: 34, weight: weight, design: .default)
    }
    static func title1(_ weight: Font.Weight = .bold) -> Font {
        .system(size: 28, weight: weight, design: .default)
    }
    static func title2(_ weight: Font.Weight = .semibold) -> Font {
        .system(size: 22, weight: weight, design: .default)
    }
    static func title3(_ weight: Font.Weight = .semibold) -> Font {
        .system(size: 20, weight: weight, design: .default)
    }
    static func headline(_ weight: Font.Weight = .semibold) -> Font {
        .system(size: 17, weight: weight, design: .default)
    }
    static func body(_ weight: Font.Weight = .regular) -> Font {
        .system(size: 17, weight: weight, design: .default)
    }
    static func callout(_ weight: Font.Weight = .regular) -> Font {
        .system(size: 16, weight: weight, design: .default)
    }
    static func subheadline(_ weight: Font.Weight = .regular) -> Font {
        .system(size: 15, weight: weight, design: .default)
    }
    static func footnote(_ weight: Font.Weight = .regular) -> Font {
        .system(size: 13, weight: weight, design: .default)
    }
    static func caption(_ weight: Font.Weight = .regular) -> Font {
        .system(size: 12, weight: weight, design: .default)
    }
    // Numeric display — large stat numbers
    static func display(_ size: CGFloat = 48, _ weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}

// MARK: - Spacing
enum NoveraSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64
}

// MARK: - Corner Radius
enum NoveraRadius {
    static let sm: CGFloat = 12
    static let md: CGFloat = 18
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let full: CGFloat = 999
}

// MARK: - Shadows
enum NoveraShadows {
    static let soft = ShadowStyle(color: Color.black.opacity(0.06), radius: 16, x: 0, y: 4)
    static let medium = ShadowStyle(color: Color.black.opacity(0.10), radius: 24, x: 0, y: 8)
    static let strong = ShadowStyle(color: Color.black.opacity(0.16), radius: 32, x: 0, y: 12)
    static let primary = ShadowStyle(
        color: NoveraColors.primary.opacity(0.35),
        radius: 20,
        x: 0,
        y: 8
    )
}

struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Animation Presets
enum NoveraAnimation {
    static let spring = Animation.spring(response: 0.5, dampingFraction: 0.78)
    static let springFast = Animation.spring(response: 0.35, dampingFraction: 0.80)
    static let springBouncy = Animation.spring(response: 0.55, dampingFraction: 0.65)
    static let easeOut = Animation.easeOut(duration: 0.3)
    static let easeIn = Animation.easeIn(duration: 0.25)
    static let smooth = Animation.easeInOut(duration: 0.35)
    static let pageTransition = Animation.spring(response: 0.6, dampingFraction: 0.85)
}

// MARK: - View Modifiers
struct GlassBackground: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    var cornerRadius: CGFloat = NoveraRadius.lg
    var opacity: Double = 1.0

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(colorScheme == .dark
                        ? NoveraColors.surfaceDark.opacity(opacity)
                        : NoveraColors.surfaceLight.opacity(opacity)
                    )
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
                    .shadow(
                        color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.08),
                        radius: 20,
                        x: 0,
                        y: 6
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

struct PrimaryGradientBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(NoveraColors.primaryGradient)
    }
}

extension View {
    func glassBackground(cornerRadius: CGFloat = NoveraRadius.lg, opacity: Double = 1.0) -> some View {
        modifier(GlassBackground(cornerRadius: cornerRadius, opacity: opacity))
    }

    func primaryGradientBackground() -> some View {
        modifier(PrimaryGradientBackground())
    }

    func noveraShadow(_ style: ShadowStyle = NoveraShadows.soft) -> some View {
        shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }

    func scaleOnPress() -> some View {
        self.buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(NoveraAnimation.springFast, value: configuration.isPressed)
    }
}
