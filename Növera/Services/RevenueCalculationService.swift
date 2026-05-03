// RevenueCalculationService.swift
// Növera — Earnings Calculation Engine
// NOTE: Bu hesaplamalar tahmini niteliktedir. Gerçek bordro için muhasebe uzmanına danışın.

import Foundation

final class RevenueCalculationService {
    static let shared = RevenueCalculationService()
    private init() {}

    // MARK: - Monthly Summary
    func calculateMonthlySummary(
        shifts: [Shift],
        for month: Date,
        hourlyRate: Double,
        overtimeMultiplier: Double = NoveraConstants.defaultOvertimeMultiplier,
        holidayMultiplier: Double = NoveraConstants.defaultHolidayMultiplier,
        nightBonusRate: Double = NoveraConstants.defaultNightBonusRate
    ) -> EarningsSummary {
        let cal = Calendar.current
        let monthShifts = shifts.filter {
            cal.isDate($0.startDate, equalTo: month, toGranularity: .month)
            && $0.deletedAt == nil
        }

        var normalHours: Double = 0
        var overtimeHours: Double = 0
        var holidayHours: Double = 0
        var nightHours: Double = 0

        for shift in monthShifts {
            let hrs = DateHelper.shared.hours(from: shift.startDate, to: shift.endDate)

            if shift.isHoliday {
                holidayHours += hrs
            } else if shift.isOvertime || shift.shiftType == .overtime {
                overtimeHours += hrs
            } else {
                normalHours += hrs
            }

            if DateHelper.shared.isNightShift(start: shift.startDate, end: shift.endDate) {
                nightHours += hrs
            }
        }

        return EarningsSummary(
            month: month,
            normalHours: normalHours,
            overtimeHours: overtimeHours,
            holidayHours: holidayHours,
            nightHours: nightHours,
            hourlyRate: hourlyRate,
            overtimeMultiplier: overtimeMultiplier,
            holidayMultiplier: holidayMultiplier,
            nightBonusRate: nightBonusRate
        )
    }

    // MARK: - Last 6 months summaries
    func last6MonthsSummaries(
        shifts: [Shift],
        hourlyRate: Double
    ) -> [EarningsSummary] {
        let cal = Calendar.current
        return (0..<6).reversed().compactMap { offset -> EarningsSummary? in
            guard let month = cal.date(byAdding: .month, value: -offset, to: Date()) else { return nil }
            return calculateMonthlySummary(shifts: shifts, for: month, hourlyRate: hourlyRate)
        }
    }

    // MARK: - Weekly hours for chart
    func weeklyHoursBreakdown(shifts: [Shift], userId: UUID) -> [(String, Double)] {
        let days = DateHelper.shared.daysInWeek(containing: Date())
        let weekdaySymbols = ["Pt", "Sa", "Ça", "Pe", "Cu", "Ct", "Pz"]

        return days.enumerated().map { index, day in
            let hours = shifts
                .filter { $0.userId == userId && Calendar.current.isDate($0.startDate, inSameDayAs: day) }
                .reduce(0.0) { $0 + $1.durationInHours }
            return (weekdaySymbols[index], hours)
        }
    }

    // MARK: - Overtime calculation
    func overtimeHoursForMonth(shifts: [Shift], month: Date, standardWeeklyHours: Double = NoveraConstants.standardWeeklyHours) -> Double {
        let cal = Calendar.current
        let monthShifts = shifts.filter {
            cal.isDate($0.startDate, equalTo: month, toGranularity: .month)
        }

        // Group by week
        var weeklyHours: [Int: Double] = [:]
        for shift in monthShifts {
            let week = cal.component(.weekOfYear, from: shift.startDate)
            weeklyHours[week, default: 0] += shift.durationInHours
        }

        return weeklyHours.values.reduce(0) { acc, hours in
            acc + max(0, hours - standardWeeklyHours)
        }
    }
}
