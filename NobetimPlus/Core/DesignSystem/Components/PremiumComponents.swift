import SwiftUI

struct PremiumGlassPanel<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    private let cornerRadius: CGFloat
    private let content: Content

    init(cornerRadius: CGFloat = 28, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    var body: some View {
        content
            .padding(Spacing.large)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassCard(cornerRadius: cornerRadius)
            .overlay(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(colorScheme == .dark ? 0.12 : 0.42),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .center
                        )
                    )
                    .blendMode(.screen)
                    .allowsHitTesting(false)
            }
    }
}

struct BrandHeroMark: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var floating = false
    var size: CGFloat = 220
    var showTitle = true
    var subtitle: String? = nil

    var body: some View {
        VStack(spacing: Spacing.medium) {
            ZStack {
                Circle()
                    .fill(DesignColors.cinematicRoyal.opacity(0.28))
                    .frame(width: size * 1.08, height: size * 1.08)
                    .blur(radius: 22)
                    .scaleEffect(floating ? 1.08 : 0.94)

                Image("BrandLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .shadow(color: DesignColors.accent.opacity(0.58), radius: 26, x: 0, y: 18)
                    .shadow(color: DesignColors.primary.opacity(0.38), radius: 34, x: -14, y: -10)
                    .rotation3DEffect(.degrees(reduceMotion ? 0 : (floating ? 3.5 : -2.5)), axis: (x: 0.8, y: -0.8, z: 0.0))
                    .scaleEffect(reduceMotion ? 1 : (floating ? 1.025 : 0.985))

                Image("BrandLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: size * 0.82, height: size * 0.82)
                    .blur(radius: 18)
                    .opacity(0.20)
                    .offset(y: size * 0.30)
                    .scaleEffect(x: 1, y: -0.24, anchor: .center)
                    .mask(
                        LinearGradient(colors: [.clear, .white.opacity(0.5), .clear], startPoint: .top, endPoint: .bottom)
                    )
                    .accessibilityHidden(true)
            }
            .frame(width: size * 1.12, height: size * 1.05)
            .accessibilityHidden(true)

            if showTitle {
                VStack(spacing: 6) {
                    Text("Nöbetim+")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, DesignColors.secondary.opacity(0.92), DesignColors.accent.opacity(0.88)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: DesignColors.accent.opacity(0.38), radius: 18, y: 8)
                        .minimumScaleFactor(0.72)

                    if let subtitle {
                        Text(subtitle)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .accessibilityElement(children: .combine)
            }
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 4.2).repeatForever(autoreverses: true)) {
                floating = true
            }
        }
    }
}

struct PremiumCTAButton: View {
    var title: String
    var systemImage: String = "arrow.right"
    var tint: Color = DesignColors.primary
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Text(title)
                    .font(.headline.weight(.bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                Image(systemName: systemImage)
                    .font(.headline.weight(.bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 56)
            .background(
                LinearGradient(colors: [tint, DesignColors.accent, DesignColors.secondary.opacity(0.86)], startPoint: .topLeading, endPoint: .bottomTrailing),
                in: RoundedRectangle(cornerRadius: 19, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 19, style: .continuous)
                    .stroke(Color.white.opacity(0.30), lineWidth: 1)
            }
            .shadow(color: tint.opacity(0.36), radius: 20, x: 0, y: 14)
        }
        .buttonStyle(.plain)
        .frame(minHeight: 56)
        .accessibilityLabel(title)
    }
}

struct ShiftStatusCapsule: View {
    var title: String
    var subtitle: String? = nil
    var color: Color = DesignColors.secondary
    var systemImage: String = "sparkles"

    var body: some View {
        HStack(spacing: 9) {
            Image(systemName: systemImage)
                .font(.caption.weight(.black))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.caption.weight(.bold))
                if let subtitle {
                    Text(subtitle)
                        .font(.caption2.weight(.semibold))
                        .opacity(0.72)
                }
            }
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(color.opacity(0.26), in: Capsule())
        .overlay(Capsule().stroke(color.opacity(0.58), lineWidth: 1))
        .shadow(color: color.opacity(0.22), radius: 12, y: 7)
        .accessibilityElement(children: .combine)
    }
}

struct CinematicMetricCard: View {
    var title: String
    var value: String
    var footnote: String
    var color: Color
    var systemImage: String

    var body: some View {
        PremiumGlassPanel(cornerRadius: 22) {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                HStack {
                    Image(systemName: systemImage)
                        .font(.headline.weight(.black))
                        .foregroundStyle(.white)
                        .frame(width: 38, height: 38)
                        .background(color.opacity(0.30), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 13, style: .continuous)
                                .stroke(color.opacity(0.62), lineWidth: 1)
                        }
                        .accessibilityHidden(true)
                    Spacer()
                    Circle()
                        .fill(color.opacity(0.58))
                        .frame(width: 8, height: 8)
                        .shadow(color: color.opacity(0.7), radius: 10)
                        .accessibilityHidden(true)
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text(value)
                        .font(.system(.title2, design: .rounded, weight: .black))
                        .minimumScaleFactor(0.76)
                    Text(title)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                    Text(footnote)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}

struct PremiumMetricCard: View {
    var title: String
    var value: String
    var footnote: String
    var color: Color
    var systemImage: String

    var body: some View {
        CinematicMetricCard(title: title, value: value, footnote: footnote, color: color, systemImage: systemImage)
    }
}

struct ShiftTypePill: View {
    var title: String
    var color: Color
    var systemImage: String?

    var body: some View {
        HStack(spacing: 6) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.caption.weight(.bold))
                    .accessibilityHidden(true)
            }
            Text(title)
                .font(.caption.weight(.bold))
                .lineLimit(1)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 11)
        .padding(.vertical, 7)
        .background(color.opacity(0.28), in: Capsule())
        .overlay(Capsule().stroke(color.opacity(0.64), lineWidth: 1))
        .accessibilityLabel(title)
    }
}

struct TodayShiftHeroCard: View {
    var shift: Shift?
    var durationText: String
    var nextText: String

    var body: some View {
        PremiumGlassPanel(cornerRadius: 34) {
            ZStack(alignment: .trailing) {
                Image("BrandLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 190)
                    .opacity(0.13)
                    .blur(radius: 1)
                    .offset(x: 54, y: 8)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: Spacing.large) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 8) {
                            ShiftStatusCapsule(
                                title: shift == nil ? "Bugün boş" : "Bugünkü nöbet",
                                subtitle: shift?.workKind.localizedTitle,
                                color: shift?.colorTag.color ?? DesignColors.secondary,
                                systemImage: shift == nil ? "moon.zzz.fill" : "waveform.path.ecg"
                            )

                            Text(shift?.title ?? "Bugün planlı nöbet yok")
                                .font(.system(.largeTitle, design: .rounded, weight: .black))
                                .lineLimit(2)
                                .minimumScaleFactor(0.70)
                        }
                        Spacer(minLength: 20)
                    }

                    if let shift {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 10) {
                                ShiftTypePill(title: shift.isNightShift ? "Gece" : "Gündüz", color: shift.colorTag.color, systemImage: shift.isNightShift ? "moon.stars.fill" : "sun.max.fill")
                                Text("\(shift.startDate.formatted(date: .omitted, time: .shortened)) - \(shift.endDate.formatted(date: .omitted, time: .shortened))")
                                    .font(.headline.weight(.bold))
                            }
                            Text("\(shift.unit) • \(durationText)")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                    }

                    Text(nextText)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(
                            LinearGradient(colors: [DesignColors.secondary, DesignColors.primary], startPoint: .leading, endPoint: .trailing)
                        )
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}

struct ShiftTimelineCard: View {
    var shift: Shift
    var duration: Double
    var estimatedIncome: Double?

    var body: some View {
        HStack(spacing: Spacing.medium) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(
                    LinearGradient(colors: [shift.colorTag.color, DesignColors.accent.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                )
                .frame(width: 7)
                .shadow(color: shift.colorTag.color.opacity(0.35), radius: 12)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 9) {
                HStack {
                    Text(shift.title)
                        .font(Typography.headline)
                    Spacer()
                    Text(String(format: "%.1fs", duration))
                        .font(.subheadline.weight(.black))
                        .foregroundStyle(shift.colorTag.color)
                }

                Text("\(shift.startDate.formatted(date: .omitted, time: .shortened)) - \(shift.endDate.formatted(date: .omitted, time: .shortened)) • \(shift.unit)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack {
                    ShiftTypePill(title: shift.workKind.localizedTitle, color: shift.colorTag.color, systemImage: shift.isOfficialHoliday ? "flag.fill" : nil)
                    if let estimatedIncome {
                        Text(String(format: "+%.0f TRY", estimatedIncome))
                            .font(.caption.weight(.bold))
                            .foregroundStyle(DesignColors.success)
                    }
                }
            }
        }
        .padding(Spacing.medium)
        .glassCard(cornerRadius: 20)
        .accessibilityElement(children: .combine)
    }
}

struct FloatingAddButton: View {
    var expanded: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: expanded ? "xmark" : "plus")
                .font(.title2.weight(.black))
                .foregroundStyle(.white)
                .frame(width: 64, height: 64)
                .background(
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [DesignColors.accent, DesignColors.primary, DesignColors.secondary], startPoint: .topLeading, endPoint: .bottomTrailing))
                        Circle()
                            .stroke(Color.white.opacity(0.36), lineWidth: 1)
                    }
                )
                .shadow(color: DesignColors.accent.opacity(0.44), radius: 24, x: 0, y: 14)
                .shadow(color: DesignColors.primary.opacity(0.30), radius: 16, x: -8, y: 0)
        }
        .buttonStyle(.plain)
        .scaleEffect(expanded ? 0.92 : 1)
        .rotationEffect(.degrees(expanded ? 90 : 0))
        .animation(.spring(response: 0.32, dampingFraction: 0.74), value: expanded)
        .accessibilityLabel("Yeni nöbet ekle")
    }
}

struct EmptyStateView: View {
    var title: String
    var message: String
    var systemImage: String

    var body: some View {
        PremiumGlassPanel {
            VStack(spacing: Spacing.medium) {
                Image(systemName: systemImage)
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(DesignColors.secondary)
                    .accessibilityHidden(true)
                Text(title)
                    .font(Typography.title)
                Text(message)
                    .font(Typography.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .accessibilityElement(children: .combine)
    }
}

struct SmartInsightCard: View {
    var insight: SmartInsight

    var body: some View {
        PremiumGlassPanel(cornerRadius: 24) {
            HStack(alignment: .top, spacing: Spacing.medium) {
                Image(systemName: icon)
                    .font(.headline.weight(.black))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(color.opacity(0.32), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .stroke(color.opacity(0.66), lineWidth: 1)
                    }
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 7) {
                    Text(insight.title)
                        .font(Typography.headline)
                    Text(insight.message)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var icon: String {
        switch insight.kind {
        case .info: "sparkle.magnifyingglass"
        case .warning: "exclamationmark.triangle.fill"
        case .success: "checkmark.seal.fill"
        case .money: "banknote.fill"
        case .workload: "waveform.path.ecg"
        }
    }

    private var color: Color {
        switch insight.kind {
        case .info: DesignColors.primary
        case .warning: DesignColors.warning
        case .success: DesignColors.success
        case .money: DesignColors.secondary
        case .workload: DesignColors.accent
        }
    }
}

struct AnimatedWorkRing: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animatedValue: Double = 0
    var value: Double
    var lineWidth: CGFloat = 12

    var body: some View {
        ZStack {
            Circle().stroke(.white.opacity(0.12), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: min(animatedValue / 100, 1))
                .stroke(
                    LinearGradient(colors: [DesignColors.secondary, DesignColors.primary, DesignColors.accent], startPoint: .topLeading, endPoint: .bottomTrailing),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: DesignColors.accent.opacity(0.24), radius: 10)
            Text("\(Int(value))")
                .font(.title3.weight(.black))
        }
        .onAppear {
            if reduceMotion {
                animatedValue = value
            } else {
                withAnimation(.spring(response: 0.75, dampingFraction: 0.82)) {
                    animatedValue = value
                }
            }
        }
        .accessibilityLabel(String(format: String(localized: "accessibility.workloadScore"), Int(value)))
    }
}

struct WorkloadRing: View {
    var value: Double
    var lineWidth: CGFloat = 12

    var body: some View {
        AnimatedWorkRing(value: value, lineWidth: lineWidth)
    }
}

struct AnimatedToast: View {
    var message: String
    var systemImage: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .accessibilityHidden(true)
            Text(message)
                .font(.subheadline.weight(.bold))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.black.opacity(0.82), in: Capsule())
        .overlay(Capsule().stroke(Color.white.opacity(0.18), lineWidth: 1))
        .shadow(color: DesignColors.accent.opacity(0.24), radius: 18, y: 10)
        .transition(.move(edge: .top).combined(with: .opacity))
        .accessibilityElement(children: .combine)
    }
}

struct AwardDepthBadge: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var float = false
    var title: String
    var subtitle: String
    var systemImage: String
    var color: Color
    var size: CGFloat = 86
    var isAnimated = false

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.26))
                    .frame(width: size, height: size)
                    .blur(radius: 10)
                    .offset(y: 10)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.92), color.opacity(0.88), DesignColors.cinematicRoyal.opacity(0.92)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size, height: size)
                    .overlay {
                        Circle()
                            .stroke(Color.white.opacity(0.48), lineWidth: 1.2)
                    }
                    .shadow(color: color.opacity(0.44), radius: 20, x: 0, y: 14)

                Image(systemName: systemImage)
                    .font(.system(size: size * 0.34, weight: .black))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.18), radius: 10, y: 5)
            }
            .rotation3DEffect(.degrees(reduceMotion || !isAnimated ? -3 : (float ? 7 : -5)), axis: (x: 0.7, y: -0.55, z: 0))
            .scaleEffect(reduceMotion || !isAnimated ? 1 : (float ? 1.035 : 0.985))
            .onAppear {
                guard isAnimated, !reduceMotion else { return }
                withAnimation(.easeInOut(duration: 3.8).repeatForever(autoreverses: true)) {
                    float = true
                }
            }

            VStack(spacing: 2) {
                Text(title)
                    .font(.caption.weight(.black))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                Text(subtitle)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
        }
        .frame(minWidth: 92)
        .accessibilityElement(children: .combine)
    }
}

struct AwardSectionHeader: View {
    var title: String
    var subtitle: String? = nil
    var icon: String = "sparkles"
    var color: Color = DesignColors.secondary

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: icon)
                .font(.headline.weight(.black))
                .foregroundStyle(.white)
                .frame(width: 38, height: 38)
                .background(color.opacity(0.30), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(color.opacity(0.62), lineWidth: 1)
                }
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(.title3, design: .rounded, weight: .black))
                if let subtitle {
                    Text(subtitle)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
    }
}

struct GlassDockTabBar: View {
    @Binding var selection: AppTab
    var hapticsEnabled = true
    var action: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            ForEach(AppTab.allCases) { tab in
                dockItem(tab)
            }

            Button(action: action) {
                Image(systemName: "plus")
                    .font(.headline.weight(.black))
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(
                        LinearGradient(colors: [DesignColors.accent, DesignColors.primary], startPoint: .topLeading, endPoint: .bottomTrailing),
                        in: Circle()
                    )
                    .shadow(color: DesignColors.accent.opacity(0.34), radius: 16, y: 8)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Yeni nöbet ekle")
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(.thinMaterial, in: Capsule())
        .background(Color.black.opacity(0.12), in: Capsule())
        .overlay(Capsule().stroke(Color.white.opacity(0.22), lineWidth: 1))
        .shadow(color: .black.opacity(0.26), radius: 26, x: 0, y: 16)
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }

    private func dockItem(_ tab: AppTab) -> some View {
        Button {
            HapticService.selection(enabled: hapticsEnabled)
            withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                selection = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.systemImage)
                    .font(.system(size: 17, weight: .black))
                Text(tab.title)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)
            }
            .foregroundStyle(selection == tab ? .white : .secondary)
            .frame(width: 50, height: 48)
            .background(
                selection == tab
                    ? AnyShapeStyle(LinearGradient(colors: [DesignColors.primary.opacity(0.92), DesignColors.accent.opacity(0.88)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    : AnyShapeStyle(Color.clear),
                in: Capsule()
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.title)
    }
}
