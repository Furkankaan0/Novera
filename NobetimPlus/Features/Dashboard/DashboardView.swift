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
                        commandHeader
                        DailyCommandHero(
                            shift: todayShift,
                            durationText: todayShift.map { String(format: "%.1f saat", appState.calculator.calculateShiftDuration($0)) } ?? "0 saat",
                            nextText: nextShiftText,
                            workload: workloadPercent
                        )
                        rhythmStrip
                        awardBadges
                        insightSection
                        teamSection
                    }
                    .padding(Spacing.large)
                    .padding(.bottom, 116)
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
                    withAnimation(.spring(response: 0.62, dampingFraction: 0.86)) {
                        didEnter = true
                    }
                }
            }
        }
    }

    private var commandHeader: some View {
        HStack(spacing: Spacing.medium) {
            VStack(alignment: .leading, spacing: 6) {
                Text("NÖBET KONTROL MERKEZİ")
                    .font(.caption.weight(.black))
                    .foregroundStyle(DesignColors.secondary)
                Text(greeting)
                    .font(.system(.title, design: .rounded, weight: .black))
                    .lineLimit(1)
                    .minimumScaleFactor(0.74)
            }
            Spacer()
            AwardDepthBadge(title: "Bugün", subtitle: "Hazır", systemImage: "waveform.path.ecg", color: DesignColors.secondary, size: 58, isAnimated: true)
        }
    }

    private var rhythmStrip: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            AwardSectionHeader(title: "Çalışma ritmi", subtitle: "Ay sonu yükünü erken gör", icon: "chart.xyaxis.line", color: DesignColors.primary)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.medium) {
                CinematicMetricCard(title: "Toplam", value: hourText(summary.totalWorkHours), footnote: "Bu ay", color: DesignColors.primary, systemImage: "clock.fill")
                CinematicMetricCard(title: "Fazla mesai", value: hourText(summary.overtimeHours), footnote: "Ayrı rapor", color: DesignColors.accent, systemImage: "plus.forwardslash.minus")
                CinematicMetricCard(title: "UBGT", value: hourText(summary.officialHolidayHours), footnote: "Resmi tatil", color: DesignColors.warning, systemImage: "flag.fill")
                CinematicMetricCard(title: "Tahmini gelir", value: moneyText(summary.estimatedTotalExtraIncome), footnote: "Bordro değildir", color: DesignColors.success, systemImage: "turkishlirasign.circle.fill")
            }
        }
    }

    private var awardBadges: some View {
        PremiumGlassPanel(cornerRadius: 30) {
            VStack(alignment: .leading, spacing: Spacing.large) {
                AwardSectionHeader(title: "Başarı vitrini", subtitle: "Günlük kullanım için küçük hedefler", icon: "crown.fill", color: DesignColors.warning)
                HStack(spacing: Spacing.medium) {
                    AwardDepthBadge(title: "Planlı", subtitle: "\(appState.shifts.count) kayıt", systemImage: "calendar.badge.checkmark", color: DesignColors.primary)
                    Spacer()
                    AwardDepthBadge(title: "Denge", subtitle: "\(Int(workloadPercent))%", systemImage: "gauge.with.dots.needle.67percent", color: DesignColors.secondary)
                    Spacer()
                    AwardDepthBadge(title: "Premium", subtitle: appState.profile.premiumStatus.isPremium ? "Açık" : "Kilitli", systemImage: "sparkles", color: DesignColors.accent)
                }
            }
        }
    }

    private var insightSection: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            AwardSectionHeader(title: "Akıllı içgörü", subtitle: "Tıbbi öneri değil, çalışma farkındalığı", icon: "sparkle.magnifyingglass", color: DesignColors.accent)
            ForEach(appState.insights().prefix(2)) { insight in
                SmartInsightCard(insight: insight)
            }
        }
    }

    private var teamSection: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            HStack {
                AwardSectionHeader(title: "Ekip nabzı", subtitle: "Bugün çalışanlar", icon: "person.3.fill", color: DesignColors.secondary)
                ShiftStatusCapsule(title: "\(teamToday.count)", color: DesignColors.secondary, systemImage: "person.fill.checkmark")
            }

            if teamToday.isEmpty {
                EmptyStateView(title: "Ekip bilgisi yok", message: "Davet kodu ve ekip takvimi mock akış olarak hazır.", systemImage: "person.3")
            } else {
                ForEach(Array(teamToday.prefix(3))) { member in
                    TeamMemberRow(member: member)
                }
            }
        }
    }

    private var workloadPercent: Double {
        min(summary.totalWorkHours / max(appState.profile.monthlyNormalHours, 1) * 100, 100)
    }

    private var greeting: String {
        let name = appState.profile.fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        return name.isEmpty ? "Bugünkü ritmini kur" : "Merhaba, \(name)"
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

private struct DailyCommandHero: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pulse = false
    var shift: Shift?
    var durationText: String
    var nextText: String
    var workload: Double

    var body: some View {
        PremiumGlassPanel(cornerRadius: 38) {
            ZStack(alignment: .trailing) {
                heroArt
                VStack(alignment: .leading, spacing: Spacing.large) {
                    ShiftStatusCapsule(
                        title: shift == nil ? "Bugün dinlenme" : "Bugünkü nöbet",
                        subtitle: shift?.workKind.localizedTitle,
                        color: shift?.colorTag.color ?? DesignColors.secondary,
                        systemImage: shift == nil ? "moon.zzz.fill" : "waveform.path.ecg"
                    )

                    VStack(alignment: .leading, spacing: 10) {
                        Text(shift?.title ?? "Bugün planlı nöbet yok")
                            .font(.system(.largeTitle, design: .rounded, weight: .black))
                            .lineLimit(2)
                            .minimumScaleFactor(0.68)

                        if let shift {
                            Text("\(shift.startDate.formatted(date: .omitted, time: .shortened)) - \(shift.endDate.formatted(date: .omitted, time: .shortened)) • \(shift.unit) • \(durationText)")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    HStack(spacing: Spacing.medium) {
                        AnimatedWorkRing(value: workload, lineWidth: 7)
                            .frame(width: 58, height: 58)
                        Text(nextText)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(DesignColors.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 3.2).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }

    private var heroArt: some View {
        ZStack {
            Circle()
                .stroke(DesignColors.secondary.opacity(0.18), lineWidth: 18)
                .frame(width: 210, height: 210)
                .scaleEffect(pulse ? 1.06 : 0.94)
            Image("BrandLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 190)
                .opacity(0.18)
                .rotation3DEffect(.degrees(pulse ? 7 : -5), axis: (x: 0.5, y: -0.8, z: 0))
        }
        .offset(x: 62, y: 6)
        .accessibilityHidden(true)
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
