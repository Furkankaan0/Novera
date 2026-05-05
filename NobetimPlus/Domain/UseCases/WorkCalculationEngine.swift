import Foundation

struct WorkCalculationSettings: Codable, Hashable {
    var monthlyNormalHours: Double
    var overtimeHourlyRate: Double
    var holidayHourlyRate: Double
    var nightWorkMultiplier: Double
    var additionalPayment: Double

    static let demo = WorkCalculationSettings(
        monthlyNormalHours: 160,
        overtimeHourlyRate: 115,
        holidayHourlyRate: 180,
        nightWorkMultiplier: 1.15,
        additionalPayment: 0
    )
}

struct WorkCalculationEngine {
    private let calendar: Calendar

    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    func calculateShiftDuration(_ shift: Shift) -> Double {
        let seconds = normalizedEndDate(start: shift.startDate, end: shift.endDate).timeIntervalSince(shift.startDate)
        let rawHours = max(seconds / 3600, 0)
        return max(rawHours - Double(shift.breakMinutes) / 60, 0)
    }

    func endDate(startDate: Date, durationHours: Double) -> Date {
        startDate.addingTimeInterval(durationHours * 3600)
    }

    func calculateMonthlyTotal(shifts: [Shift], month: Date) -> Double {
        shiftsForMonth(shifts, month: month).reduce(0) { $0 + calculateShiftDuration($1) }
    }

    func calculateOvertime(totalHours: Double, normalHours: Double) -> Double {
        max(totalHours - normalHours, 0)
    }

    func calculateHolidayHours(_ shifts: [Shift]) -> Double {
        shifts.filter { $0.isOfficialHoliday || $0.workKind == .officialHoliday }
            .reduce(0) { $0 + calculateShiftDuration($1) }
    }

    func calculateNightShiftHours(_ shifts: [Shift]) -> Double {
        shifts.filter { $0.isNightShift || $0.type == .night || $0.workKind == .nightWork }
            .reduce(0) { $0 + calculateShiftDuration($1) }
    }

    func calculateWeekendHours(_ shifts: [Shift]) -> Double {
        shifts.filter { $0.isWeekend || calendar.isDateInWeekend($0.date) || $0.workKind == .weekendWork }
            .reduce(0) { $0 + calculateShiftDuration($1) }
    }

    func calculateEstimatedIncome(summary: WorkSummary, settings: WorkCalculationSettings) -> Double {
        (summary.overtimeHours * settings.overtimeHourlyRate)
            + (summary.officialHolidayHours * settings.holidayHourlyRate)
            + settings.additionalPayment
    }

    func generateWorkloadScore(shifts: [Shift], month: Date = .now) -> Double {
        let monthShifts = shiftsForMonth(shifts, month: month)
        let longShiftCount = monthShifts.filter { calculateShiftDuration($0) >= 12 }.count
        let nightCount = monthShifts.filter(\.isNightShift).count
        let total = calculateMonthlyTotal(shifts: monthShifts, month: month)
        return min((total / 180 * 60) + Double(longShiftCount * 6) + Double(nightCount * 4), 100)
    }

    func makeMonthlySummary(shifts: [Shift], month: Date, settings: WorkCalculationSettings) -> WorkSummary {
        let monthShifts = shiftsForMonth(shifts, month: month)
        let total = monthShifts.reduce(0) { $0 + calculateShiftDuration($1) }
        let overtimeByKind = monthShifts.filter { [.overtime, .shortExtra].contains($0.workKind) }
            .reduce(0) { $0 + calculateShiftDuration($1) }
        let overtime = max(calculateOvertime(totalHours: total, normalHours: settings.monthlyNormalHours), overtimeByKind)
        let holiday = calculateHolidayHours(monthShifts)
        let summary = WorkSummary(
            month: month,
            monthIdentifier: Self.monthIdentifier(for: month, calendar: calendar),
            totalWorkHours: total,
            normalShiftHours: monthShifts.filter { $0.workKind == .normalShift }.reduce(0) { $0 + calculateShiftDuration($1) },
            overtimeHours: overtime,
            officialHolidayHours: holiday,
            nightShiftHours: calculateNightShiftHours(monthShifts),
            weekendHours: calculateWeekendHours(monthShifts),
            onCallHours: monthShifts.filter { $0.workKind == .onCall || $0.type == .onCall }.reduce(0) { $0 + calculateShiftDuration($1) },
            trainingHours: monthShifts.filter { $0.workKind == .training || $0.type == .training }.reduce(0) { $0 + calculateShiftDuration($1) },
            customDurationHours: monthShifts.filter { $0.workKind == .customDuration || $0.type == .custom }.reduce(0) { $0 + calculateShiftDuration($1) },
            estimatedOvertimeIncome: overtime * settings.overtimeHourlyRate,
            estimatedHolidayIncome: holiday * settings.holidayHourlyRate,
            estimatedTotalExtraIncome: 0
        )
        var enriched = summary
        enriched.estimatedTotalExtraIncome = calculateEstimatedIncome(summary: summary, settings: settings)
        return enriched
    }

    func weeklyPoints(shifts: [Shift], referenceDate: Date = .now) -> [WeeklyWorkPoint] {
        let start = calendar.dateInterval(of: .weekOfYear, for: referenceDate)?.start ?? referenceDate
        return (0..<7).compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: offset, to: start) else { return nil }
            let hours = shifts.filter { calendar.isDate($0.date, inSameDayAs: day) }
                .reduce(0) { $0 + calculateShiftDuration($1) }
            return WeeklyWorkPoint(label: day.formatted(.dateTime.weekday(.narrow)), hours: hours)
        }
    }

    func distribution(shifts: [Shift], month: Date = .now) -> [ShiftTypeDistribution] {
        Dictionary(grouping: shiftsForMonth(shifts, month: month), by: \.workKind)
            .map { kind, items in
                ShiftTypeDistribution(
                    label: kind.localizedTitle,
                    hours: items.reduce(0) { $0 + calculateShiftDuration($1) },
                    colorTag: kind.colorTag
                )
            }
            .sorted { $0.hours > $1.hours }
    }

    private func shiftsForMonth(_ shifts: [Shift], month: Date) -> [Shift] {
        shifts.filter { calendar.isDate($0.date, equalTo: month, toGranularity: .month) }
    }

    private func normalizedEndDate(start: Date, end: Date) -> Date {
        end <= start ? calendar.date(byAdding: .day, value: 1, to: end) ?? end.addingTimeInterval(24 * 3600) : end
    }

    private static func monthIdentifier(for date: Date, calendar: Calendar) -> String {
        let components = calendar.dateComponents([.year, .month], from: date)
        return "\(components.year ?? 0)-\(components.month ?? 0)"
    }
}
