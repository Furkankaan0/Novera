import SwiftUI

struct DashboardView: View {
    @ObservedObject var appState: AppState

    private var summary: WorkSummary { appState.monthlySummary() }
    private var todayShift: Shift? { appState.shifts.shifts(on: .now).first }
    private var teamToday: [TeamMember] { appState.teams.first?.members.filter(\.isOnDutyToday) ?? [] }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: Spacing.large) {
                    TodayShiftHeroCard(
                        shift: todayShift,
                        durationText: todayShift.map { String(format: "%.1f saat", appState.calculator.calculateShiftDuration($0)) } ?? "",
                        nextText: nextShiftText
                    )
                    .padding(.top, Spacing.medium)

                    metricGrid

                    VStack(alignment: .leading, spacing: Spacing.medium) {
                        sectionTitle("Akıllı İçgörü")
                        ForEach(appState.insights().prefix(2)) { insight in
                            SmartInsightCard(insight: insight)
                        }
                    }

                    VStack(alignment: .leading, spacing: Spacing.medium) {
                        sectionTitle("Bugün ekipte")
                        if teamToday.isEmpty {
                            EmptyStateView(title: "Ekip bilgisi yok", message: "Ekip görünümü mock olarak hazır. Davet kodu ile katılım akışı genişletilebilir.", systemImage: "person.3")
                        } else {
                            ForEach(teamToday) { member in
                                TeamMemberRow(member: member)
                            }
                        }
                    }
                }
                .padding(Spacing.large)
            }
            .navigationTitle("Bugün")
            .toolbar {
                Button {
                    appState.activeSheet = .settings
                } label: {
                    Image(systemName: "gearshape.fill")
                }
                .accessibilityLabel("Ayarlar")
            }
        }
    }

    private var metricGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.medium) {
            PremiumMetricCard(title: "Bu ay toplam", value: String(format: "%.0fs", summary.totalWorkHours), footnote: "Normal + ek mesai", color: DesignColors.primary, systemImage: "clock.fill")
            PremiumMetricCard(title: "Fazla mesai", value: String(format: "%.0fs", summary.overtimeHours), footnote: "Tahmini ayrım", color: DesignColors.accent, systemImage: "plus.forwardslash.minus")
            PremiumMetricCard(title: "UBGT / resmi tatil", value: String(format: "%.1fs", summary.officialHolidayHours), footnote: "Ayrıca raporlanır", color: DesignColors.warning, systemImage: "flag.fill")
            PremiumMetricCard(title: "Gelir tahmini", value: String(format: "%.0f₺", summary.estimatedTotalExtraIncome), footnote: "Bilgilendirme amaçlıdır", color: DesignColors.success, systemImage: "banknote.fill")
        }
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(Typography.title)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var nextShiftText: String {
        guard let next = appState.shifts.filter({ $0.startDate > .now }).sorted(by: { $0.startDate < $1.startDate }).first else {
            return "Planlı sıradaki nöbet yok"
        }
        let hours = max(next.startDate.timeIntervalSinceNow / 3600, 0)
        return "Sıradaki nöbete yaklaşık \(Int(hours)) saat kaldı"
    }
}

struct TeamMemberRow: View {
    var member: TeamMember

    var body: some View {
        HStack(spacing: Spacing.medium) {
            Circle()
                .fill(member.avatarColor.color.gradient)
                .frame(width: 46, height: 46)
                .overlay(Text(String(member.name.prefix(1))).font(.headline).foregroundStyle(.white))
            VStack(alignment: .leading, spacing: 4) {
                Text(member.name).font(Typography.headline)
                Text(member.department).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            WorkloadRing(value: member.workloadScore, lineWidth: 6)
                .frame(width: 48, height: 48)
        }
        .padding(Spacing.medium)
        .glassCard(cornerRadius: 18)
    }
}
