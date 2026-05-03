// CalendarViewModel.swift
// Növera — Calendar ViewModel

import SwiftUI
import Combine

enum CalendarViewMode: String, CaseIterable {
    case monthly = "Aylık"
    case weekly = "Haftalık"
    case daily = "Günlük"
}

final class CalendarViewModel: ObservableObject {
    @Published var viewMode: CalendarViewMode = .monthly
    @Published var selectedDate: Date = Date()
    @Published var displayedMonth: Date = Date()
    @Published var shiftsForSelectedDate: [Shift] = []
    @Published var allShiftsInMonth: [Shift] = []

    private let shiftService = ShiftService.shared
    private let repo = ShiftRepository.shared
    private var currentUserId: UUID? = UserRepository.shared.getCurrentUser()?.id

    // MARK: - Calendar grid
    var daysInDisplayedMonth: [Date] {
        DateHelper.shared.daysInMonth(containing: displayedMonth)
    }

    var firstWeekdayOffset: Int {
        let firstDay = displayedMonth.startOfMonth
        let weekday = Calendar.current.component(.weekday, from: firstDay)
        // Monday-first: Mon=1, Tue=2, ... Sun=7
        return (weekday + 5) % 7
    }

    func loadMonth() {
        guard let userId = currentUserId else { return }
        allShiftsInMonth = repo.getShifts(forMonth: displayedMonth)
            .filter { $0.userId == userId }
        loadSelectedDay()
    }

    func loadSelectedDay() {
        guard let userId = currentUserId else { return }
        shiftsForSelectedDate = repo.getShifts(for: selectedDate)
            .filter { $0.userId == userId }
            .sorted { $0.startDate < $1.startDate }
    }

    func selectDate(_ date: Date) {
        HapticManager.selection()
        withAnimation(NoveraAnimation.springFast) {
            selectedDate = date
        }
        loadSelectedDay()
    }

    func navigateMonth(by months: Int) {
        withAnimation(NoveraAnimation.spring) {
            displayedMonth = Calendar.current.date(
                byAdding: .month,
                value: months,
                to: displayedMonth
            ) ?? displayedMonth
        }
        loadMonth()
    }

    func shiftsForDate(_ date: Date) -> [Shift] {
        allShiftsInMonth.filter { Calendar.current.isDate($0.startDate, inSameDayAs: date) }
    }

    func shiftDensity(for date: Date) -> Int {
        shiftsForDate(date).count
    }

    var selectedDateTitle: String {
        selectedDate.dayFormatted + ", " + selectedDate.formatted("EEEE")
    }

    var displayedMonthTitle: String {
        displayedMonth.monthYearFormatted
    }
}
