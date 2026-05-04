// EarningsView.swift
// Növera — Premium Earnings & Revenue Dashboard

import SwiftUI

struct EarningsView: View {
    @StateObject private var vm = EarningsViewModel()
    @State private var animateRevenue: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: NSpacing.xl) {
                    // Disclaimer
                    premiumDisclaimer
                        .entrance(delay: 0)

                    // Month navigator
                    monthNavigator
                        .padding(.horizontal, NSpacing.base)
                        .entrance(delay: 0.03)

                    if let summary = vm.currentMonthSummary {
                        // Main revenue hero card
                        premiumRevenueCard(summary)
                            .padding(.horizontal, NSpacing.base)
                            .entrance(delay: 0.06)

                        // Breakdown grid
                        premiumBreakdownGrid(summary)
                            .padding(.horizontal, NSpacing.base)

                        // Hours breakdown
                        premiumHoursBreakdown(summary)
                            .padding(.horizontal, NSpacing.base)
                            .entrance(delay: 0.15)
                    }

                    // 6-month chart
                    premiumSixMonthChart
                        .padding(.horizontal, NSpacing.base)
                        .entrance(delay: 0.20)

                    // Rate settings
                    premiumRateSettings
                        .padding(.horizontal, NSpacing.base)
                        .entrance(delay: 0.25)

                    Spacer(minLength: 120)
                }
                .padding(.top, NSpacing.sm)
            }
            .screenBackground()
            .navigationTitle("Gelir Takibi")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                vm.loadData()
                withAnimation(NMotion.premium.delay(0.3)) {
                    animateRevenue = true
                }
            }
        }
    }

    // MARK: - Disclaimer
    var premiumDisclaimer: some View {
        HStack(spacing: NSpacing.sm) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(NColor.info)
                .font(.system(size: 15))
            Text("Bu hesaplamalar tahmini niteliktedir. Gerçek bordro için muhasebe uzmanınıza danışın.")
                .font(NFont.caption())
                .foregroundStyle(NColor.textSecondary)
        }
        .padding(NSpacing.md)
        .premiumGlass(radius: NRadius.medium, padding: 0)
        .padding(.horizontal, NSpacing.base)
    }

    // MARK: - Month Navigator
    var monthNavigator: some View {
        HStack {
            PremiumIconButton(icon: "chevron.left") { vm.navigateMonth(by: -1) }
            Spacer()
            Text(vm.selectedMonth.monthYearFormatted)
                .font(NFont.title3(.bold))
                .foregroundStyle(NColor.textPrimary)
            Spacer()
            PremiumIconButton(icon: "chevron.right") { vm.navigateMonth(by: 1) }
        }
    }

    // MARK: - Revenue Hero Card
    func premiumRevenueCard(_ summary: EarningsSummary) -> some View {
        VStack(spacing: NSpacing.lg) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: NSpacing.xs) {
                    Text("Tahmini Toplam Kazanç")
                        .font(NFont.subheadline(.medium))
                        .foregroundStyle(.white.opacity(0.8))
                    Text(summary.estimatedRevenue.currencyFormatted)
                        .font(NFont.display(38, .bold))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                        .animation(NMotion.premium, value: summary.estimatedRevenue)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: NSpacing.xs) {
                    Text("Toplam Saat")
                        .font(NFont.caption(.medium))
                        .foregroundStyle(.white.opacity(0.65))
                    Text(summary.totalHours.hoursFormatted)
                        .font(NFont.title2(.bold))
                        .foregroundStyle(.white)
                }
            }

            // Progress bar
            let totalRevenue = max(summary.estimatedRevenue, 1)
            let normalRatio = summary.normalRevenue / totalRevenue

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.white.opacity(0.15))
                        .frame(height: 8)
                    HStack(spacing: 0) {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(.white.opacity(0.88))
                            .frame(width: geo.size.width * normalRatio, height: 8)
                        RoundedRectangle(cornerRadius: 5)
                            .fill(NColor.success)
                            .frame(width: geo.size.width * (1 - normalRatio), height: 8)
                    }
                }
            }
            .frame(height: 8)

            HStack {
                Label("Normal", systemImage: "circle.fill")
                    .font(NFont.caption())
                    .foregroundStyle(.white.opacity(0.75))
                Spacer()
                Label("Ekstra", systemImage: "circle.fill")
                    .font(NFont.caption())
                    .foregroundStyle(NColor.success)
            }
        }
        .padding(NSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: NRadius.large, style: .continuous)
                .fill(NColor.primaryGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: NRadius.large, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.35), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .depth3D(radius: NRadius.large)
        .nShadow(.glow)
    }

    // MARK: - Breakdown Grid
    func premiumBreakdownGrid(_ summary: EarningsSummary) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: NSpacing.md) {
            PremiumEarningCell(title: "Normal Mesai", hours: summary.normalHours, amount: summary.normalRevenue, icon: "clock.fill", color: NColor.primaryFallback)
                .entrance(delay: 0.09)
            PremiumEarningCell(title: "Fazla Mesai", hours: summary.overtimeHours, amount: summary.overtimeRevenue, icon: "clock.badge.plus", color: NColor.shiftOvertime)
                .entrance(delay: 0.11)
            PremiumEarningCell(title: "Tatil Nöbeti", hours: summary.holidayHours, amount: summary.holidayRevenue, icon: "flag.fill", color: NColor.shiftHoliday)
                .entrance(delay: 0.13)
            PremiumEarningCell(title: "Gece Zammı", hours: summary.nightHours, amount: summary.nightBonus, icon: "moon.stars.fill", color: NColor.shiftNight)
                .entrance(delay: 0.15)
        }
    }

    // MARK: - Hours Breakdown
    func premiumHoursBreakdown(_ summary: EarningsSummary) -> some View {
        VStack(alignment: .leading, spacing: NSpacing.md) {
            PremiumSectionHeader(title: "Saat Dağılımı")
            PremiumGlassCard {
                VStack(spacing: NSpacing.md) {
                    PremiumHoursRow(label: "Normal", hours: summary.normalHours, color: NColor.primaryFallback, total: summary.totalHours)
                    PremiumHoursRow(label: "Fazla Mesai", hours: summary.overtimeHours, color: NColor.shiftOvertime, total: summary.totalHours)
                    PremiumHoursRow(label: "Tatil", hours: summary.holidayHours, color: NColor.shiftHoliday, total: summary.totalHours)
                }
            }
        }
    }

    // MARK: - 6-Month Chart
    var premiumSixMonthChart: some View {
        VStack(alignment: .leading, spacing: NSpacing.md) {
            PremiumSectionHeader(title: "Son 6 Ay", subtitle: "Tahmini kazanç trendi")
            PremiumGlassCard {
                if vm.last6Months.isEmpty {
                    PremiumEmptyState(icon: "chart.bar", title: "Veri Yok", subtitle: "Yeterli veri oluştuğunda grafik burada görünecek")
                } else {
                    PremiumBarChart(
                        data: vm.last6Months.map { ($0.month.formatted("MMM"), $0.estimatedRevenue) },
                        maxValue: vm.maxRevenue,
                        color: NColor.primaryFallback,
                        height: 90
                    )
                }
            }
        }
    }

    // MARK: - Rate Settings
    var premiumRateSettings: some View {
        VStack(alignment: .leading, spacing: NSpacing.md) {
            PremiumSectionHeader(title: "Ücret Ayarları")
            VStack(spacing: NSpacing.md) {
                RateRow(title: "Saatlik Ücret (₺)", value: $vm.hourlyRate, range: 50...1000)
                RateRow(title: "Fazla Mesai Çarpanı (x)", value: $vm.overtimeMultiplier, range: 1...3)
                RateRow(title: "Resmi Tatil Çarpanı (x)", value: $vm.holidayMultiplier, range: 1...3)

                PremiumPrimaryButton(title: "Kaydet", icon: "checkmark") {
                    vm.saveSettings()
                    HapticManager.notification(.success)
                }
            }
            .premiumGlass(radius: NRadius.large, padding: NSpacing.base)
        }
    }
}

// MARK: - Premium Earning Cell
struct PremiumEarningCell: View {
    let title: String
    let hours: Double
    let amount: Double
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: NSpacing.sm) {
            Soft3DIcon(icon: icon, size: .small, color: color)

            Text(amount.currencyFormatted)
                .font(NFont.title3(.bold))
                .foregroundStyle(NColor.textPrimary)
                .contentTransition(.numericText())

            Text(title)
                .font(NFont.caption(.medium))
                .foregroundStyle(NColor.textSecondary)

            Text(hours.hoursFormatted)
                .font(NFont.caption2(.semibold))
                .foregroundStyle(color)
        }
        .premiumGlass(radius: NRadius.medium, padding: NSpacing.base)
    }
}

// MARK: - Premium Hours Row
struct PremiumHoursRow: View {
    let label: String
    let hours: Double
    let color: Color
    let total: Double

    var ratio: Double {
        guard total > 0 else { return 0 }
        return hours / total
    }

    @State private var barWidth: CGFloat = 0

    var body: some View {
        VStack(spacing: NSpacing.xs) {
            HStack {
                Text(label)
                    .font(NFont.subheadline())
                    .foregroundStyle(NColor.textPrimary)
                Spacer()
                Text(hours.hoursFormatted)
                    .font(NFont.subheadline(.semibold))
                    .foregroundStyle(color)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.12))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.5), color],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: barWidth, height: 6)
                        .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
                        .onAppear {
                            withAnimation(NMotion.bouncy.delay(0.2)) {
                                barWidth = geo.size.width * ratio
                            }
                        }
                }
            }
            .frame(height: 6)
        }
    }
}

// MARK: - Rate Input Row
struct RateRow: View {
    let title: String
    @Binding var value: Double
    var range: ClosedRange<Double> = 0...1000

    var body: some View {
        VStack(alignment: .leading, spacing: NSpacing.sm) {
            HStack {
                Text(title)
                    .font(NFont.subheadline(.medium))
                    .foregroundStyle(NColor.textPrimary)
                Spacer()
                Text(String(format: value >= 10 ? "%.0f" : "%.1f", value))
                    .font(NFont.headline(.bold))
                    .foregroundStyle(NColor.primaryFallback)
                    .frame(minWidth: 50, alignment: .trailing)
            }
            Slider(value: $value, in: range, step: value >= 10 ? 5 : 0.1)
                .tint(NColor.primaryFallback)
        }
    }
}

#Preview {
    EarningsView()
        .environmentObject(AppState())
}
