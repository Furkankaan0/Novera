// EarningsView.swift
// Növera — Earnings & Revenue Tracker

import SwiftUI

struct EarningsView: View {
    @StateObject private var vm = EarningsViewModel()
    @State private var animateRevenue: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: NoveraSpacing.lg) {
                    // Disclaimer
                    disclaimerBanner

                    // Month navigator + main card
                    monthNavigator
                        .padding(.horizontal, NoveraSpacing.md)

                    if let summary = vm.currentMonthSummary {
                        // Main revenue card
                        mainRevenueCard(summary)
                            .padding(.horizontal, NoveraSpacing.md)

                        // Breakdown cards
                        breakdownGrid(summary)
                            .padding(.horizontal, NoveraSpacing.md)

                        // Hours breakdown
                        hoursBreakdown(summary)
                            .padding(.horizontal, NoveraSpacing.md)
                    }

                    // 6-month chart
                    sixMonthChart
                        .padding(.horizontal, NoveraSpacing.md)

                    // Rate settings
                    rateSettings
                        .padding(.horizontal, NoveraSpacing.md)

                    Spacer(minLength: 100)
                }
                .padding(.top, NoveraSpacing.sm)
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Gelir Takibi")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                vm.loadData()
                withAnimation(NoveraAnimation.spring.delay(0.3)) {
                    animateRevenue = true
                }
            }
        }
    }

    // MARK: - Disclaimer
    var disclaimerBanner: some View {
        HStack(spacing: NoveraSpacing.sm) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(NoveraColors.info)
                .font(.system(size: 14))
            Text("Bu hesaplamalar tahmini niteliktedir. Gerçek bordro için muhasebe uzmanınıza danışın.")
                .font(NoveraFonts.caption())
                .foregroundStyle(NoveraColors.textSecondary)
        }
        .padding(NoveraSpacing.sm)
        .padding(.horizontal, NoveraSpacing.md)
        .background(NoveraColors.info.opacity(0.08))
    }

    // MARK: - Month Navigator
    var monthNavigator: some View {
        HStack {
            NoveraIconButton(icon: "chevron.left") { vm.navigateMonth(by: -1) }
            Spacer()
            Text(vm.selectedMonth.monthYearFormatted)
                .font(NoveraFonts.title3(.semibold))
            Spacer()
            NoveraIconButton(icon: "chevron.right") { vm.navigateMonth(by: 1) }
        }
    }

    // MARK: - Main Revenue Card
    func mainRevenueCard(_ summary: EarningsSummary) -> some View {
        VStack(spacing: NoveraSpacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tahmini Toplam Kazanç")
                        .font(NoveraFonts.subheadline())
                        .foregroundStyle(.white.opacity(0.8))
                    Text(summary.estimatedRevenue.currencyFormatted)
                        .font(NoveraFonts.display(38, .bold))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                        .animation(NoveraAnimation.spring, value: summary.estimatedRevenue)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Toplam Saat")
                        .font(NoveraFonts.caption())
                        .foregroundStyle(.white.opacity(0.7))
                    Text(summary.totalHours.hoursFormatted)
                        .font(NoveraFonts.title2(.bold))
                        .foregroundStyle(.white)
                }
            }

            // Progress bar: normal vs extra
            let totalRevenue = max(summary.estimatedRevenue, 1)
            let normalRatio = summary.normalRevenue / totalRevenue

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4).fill(.white.opacity(0.2)).frame(height: 8)
                    HStack(spacing: 0) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.white.opacity(0.9))
                            .frame(width: geo.size.width * normalRatio, height: 8)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hue: 0.38, saturation: 0.7, brightness: 0.95))
                            .frame(width: geo.size.width * (1 - normalRatio), height: 8)
                    }
                }
            }
            .frame(height: 8)

            HStack {
                Label("Normal", systemImage: "circle.fill")
                    .font(NoveraFonts.caption()).foregroundStyle(.white.opacity(0.8))
                Spacer()
                Label("Ekstra", systemImage: "circle.fill")
                    .font(NoveraFonts.caption()).foregroundStyle(Color(hue: 0.38, saturation: 0.7, brightness: 0.95))
            }
        }
        .padding(NoveraSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: NoveraRadius.xl, style: .continuous)
                .fill(NoveraColors.primaryGradient)
        )
        .noveraShadow(NoveraShadows.primary)
    }

    // MARK: - Breakdown Grid
    func breakdownGrid(_ summary: EarningsSummary) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: NoveraSpacing.sm) {
            EarningCell(
                title: "Normal Mesai",
                hours: summary.normalHours,
                amount: summary.normalRevenue,
                icon: "clock.fill",
                color: NoveraColors.primary
            )
            EarningCell(
                title: "Fazla Mesai",
                hours: summary.overtimeHours,
                amount: summary.overtimeRevenue,
                icon: "clock.badge.plus",
                color: NoveraColors.shiftOvertime
            )
            EarningCell(
                title: "Tatil Nöbeti",
                hours: summary.holidayHours,
                amount: summary.holidayRevenue,
                icon: "flag.fill",
                color: NoveraColors.shiftHoliday
            )
            EarningCell(
                title: "Gece Zammı",
                hours: summary.nightHours,
                amount: summary.nightBonus,
                icon: "moon.stars.fill",
                color: NoveraColors.shiftNight
            )
        }
    }

    // MARK: - Hours Breakdown
    func hoursBreakdown(_ summary: EarningsSummary) -> some View {
        VStack(alignment: .leading, spacing: NoveraSpacing.sm) {
            NoveraSectionHeader(title: "Saat Dağılımı")
            GlassCard {
                VStack(spacing: NoveraSpacing.sm) {
                    HoursRow(label: "Normal", hours: summary.normalHours, color: NoveraColors.primary, total: summary.totalHours)
                    HoursRow(label: "Fazla Mesai", hours: summary.overtimeHours, color: NoveraColors.shiftOvertime, total: summary.totalHours)
                    HoursRow(label: "Tatil", hours: summary.holidayHours, color: NoveraColors.shiftHoliday, total: summary.totalHours)
                }
            }
        }
    }

    // MARK: - 6-Month Chart
    var sixMonthChart: some View {
        VStack(alignment: .leading, spacing: NoveraSpacing.sm) {
            NoveraSectionHeader(title: "Son 6 Ay", subtitle: "Tahmini kazanç trendi")
            GlassCard {
                VStack(alignment: .leading, spacing: NoveraSpacing.sm) {
                    if vm.last6Months.isEmpty {
                        Text("Yeterli veri yok")
                            .font(NoveraFonts.subheadline())
                            .foregroundStyle(NoveraColors.textSecondary)
                    } else {
                        HStack(alignment: .bottom, spacing: NoveraSpacing.sm) {
                            ForEach(vm.last6Months, id: \.month) { summary in
                                VStack(spacing: 4) {
                                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                                        .fill(
                                            summary.month.isThisMonth
                                            ? NoveraColors.primaryGradient
                                            : LinearGradient(colors: [NoveraColors.primary.opacity(0.4)], startPoint: .top, endPoint: .bottom)
                                        )
                                        .frame(
                                            maxWidth: .infinity,
                                            minHeight: 4,
                                            maxHeight: max(4, CGFloat(summary.estimatedRevenue / (vm.maxRevenue + 1)) * 80)
                                        )
                                        .animation(NoveraAnimation.spring, value: summary.estimatedRevenue)

                                    Text(summary.month.formatted("MMM"))
                                        .font(NoveraFonts.caption())
                                        .foregroundStyle(NoveraColors.textTertiary)
                                }
                            }
                        }
                        .frame(height: 100)
                    }
                }
            }
        }
    }

    // MARK: - Rate Settings
    var rateSettings: some View {
        VStack(alignment: .leading, spacing: NoveraSpacing.sm) {
            NoveraSectionHeader(title: "Ücret Ayarları")
            VStack(spacing: NoveraSpacing.sm) {
                RateRow(title: "Saatlik Ücret (₺)", value: $vm.hourlyRate, range: 50...1000)
                RateRow(title: "Fazla Mesai Çarpanı (x)", value: $vm.overtimeMultiplier, range: 1...3)
                RateRow(title: "Resmi Tatil Çarpanı (x)", value: $vm.holidayMultiplier, range: 1...3)

                NoveraPrimaryButton("Kaydet", icon: "checkmark") {
                    vm.saveSettings()
                    HapticManager.notification(.success)
                }
            }
            .padding(NoveraSpacing.md)
            .glassBackground(cornerRadius: NoveraRadius.lg)
            .noveraShadow(NoveraShadows.soft)
        }
    }
}

// MARK: - Earning Cell
struct EarningCell: View {
    let title: String
    let hours: Double
    let amount: Double
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: NoveraSpacing.xs) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(color)
                Spacer()
            }
            Text(amount.currencyFormatted)
                .font(NoveraFonts.title3(.bold))
                .foregroundStyle(NoveraColors.textPrimary)
            Text(title)
                .font(NoveraFonts.caption(.medium))
                .foregroundStyle(NoveraColors.textSecondary)
            Text(hours.hoursFormatted)
                .font(NoveraFonts.caption())
                .foregroundStyle(color)
        }
        .padding(NoveraSpacing.md)
        .glassBackground(cornerRadius: NoveraRadius.md)
        .noveraShadow(NoveraShadows.soft)
    }
}

// MARK: - Hours Row
struct HoursRow: View {
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
        VStack(spacing: 4) {
            HStack {
                Text(label)
                    .font(NoveraFonts.subheadline())
                    .foregroundStyle(NoveraColors.textPrimary)
                Spacer()
                Text(hours.hoursFormatted)
                    .font(NoveraFonts.subheadline(.semibold))
                    .foregroundStyle(color)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3).fill(color.opacity(0.12)).frame(height: 6)
                    RoundedRectangle(cornerRadius: 3).fill(color).frame(width: barWidth, height: 6)
                        .onAppear {
                            withAnimation(NoveraAnimation.spring.delay(0.2)) {
                                barWidth = geo.size.width * ratio
                            }
                        }
                }
            }
            .frame(height: 6)
        }
    }
}

// MARK: - Rate Row
struct RateRow: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(NoveraFonts.subheadline())
                Spacer()
                Text(String(format: "%.0f", value))
                    .font(NoveraFonts.subheadline(.semibold))
                    .foregroundStyle(NoveraColors.primary)
                    .frame(width: 60, alignment: .trailing)
            }
            Slider(value: $value, in: range, step: range == 50...1000 ? 10 : 0.1)
                .tint(NoveraColors.primary)
        }
    }
}

#Preview {
    EarningsView()
        .environmentObject(AppState())
}
