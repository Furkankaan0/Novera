import Charts
import SwiftUI

struct AnalyticsView: View {
    @ObservedObject var appState: AppState

    private var summary: WorkSummary { appState.monthlySummary() }
    private var weekly: [WeeklyWorkPoint] { appState.calculator.weeklyPoints(shifts: appState.shifts) }
    private var distribution: [ShiftTypeDistribution] { appState.calculator.distribution(shifts: appState.shifts) }

    var body: some View {
        NavigationStack {
            ZStack {
                CinematicBackground()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: Spacing.large) {
                        hero
                        metrics
                        barChart
                        distributionChart
                        legalNotice
                    }
                    .padding(Spacing.large)
                    .padding(.bottom, 110)
                }
            }
            .navigationTitle("Analiz")
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }

    private var hero: some View {
        PremiumGlassPanel(cornerRadius: 32) {
            HStack(spacing: Spacing.medium) {
                AnimatedWorkRing(value: min(summary.totalWorkHours / max(appState.profile.monthlyNormalHours, 1) * 100, 100), lineWidth: 10)
                    .frame(width: 96, height: 96)

                VStack(alignment: .leading, spacing: 9) {
                    ShiftStatusCapsule(title: "Bu ay", subtitle: "Çalışma yükü", color: DesignColors.accent, systemImage: "chart.xyaxis.line")
                    Text(String(format: "%.0f saat", summary.totalWorkHours))
                        .font(.system(.largeTitle, design: .rounded, weight: .black))
                    Text("Normal süre: \(String(format: "%.0f saat", appState.profile.monthlyNormalHours))")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var metrics: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.medium) {
            CinematicMetricCard(title: "Normal", value: String(format: "%.0fs", summary.normalShiftHours), footnote: "Ay toplamı", color: DesignColors.primary, systemImage: "briefcase.fill")
            CinematicMetricCard(title: "Gece", value: String(format: "%.0fs", summary.nightShiftHours), footnote: "Ayrı raporlanır", color: DesignColors.navy, systemImage: "moon.stars.fill")
            CinematicMetricCard(title: "Hafta sonu", value: String(format: "%.0fs", summary.weekendHours), footnote: "Takvim bazlı", color: DesignColors.orange, systemImage: "calendar")
            CinematicMetricCard(title: "Tahmini gelir", value: String(format: "%.0f₺", summary.estimatedTotalExtraIncome), footnote: "Bordro değildir", color: DesignColors.success, systemImage: "turkishlirasign.circle.fill")
        }
    }

    private var barChart: some View {
        chartCard("Haftalık çalışma") {
            Chart(weekly) { point in
                BarMark(x: .value("Gün", point.label), y: .value("Saat", point.hours))
                    .foregroundStyle(LinearGradient(colors: [DesignColors.primary, DesignColors.secondary], startPoint: .bottom, endPoint: .top))
                    .cornerRadius(8)
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .frame(height: 220)
        }
    }

    private var distributionChart: some View {
        chartCard("Mesai dağılımı") {
            Chart(distribution) { item in
                SectorMark(angle: .value("Saat", item.hours), innerRadius: .ratio(0.62), angularInset: 2.5)
                    .foregroundStyle(item.colorTag.color)
                    .cornerRadius(6)
            }
            .frame(height: 230)

            VStack(spacing: 8) {
                ForEach(distribution.prefix(5)) { item in
                    HStack {
                        Circle().fill(item.colorTag.color).frame(width: 9, height: 9)
                        Text(item.label).font(.caption.weight(.bold))
                        Spacer()
                        Text(String(format: "%.1fs", item.hours)).font(.caption.monospacedDigit().weight(.bold))
                    }
                }
            }
        }
    }

    private var legalNotice: some View {
        PremiumGlassPanel(cornerRadius: 22) {
            Label("Bu hesaplama bilgilendirme amaçlıdır. Kurum bordrosu, toplu iş sözleşmesi ve mevzuat farklılık gösterebilir.", systemImage: "info.circle.fill")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
        }
    }

    private func chartCard<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        PremiumGlassPanel(cornerRadius: 28) {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                Text(title)
                    .font(.system(.title3, design: .rounded, weight: .black))
                content()
            }
        }
    }
}
