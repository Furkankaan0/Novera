// CalendarView.swift
// Növera — Premium Shift Calendar

import SwiftUI

struct CalendarView: View {
    @StateObject private var vm = CalendarViewModel()
    @State private var showAddShift = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                calendarHeader
                    .padding(.horizontal, NoveraSpacing.md)
                    .padding(.top, NoveraSpacing.md)

                // Mode Picker
                modePicker
                    .padding(.horizontal, NoveraSpacing.md)
                    .padding(.top, NoveraSpacing.sm)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: NoveraSpacing.md) {
                        // Monthly grid
                        if vm.viewMode == .monthly {
                            monthlyCalendarGrid
                                .padding(.horizontal, NoveraSpacing.md)
                                .padding(.top, NoveraSpacing.md)
                        }

                        // Selected date shifts
                        selectedDaySection
                            .padding(.horizontal, NoveraSpacing.md)

                        Spacer(minLength: 100)
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationBarHidden(true)
            .onAppear { vm.loadMonth() }
            .sheet(isPresented: $showAddShift, onDismiss: { vm.loadMonth() }) {
                AddShiftView(preselectedDate: vm.selectedDate)
            }
        }
    }

    // MARK: - Header
    var calendarHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Takvim")
                    .font(NoveraFonts.largeTitle(.bold))
                Text(vm.displayedMonthTitle)
                    .font(NoveraFonts.callout())
                    .foregroundStyle(NoveraColors.textSecondary)
            }
            Spacer()
            HStack(spacing: NoveraSpacing.sm) {
                NoveraIconButton(icon: "chevron.left") { vm.navigateMonth(by: -1) }
                NoveraIconButton(icon: "chevron.right") { vm.navigateMonth(by: 1) }
                NoveraIconButton(icon: "plus", color: NoveraColors.primary) { showAddShift = true }
            }
        }
    }

    // MARK: - Mode Picker
    var modePicker: some View {
        HStack(spacing: 0) {
            ForEach(CalendarViewMode.allCases, id: \.self) { mode in
                Button(action: {
                    withAnimation(NoveraAnimation.springFast) {
                        vm.viewMode = mode
                    }
                    HapticManager.selection()
                }) {
                    Text(mode.rawValue)
                        .font(NoveraFonts.subheadline(.medium))
                        .foregroundStyle(vm.viewMode == mode ? .white : NoveraColors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(
                            RoundedRectangle(cornerRadius: NoveraRadius.sm - 4, style: .continuous)
                                .fill(vm.viewMode == mode ? NoveraColors.primary : .clear)
                        )
                }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: NoveraRadius.sm, style: .continuous)
                .fill(Color(UIColor.tertiarySystemGroupedBackground))
        )
    }

    // MARK: - Monthly Grid
    var monthlyCalendarGrid: some View {
        VStack(spacing: 4) {
            // Weekday headers
            HStack {
                ForEach(["Pt", "Sa", "Ça", "Pe", "Cu", "Ct", "Pz"], id: \.self) { day in
                    Text(day)
                        .font(NoveraFonts.caption(.semibold))
                        .foregroundStyle(NoveraColors.textTertiary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, 4)

            // Day cells
            let days = vm.daysInDisplayedMonth
            let offset = vm.firstWeekdayOffset

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                // Empty cells for offset
                ForEach(0..<offset, id: \.self) { _ in
                    Color.clear.frame(height: 48)
                }
                // Day cells
                ForEach(days, id: \.self) { date in
                    CalendarDayCell(
                        date: date,
                        isSelected: Calendar.current.isDate(date, inSameDayAs: vm.selectedDate),
                        isToday: date.isToday,
                        shiftCount: vm.shiftDensity(for: date),
                        shifts: vm.shiftsForDate(date)
                    )
                    .onTapGesture { vm.selectDate(date) }
                }
            }
        }
        .padding(NoveraSpacing.md)
        .glassBackground(cornerRadius: NoveraRadius.lg)
        .noveraShadow(NoveraShadows.soft)
    }

    // MARK: - Selected Day
    var selectedDaySection: some View {
        VStack(alignment: .leading, spacing: NoveraSpacing.sm) {
            HStack {
                Text(vm.selectedDateTitle)
                    .font(NoveraFonts.title3(.semibold))
                Spacer()
                Button(action: { showAddShift = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(NoveraColors.primary)
                }
            }

            if vm.shiftsForSelectedDate.isEmpty {
                NoveraEmptyState(
                    icon: "calendar.badge.plus",
                    title: "Bu gün serbest",
                    subtitle: "Vardiya eklemek için + butonuna basın",
                    actionTitle: "Vardiya Ekle"
                ) { showAddShift = true }
            } else {
                ForEach(vm.shiftsForSelectedDate) { shift in
                    NavigationLink(destination: ShiftDetailView(shift: shift)) {
                        ShiftPreviewCard(shift: shift)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

// MARK: - Calendar Day Cell
struct CalendarDayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let shiftCount: Int
    let shifts: [Shift]

    var dayNumber: String {
        Calendar.current.component(.day, from: date).description
    }

    var body: some View {
        VStack(spacing: 3) {
            ZStack {
                if isSelected {
                    Circle()
                        .fill(NoveraColors.primaryGradient)
                        .frame(width: 34, height: 34)
                } else if isToday {
                    Circle()
                        .strokeBorder(NoveraColors.primary, lineWidth: 1.5)
                        .frame(width: 34, height: 34)
                }

                Text(dayNumber)
                    .font(NoveraFonts.subheadline(isToday || isSelected ? .bold : .regular))
                    .foregroundStyle(
                        isSelected ? .white :
                        isToday ? NoveraColors.primary :
                        NoveraColors.textPrimary
                    )
            }

            // Shift density dots
            if shiftCount > 0 {
                HStack(spacing: 2) {
                    ForEach(0..<min(shiftCount, 3), id: \.self) { idx in
                        Circle()
                            .fill(idx < shifts.count ? shifts[idx].shiftType.color : NoveraColors.primary)
                            .frame(width: 5, height: 5)
                    }
                }
            }
        }
        .frame(height: 48)
        .accessibilityLabel("\(dayNumber), \(shiftCount) vardiya")
    }
}

#Preview {
    CalendarView()
        .environmentObject(AppState())
}
