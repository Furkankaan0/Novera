// GlassCard.swift
// Növera — Glass Card & Surface Components

import SwiftUI

// MARK: - Glass Card
struct GlassCard<Content: View>: View {
    let content: () -> Content
    var cornerRadius: CGFloat = NoveraRadius.lg
    var padding: CGFloat = NoveraSpacing.md
    var shadowStyle: ShadowStyle = NoveraShadows.soft

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        content()
            .padding(padding)
            .glassBackground(cornerRadius: cornerRadius)
            .noveraShadow(shadowStyle)
    }
}

// MARK: - Metric Card (for Dashboard stats)
struct MetricCard: View {
    let title: String
    let value: String
    let subtitle: String?
    let icon: String
    let color: Color
    var trend: TrendDirection?
    var trendValue: String?

    enum TrendDirection {
        case up, down, neutral
        var icon: String {
            switch self {
            case .up: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .neutral: return "minus"
            }
        }
        var color: Color {
            switch self {
            case .up: return NoveraColors.success
            case .down: return NoveraColors.error
            case .neutral: return NoveraColors.textSecondary
            }
        }
    }

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: NoveraSpacing.sm) {
            HStack {
                // Icon badge
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(color.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(color)
                }

                Spacer()

                if let trend, let trendValue {
                    HStack(spacing: 3) {
                        Image(systemName: trend.icon)
                            .font(.system(size: 11, weight: .semibold))
                        Text(trendValue)
                            .font(NoveraFonts.caption(.semibold))
                    }
                    .foregroundStyle(trend.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(trend.color.opacity(0.12))
                    )
                }
            }

            Text(value)
                .font(NoveraFonts.display(32))
                .foregroundStyle(NoveraColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(title)
                .font(NoveraFonts.footnote(.medium))
                .foregroundStyle(NoveraColors.textSecondary)

            if let subtitle {
                Text(subtitle)
                    .font(NoveraFonts.caption())
                    .foregroundStyle(NoveraColors.textTertiary)
            }
        }
        .padding(NoveraSpacing.md)
        .glassBackground(cornerRadius: NoveraRadius.lg)
        .noveraShadow(NoveraShadows.soft)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
}

// MARK: - Shift Preview Card
struct ShiftPreviewCard: View {
    let shift: Shift
    var isCompact: Bool = false

    var body: some View {
        HStack(spacing: NoveraSpacing.md) {
            // Color strip + type icon
            VStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(shift.shiftType.color)
                    .frame(width: 4)
            }
            .frame(height: isCompact ? 50 : 70)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(shift.title)
                        .font(NoveraFonts.headline(.semibold))
                        .foregroundStyle(NoveraColors.textPrimary)
                    Spacer()
                    ShiftTypeBadge(type: shift.shiftType)
                }

                HStack(spacing: NoveraSpacing.sm) {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                        .foregroundStyle(NoveraColors.textSecondary)
                    Text(shift.timeRangeFormatted)
                        .font(NoveraFonts.subheadline())
                        .foregroundStyle(NoveraColors.textSecondary)
                }

                if !isCompact {
                    HStack(spacing: NoveraSpacing.sm) {
                        Image(systemName: "mappin")
                            .font(.system(size: 12))
                            .foregroundStyle(NoveraColors.textTertiary)
                        Text(shift.location)
                            .font(NoveraFonts.caption())
                            .foregroundStyle(NoveraColors.textTertiary)
                    }
                }
            }
        }
        .padding(NoveraSpacing.md)
        .glassBackground(cornerRadius: NoveraRadius.md)
        .noveraShadow(NoveraShadows.soft)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(shift.title), \(shift.timeRangeFormatted), \(shift.location)")
    }
}

// MARK: - Shift Type Badge
struct ShiftTypeBadge: View {
    let type: ShiftType

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: type.icon)
                .font(.system(size: 10, weight: .semibold))
            Text(type.displayName)
                .font(NoveraFonts.caption(.semibold))
        }
        .foregroundStyle(type.color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(type.color.opacity(0.15))
        )
    }
}

// MARK: - Section Header
struct NoveraSectionHeader: View {
    let title: String
    var subtitle: String? = nil
    var action: (() -> Void)? = nil
    var actionTitle: String = "Tümü"

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(NoveraFonts.title3(.semibold))
                    .foregroundStyle(NoveraColors.textPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(NoveraFonts.caption())
                        .foregroundStyle(NoveraColors.textSecondary)
                }
            }
            Spacer()
            if let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(NoveraFonts.subheadline(.medium))
                        .foregroundStyle(NoveraColors.primary)
                }
                .accessibilityLabel("\(title) - \(actionTitle)")
            }
        }
    }
}

// MARK: - Empty State View
struct NoveraEmptyState: View {
    let icon: String
    let title: String
    let subtitle: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    @State private var iconScale: CGFloat = 1.0
    @State private var iconOpacity: Double = 0.7

    var body: some View {
        VStack(spacing: NoveraSpacing.lg) {
            ZStack {
                Circle()
                    .fill(NoveraColors.primary.opacity(0.08))
                    .frame(width: 100, height: 100)

                Circle()
                    .fill(NoveraColors.primary.opacity(0.05))
                    .frame(width: 130, height: 130)

                Image(systemName: icon)
                    .font(.system(size: 40, weight: .light))
                    .foregroundStyle(NoveraColors.primary.opacity(0.6))
                    .scaleEffect(iconScale)
                    .opacity(iconOpacity)
            }
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)
                ) {
                    iconScale = 1.05
                    iconOpacity = 1.0
                }
            }

            VStack(spacing: NoveraSpacing.xs) {
                Text(title)
                    .font(NoveraFonts.title3(.semibold))
                    .foregroundStyle(NoveraColors.textPrimary)
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(NoveraFonts.callout())
                    .foregroundStyle(NoveraColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, NoveraSpacing.xl)
            }

            if let actionTitle, let action {
                NoveraPrimaryButton(actionTitle, isFullWidth: false, action: action)
            }
        }
        .padding(NoveraSpacing.xl)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            MetricCard(
                title: "Bu Hafta",
                value: "42s",
                subtitle: "Normal 40s",
                icon: "clock.fill",
                color: NoveraColors.primary,
                trend: .up,
                trendValue: "+2s"
            )

            NoveraEmptyState(
                icon: "calendar.badge.plus",
                title: "Henüz vardiya yok",
                subtitle: "İlk vardiyenizi ekleyerek başlayın",
                actionTitle: "Vardiya Ekle",
                action: {}
            )
        }
        .padding()
    }
}
