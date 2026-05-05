import Charts
import SwiftUI

struct AnalyticsView: View {
    @ObservedObject var appState: AppState

    private var summary: WorkSummary { appState.monthlySummary() }
    private var weekly: [WeeklyWorkPoint] { appState.calculator.weeklyPoints(shifts: appState.shifts) }
    private var distribution: [ShiftTypeDistribution] { appState.calculator.distribution(shifts: appState.shifts) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.large) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.medium) {
                        PremiumMetricCard(title: "Normal çalışma", value: String(format: "%.0fs", summary.normalShiftHours), footnote: "Ay toplamı", color: DesignColors.primary, systemImage: "briefcase.fill")
                        PremiumMetricCard(title: "Gece nöbeti", value: String(format: "%.0fs", summary.nightShiftHours), footnote: "Ayrı raporlanır", color: DesignColors.navy, systemImage: "moon.stars.fill")
                        PremiumMetricCard(title: "Hafta sonu", value: String(format: "%.0fs", summary.weekendHours), footnote: "Takvim bazlı", color: DesignColors.orange, systemImage: "calendar")
                        PremiumMetricCard(title: "Tahmini gelir", value: String(format: "%.0f₺", summary.estimatedTotalExtraIncome), footnote: "Bordro değildir", color: DesignColors.success, systemImage: "turkishlirasign.circle.fill")
                    }

                    chartCard("Haftalık çalışma saatleri") {
                        Chart(weekly) { point in
                            BarMark(x: .value("Gün", point.label), y: .value("Saat", point.hours))
                                .foregroundStyle(DesignColors.primary.gradient)
                                .cornerRadius(6)
                        }
                        .frame(height: 220)
                    }

                    chartCard("Vardiya türü dağılımı") {
                        Chart(distribution) { item in
                            SectorMark(angle: .value("Saat", item.hours), innerRadius: .ratio(0.58), angularInset: 2)
                                .foregroundStyle(item.colorTag.color)
                        }
                        .frame(height: 220)
                    }

                    Text("Bu hesaplama bilgilendirme amaçlıdır. Kurum bordrosu, toplu iş sözleşmesi ve mevzuat farklılık gösterebilir.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(Spacing.medium)
                        .glassCard(cornerRadius: 18)
                }
                .padding(Spacing.large)
            }
            .navigationTitle("Analiz")
        }
    }

    private func chartCard<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Text(title).font(Typography.title)
            content()
        }
        .padding(Spacing.large)
        .glassCard()
    }
}
