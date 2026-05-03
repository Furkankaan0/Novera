// DashboardView.swift
// Növera — Premium Dashboard

import SwiftUI

struct DashboardView: View {
    @StateObject private var vm = DashboardViewModel()
    @EnvironmentObject var appState: AppState
    @State private var showAddShift = false
    @State private var cardOffset: CGFloat = 30
    @State private var cardOpacity: Double = 0

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                // Background
                backgroundGradient

                ScrollView(showsIndicators: false) {
                    VStack(spacing: NoveraSpacing.lg) {
                        // Header
                        headerSection
                            .padding(.horizontal, NoveraSpacing.md)

                        // Stat cards grid
                        statCardsSection
                            .padding(.horizontal, NoveraSpacing.md)

                        // Weekly hours chart
                        weeklyChartSection
                            .padding(.horizontal, NoveraSpacing.md)

                        // Upcoming shift
                        if let upcoming = vm.upcomingShift {
                            upcomingShiftSection(upcoming)
                                .padding(.horizontal, NoveraSpacing.md)
                        }

                        // Today's shifts
                        if !vm.todayShifts.isEmpty {
                            todayShiftsSection
                                .padding(.horizontal, NoveraSpacing.md)
                        }

                        // Team announcements
                        if !vm.recentAnnouncements.isEmpty {
                            announcementsSection
                                .padding(.horizontal, NoveraSpacing.md)
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(.top, NoveraSpacing.sm)
                }

                // FAB
                NoveraFAB(icon: "plus") {
                    showAddShift = true
                    HapticManager.impact(.medium)
                }
                .padding(.trailing, NoveraSpacing.lg)
                .padding(.bottom, NoveraSpacing.xl)
            }
            .navigationBarHidden(true)
            .onAppear {
                vm.loadData()
                withAnimation(NoveraAnimation.spring.delay(0.1)) {
                    cardOffset = 0
                    cardOpacity = 1
                }
            }
            .sheet(isPresented: $showAddShift, onDismiss: { vm.loadData() }) {
                AddShiftView()
            }
        }
    }

    // MARK: - Background
    var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(hue: 0.57, saturation: 0.04, brightness: 0.98),
                Color(hue: 0.55, saturation: 0.08, brightness: 0.96)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    // MARK: - Header
    var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(vm.greetingText)
                    .font(NoveraFonts.callout())
                    .foregroundStyle(NoveraColors.textSecondary)
                Text(vm.userName) + Text(" 👋")
                    .foregroundStyle(NoveraColors.primary)
                Text(vm.userName)
                    .font(NoveraFonts.largeTitle(.bold))
                    .foregroundStyle(NoveraColors.textPrimary)
                Text(vm.todayDateString)
                    .font(NoveraFonts.footnote())
                    .foregroundStyle(NoveraColors.textTertiary)
            }

            Spacer()

            // Profile avatar
            NavigationLink(destination: ProfileView()) {
                ZStack {
                    Circle()
                        .fill(NoveraColors.primaryGradient)
                        .frame(width: 46, height: 46)
                    Text(vm.currentUser?.initials ?? "?")
                        .font(NoveraFonts.headline(.bold))
                        .foregroundStyle(.white)
                }
                .noveraShadow(NoveraShadows.primary)
            }
        }
        .offset(y: cardOffset)
        .opacity(cardOpacity)
    }

    // MARK: - Stat Cards
    var statCardsSection: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: NoveraSpacing.sm
        ) {
            MetricCard(
                title: "Haftalık Saat",
                value: vm.weeklyHoursFormatted,
                subtitle: "Bu hafta",
                icon: "clock.fill",
                color: NoveraColors.primary,
                trend: vm.weeklyHours > 40 ? .up : .neutral,
                trendValue: vm.weeklyHours > 40 ? "+FZ" : nil
            )
            .offset(y: cardOffset)
            .opacity(cardOpacity)

            MetricCard(
                title: "Aylık Nöbet",
                value: "\(vm.monthlyShiftCount)",
                subtitle: "Bu ay",
                icon: "calendar.badge.clock",
                color: NoveraColors.accent
            )
            .offset(y: cardOffset)
            .opacity(cardOpacity)
            .animation(NoveraAnimation.spring.delay(0.05), value: cardOpacity)

            MetricCard(
                title: "Tahmini FZ",
                value: vm.overtimeFormatted,
                subtitle: "Fazla mesai",
                icon: "clock.badge.plus",
                color: NoveraColors.shiftOvertime,
                trend: vm.estimatedOvertime > 0 ? .up : .neutral,
                trendValue: vm.estimatedOvertime > 0 ? "Var" : nil
            )
            .offset(y: cardOffset)
            .opacity(cardOpacity)
            .animation(NoveraAnimation.spring.delay(0.10), value: cardOpacity)

            MetricCard(
                title: "Bugün",
                value: vm.todayShifts.isEmpty ? "Serbest" : "\(vm.todayShifts.count) Nöbet",
                subtitle: "Durum",
                icon: vm.todayShifts.isEmpty ? "sun.horizon.fill" : "stethoscope",
                color: vm.todayShifts.isEmpty ? NoveraColors.accentGreen : NoveraColors.shiftDay
            )
            .offset(y: cardOffset)
            .opacity(cardOpacity)
            .animation(NoveraAnimation.spring.delay(0.15), value: cardOpacity)
        }
    }

    // MARK: - Weekly Chart
    var weeklyChartSection: some View {
        VStack(alignment: .leading, spacing: NoveraSpacing.sm) {
            NoveraSectionHeader(title: "Bu Hafta", subtitle: "Çalışma saatleri dağılımı")

            GlassCard {
                WeeklyHoursBar(
                    days: vm.weeklyData,
                    maxHours: 12,
                    color: NoveraColors.primary
                )
            }
        }
        .offset(y: cardOffset)
        .opacity(cardOpacity)
        .animation(NoveraAnimation.spring.delay(0.2), value: cardOpacity)
    }

    // MARK: - Upcoming Shift
    func upcomingShiftSection(_ shift: Shift) -> some View {
        VStack(alignment: .leading, spacing: NoveraSpacing.sm) {
            NoveraSectionHeader(title: "Yaklaşan Nöbet")

            NavigationLink(destination: ShiftDetailView(shift: shift)) {
                VStack(alignment: .leading, spacing: NoveraSpacing.sm) {
                    HStack {
                        Image(systemName: "timer")
                            .foregroundStyle(NoveraColors.primary)
                        Text(shift.startDate.dayFormatted)
                            .font(NoveraFonts.footnote(.semibold))
                            .foregroundStyle(NoveraColors.primary)
                        Spacer()
                        Text(shift.durationInHours.hoursFormatted)
                            .font(NoveraFonts.caption(.semibold))
                            .foregroundStyle(NoveraColors.textSecondary)
                    }
                    ShiftPreviewCard(shift: shift)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .offset(y: cardOffset)
        .opacity(cardOpacity)
        .animation(NoveraAnimation.spring.delay(0.25), value: cardOpacity)
    }

    // MARK: - Today Shifts
    var todayShiftsSection: some View {
        VStack(alignment: .leading, spacing: NoveraSpacing.sm) {
            NoveraSectionHeader(
                title: "Bugünkü Nöbetler",
                subtitle: "\(vm.todayShifts.count) vardiya"
            )

            ForEach(vm.todayShifts) { shift in
                NavigationLink(destination: ShiftDetailView(shift: shift)) {
                    ShiftPreviewCard(shift: shift, isCompact: true)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .offset(y: cardOffset)
        .opacity(cardOpacity)
        .animation(NoveraAnimation.spring.delay(0.3), value: cardOpacity)
    }

    // MARK: - Announcements
    var announcementsSection: some View {
        VStack(alignment: .leading, spacing: NoveraSpacing.sm) {
            NoveraSectionHeader(
                title: "Ekip Duyuruları",
                action: { appState.selectedTab = .teams },
                actionTitle: "Tümü"
            )

            ForEach(vm.recentAnnouncements) { announcement in
                AnnouncementRow(announcement: announcement)
            }
        }
        .offset(y: cardOffset)
        .opacity(cardOpacity)
        .animation(NoveraAnimation.spring.delay(0.35), value: cardOpacity)
    }
}

// MARK: - Announcement Row
struct AnnouncementRow: View {
    let announcement: Announcement

    var body: some View {
        HStack(spacing: NoveraSpacing.sm) {
            ZStack {
                Circle()
                    .fill(NoveraColors.primary.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: "megaphone.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(NoveraColors.primary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(announcement.title)
                    .font(NoveraFonts.subheadline(.semibold))
                    .foregroundStyle(NoveraColors.textPrimary)
                    .lineLimit(1)
                Text(announcement.message)
                    .font(NoveraFonts.caption())
                    .foregroundStyle(NoveraColors.textSecondary)
                    .lineLimit(2)
                Text(announcement.createdByName + " • " + announcement.createdAt.dayFormatted)
                    .font(NoveraFonts.caption())
                    .foregroundStyle(NoveraColors.textTertiary)
            }
        }
        .padding(NoveraSpacing.md)
        .glassBackground(cornerRadius: NoveraRadius.md)
        .noveraShadow(NoveraShadows.soft)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(announcement.title): \(announcement.message)")
    }
}

#Preview {
    DashboardView()
        .environmentObject(AppState())
        .environmentObject(AuthService())
}
