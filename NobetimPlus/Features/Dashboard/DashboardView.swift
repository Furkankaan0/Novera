import SwiftUI

struct DashboardView: View {
    @ObservedObject var appState: AppState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var didEnter = false

    private var summary: WorkSummary { appState.monthlySummary() }
    private var todayShift: Shift? { appState.shifts.shifts(on: .now).first }
    private var teamToday: [TeamMember] { appState.teams.first?.members.filter(\.isOnDutyToday) ?? [] }

    var body: some View {
        NavigationStack {
            ZStack {
                CinematicBackground()

                ScrollView(showsIndicators: false) {
                    LazyVStack(alignment: .leading, spacing: Spacing.large) {
                        header
                        hero
                        monthlyStrip
                        insightSection
                        teamSection
                        premiumPrompt
                    }
                    .padding(Spacing.large)
                    .padding(.bottom, 110)
                    .offset(y: didEnter ? 0 : 18)
                    .opacity(didEnter ? 1 : 0)
                }
            }
            .navigationTitle("Bugün")
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                Button {
                    appState.activeSheet = .settings
                } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundStyle(DesignColors.secondary)
                }
                .accessibilityLabel("Ayarlar")
            }
            .onAppear {
                guard !didEnter else { return }
                if reduceMotion {
                    didEnter = true
                } else {
                    withAnimation(.spring(response: 0.58, dampingFraction: 0.86)) {
                        didEnter = true
                    }
                }
            }
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: Spacing.medium) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Nöbetim+")
                    .font(.caption.weight(.black))
                    .foregroundStyle(DesignColors.secondary)
                    .textCase(.uppercase)
                Text(greeting)
                    .font(.system(.title, design: .rounded, weight: .black))
                    .lineLimit(1)
                    .minimumScaleFactor(0.74)
            }
            Spacer()
            Image("BrandLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .shadow(color: DesignColors.accent.opacity(0.38), radius: 14, y: 8)
                .accessibilityHidden(true)
        }
    }

    private var hero: some View {
        TodayShiftHeroCard(
            shift: todayShift,
            durationText: todayShift.map { String(format: "%.1f saat", appState.calculator.calculateShiftDuration($0)) } ?? "",
            nextText: nextShiftText
        )
    }

    private var monthlyStrip: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            sectionTitle("Bu ay")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.medium) {
                CinematicMetricCard(title: "Toplam", value: hourText(summary.totalWorkHours), footnote: "Normal + ek mesai", color: DesignColors.primary, systemImage: "clock.fill")
                CinematicMetricCard(title: "Fazla mesai", value: hourText(summary.overtimeHours), footnote: "Normalden ayrı", color: DesignColors.accent, systemImage: "plus.forwardslash.minus")
                CinematicMetricCard(title: "UBGT", value: hourText(summary.officialHolidayHours), footnote: "Resmi tatil", color: DesignColors.warning, systemImage: "flag.fill")
                CinematicMetricCard(title: "Tahmini gelir", value: moneyText(summary.estimatedTotalExtraIncome), footnote: "Bilgilendirme amaçlı", color: DesignColors.success, systemImage: "banknote.fill")
            }
        }
    }

    private var insightSection: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            sectionTitle("Akıllı içgörü")
            ForEach(appState.insights().prefix(2)) { insight in
                SmartInsightCard(insight: insight)
            }
        }
    }

    private var teamSection: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            HStack {
                sectionTitle("Bugün ekipte")
                Spacer()
                ShiftStatusCapsule(title: "\(teamToday.count) kişi", color: DesignColors.secondary, systemImage: "person.3.fill")
            }

            if teamToday.isEmpty {
                EmptyStateView(
                    title: "Ekip bilgisi yok",
                    message: "Davet kodu ve ekip takvimi mock akış olarak hazır; TestFlight MVP’de genişletilebilir.",
                    systemImage: "person.3"
                )
            } else {
                ForEach(Array(teamToday.prefix(4))) { member in
                    TeamMemberRow(member: member)
                }
            }
        }
    }

    private var premiumPrompt: some View {
        PremiumGlassPanel(cornerRadius: 28) {
            HStack(spacing: Spacing.medium) {
                AnimatedWorkRing(value: min((summary.totalWorkHours / max(appState.profile.monthlyNormalHours, 1)) * 100, 100), lineWidth: 8)
                    .frame(width: 70, height: 70)

                VStack(alignment: .leading, spacing: 7) {
                    Text("Çalışma yükü görünürlüğü")
                        .font(Typography.headline)
                    Text("Bu ayki ritmini, fazla mesaini ve tahmini ek gelirini tek yerden izle.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(.title3, design: .rounded, weight: .black))
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var greeting: String {
        let name = appState.profile.fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        return name.isEmpty ? "Hazır mısın?" : "Merhaba, \(name)"
    }

    private var nextShiftText: String {
        guard let next = appState.shifts.filter({ $0.startDate > .now }).sorted(by: { $0.startDate < $1.startDate }).first else {
            return "Planlı sıradaki nöbet yok"
        }
        let hours = max(next.startDate.timeIntervalSinceNow / 3600, 0)
        return "Sıradaki nöbete yaklaşık \(Int(hours)) saat kaldı"
    }

    private func hourText(_ value: Double) -> String {
        String(format: "%.0fs", value)
    }

    private func moneyText(_ value: Double) -> String {
        String(format: "%.0f₺", value)
    }
}

struct TeamMemberRow: View {
    var member: TeamMember

    var body: some View {
        PremiumGlassPanel(cornerRadius: 22) {
            HStack(spacing: Spacing.medium) {
                Circle()
                    .fill(member.avatarColor.color.gradient)
                    .frame(width: 48, height: 48)
                    .overlay(Text(String(member.name.prefix(1))).font(.headline.weight(.black)).foregroundStyle(.white))
                    .shadow(color: member.avatarColor.color.opacity(0.28), radius: 12, y: 7)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text(member.name)
                        .font(Typography.headline)
                    Text(member.department)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                WorkloadRing(value: member.workloadScore, lineWidth: 6)
                    .frame(width: 48, height: 48)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
