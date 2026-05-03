// DateHelper.swift
// Növera — Date Calculation Utilities

import Foundation

struct DateHelper {
    static let shared = DateHelper()
    private init() {}

    let calendar: Calendar = {
        var cal = Calendar.current
        cal.locale = Locale(identifier: "tr_TR")
        return cal
    }()

    // MARK: - Week generation
    func daysInWeek(containing date: Date) -> [Date] {
        let startOfWeek = calendar.date(
            from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        ) ?? date
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }

    // MARK: - Month generation
    func daysInMonth(containing date: Date) -> [Date] {
        guard
            let range = calendar.range(of: .day, in: .month, for: date),
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))
        else { return [] }

        return range.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }

    // MARK: - Shift duration
    func duration(from start: Date, to end: Date) -> TimeInterval {
        // Handle overnight shifts
        if end < start {
            let adjustedEnd = calendar.date(byAdding: .day, value: 1, to: end) ?? end
            return adjustedEnd.timeIntervalSince(start)
        }
        return end.timeIntervalSince(start)
    }

    func hours(from start: Date, to end: Date) -> Double {
        duration(from: start, to: end) / 3600
    }

    // MARK: - Night shift detection (22:00 - 06:00)
    func isNightShift(start: Date, end: Date) -> Bool {
        let startHour = calendar.component(.hour, from: start)
        let endHour = calendar.component(.hour, from: end)
        return startHour >= 22 || startHour < 6 || endHour >= 22 || endHour < 6
    }

    // MARK: - Overlap detection
    func overlaps(_ shift1: Shift, with shift2: Shift) -> Bool {
        shift1.startDate < shift2.endDate && shift1.endDate > shift2.startDate
    }

    // MARK: - Month summary
    func monthlyHoursSummary(shifts: [Shift], for date: Date) -> (normal: Double, overtime: Double, holiday: Double, night: Double) {
        let monthShifts = shifts.filter { calendar.isDate($0.startDate, equalTo: date, toGranularity: .month) }

        var normal: Double = 0
        var overtime: Double = 0
        var holiday: Double = 0
        var night: Double = 0

        for shift in monthShifts {
            let hrs = hours(from: shift.startDate, to: shift.endDate)
            if shift.isHoliday { holiday += hrs }
            if shift.isOvertime { overtime += hrs }
            if shift.shiftType == .night { night += hrs }
            if !shift.isOvertime && !shift.isHoliday { normal += hrs }
        }

        return (normal, overtime, holiday, night)
    }
}
