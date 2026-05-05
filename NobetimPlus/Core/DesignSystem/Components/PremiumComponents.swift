import SwiftUI

struct PremiumMetricCard: View {
    var title: String
    var value: String
    var footnote: String
    var color: Color
    var systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Image(systemName: systemImage)
                .font(.title3.weight(.semibold))
                .foregroundStyle(color)
                .frame(width: 44, height: 44)
                .background(color.opacity(0.14), in: Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(Typography.metric)
                    .minimumScaleFactor(0.8)
                Text(title)
                    .font(Typography.caption)
                    .foregroundStyle(.secondary)
                Text(footnote)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.medium)
        .glassCard(cornerRadius: 22)
        .accessibilityElement(children: .combine)
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
                    .font(.caption.weight(.semibold))
            }
            Text(title)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
        }
        .foregroundStyle(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(color.opacity(0.14), in: Capsule())
        .accessibilityLabel(title)
    }
}

struct TodayShiftHeroCard: View {
    var shift: Shift?
    var durationText: String
    var nextText: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.large) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "dashboard.todayShift"))
                        .font(Typography.caption)
                        .foregroundStyle(.secondary)
                    Text(shift?.title ?? String(localized: "dashboard.noShiftToday"))
                        .font(Typography.hero)
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)
                }
                Spacer()
                Image(systemName: shift == nil ? "sparkles" : "stethoscope")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 54, height: 54)
                    .background(
                        LinearGradient(colors: [DesignColors.primary, DesignColors.secondary], startPoint: .topLeading, endPoint: .bottomTrailing),
                        in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                    )
                    .accessibilityHidden(true)
            }

            if let shift {
                HStack {
                    ShiftTypePill(title: shift.workKind.localizedTitle, color: shift.colorTag.color, systemImage: shift.isNightShift ? "moon.stars.fill" : "clock.fill")
                    Text("\(shift.startDate.formatted(date: .omitted, time: .shortened)) - \(shift.endDate.formatted(date: .omitted, time: .shortened))")
                        .font(Typography.headline)
                    Spacer()
                }
                Text("\(shift.unit) • \(durationText)")
                    .font(Typography.body)
                    .foregroundStyle(.secondary)
            }

            Text(nextText)
                .font(Typography.headline)
                .foregroundStyle(DesignColors.primary)
        }
        .padding(Spacing.large)
        .glassCard(cornerRadius: 30)
        .accessibilityElement(children: .combine)
    }
}

struct ShiftTimelineCard: View {
    var shift: Shift
    var duration: Double
    var estimatedIncome: Double?

    var body: some View {
        HStack(spacing: Spacing.medium) {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(shift.colorTag.color)
                .frame(width: 6)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(shift.title)
                        .font(Typography.headline)
                    Spacer()
                    Text(String(format: "%.1fs", duration))
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(shift.colorTag.color)
                }

                Text("\(shift.startDate.formatted(date: .omitted, time: .shortened)) - \(shift.endDate.formatted(date: .omitted, time: .shortened)) • \(shift.unit)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack {
                    ShiftTypePill(title: shift.workKind.localizedTitle, color: shift.colorTag.color, systemImage: shift.isOfficialHoliday ? "flag.fill" : nil)
                    if let estimatedIncome {
                        Text(String(format: "+%.0f TRY", estimatedIncome))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(DesignColors.success)
                    }
                }
            }
        }
        .padding(Spacing.medium)
        .glassCard(cornerRadius: 18)
        .accessibilityElement(children: .combine)
    }
}

struct FloatingAddButton: View {
    var expanded: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: expanded ? "xmark" : "plus")
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 62, height: 62)
                .background(
                    LinearGradient(colors: [DesignColors.primary, DesignColors.accent], startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: Circle()
                )
                .shadow(color: DesignColors.primary.opacity(0.35), radius: 18, x: 0, y: 10)
        }
        .buttonStyle(.plain)
        .scaleEffect(expanded ? 0.92 : 1)
        .animation(.spring(response: 0.32, dampingFraction: 0.74), value: expanded)
        .accessibilityLabel(String(localized: "action.addShift"))
    }
}

struct EmptyStateView: View {
    var title: String
    var message: String
    var systemImage: String

    var body: some View {
        VStack(spacing: Spacing.medium) {
            Image(systemName: systemImage)
                .font(.largeTitle)
                .foregroundStyle(DesignColors.primary)
            Text(title)
                .font(Typography.title)
            Text(message)
                .font(Typography.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.large)
        .glassCard()
        .accessibilityElement(children: .combine)
    }
}

struct SmartInsightCard: View {
    var insight: SmartInsight

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.medium) {
            Image(systemName: icon)
                .font(.headline.weight(.bold))
                .foregroundStyle(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.14), in: Circle())
            VStack(alignment: .leading, spacing: 6) {
                Text(insight.title)
                    .font(Typography.headline)
                Text(insight.message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(Spacing.medium)
        .glassCard(cornerRadius: 20)
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

struct WorkloadRing: View {
    var value: Double
    var lineWidth: CGFloat = 12

    var body: some View {
        ZStack {
            Circle().stroke(.secondary.opacity(0.15), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: min(value / 100, 1))
                .stroke(
                    LinearGradient(colors: [DesignColors.secondary, DesignColors.primary, DesignColors.accent], startPoint: .topLeading, endPoint: .bottomTrailing),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            Text("\(Int(value))")
                .font(.title3.weight(.bold))
        }
        .accessibilityLabel(String(format: String(localized: "accessibility.workloadScore"), Int(value)))
    }
}

struct AnimatedToast: View {
    var message: String
    var systemImage: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
            Text(message).font(.subheadline.weight(.semibold))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.black.opacity(0.82), in: Capsule())
        .transition(.move(edge: .top).combined(with: .opacity))
        .accessibilityElement(children: .combine)
    }
}
