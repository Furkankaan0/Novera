import Foundation

struct CreateShiftUseCase {
    private let calendar: Calendar
    private let calculator: WorkCalculationEngine

    init(calendar: Calendar = .current, calculator: WorkCalculationEngine = WorkCalculationEngine()) {
        self.calendar = calendar
        self.calculator = calculator
    }

    func makeShift(
        title: String,
        date: Date,
        startTime: Date,
        endTime: Date?,
        durationHours: Double?,
        department: String,
        unit: String,
        type: ShiftType,
        workKind: WorkEntryKind,
        isOfficialHoliday: Bool,
        isNightShift: Bool,
        reminderEnabled: Bool,
        notes: String,
        colorTag: ShiftColorTag? = nil
    ) -> Shift {
        let startDate = combine(day: date, time: startTime)
        let resolvedEndDate: Date
        if let durationHours {
            resolvedEndDate = calculator.endDate(startDate: startDate, durationHours: durationHours)
        } else {
            let rawEnd = combine(day: date, time: endTime ?? startTime)
            resolvedEndDate = rawEnd <= startDate ? calendar.date(byAdding: .day, value: 1, to: rawEnd) ?? rawEnd : rawEnd
        }

        return Shift(
            title: title.isEmpty ? workKind.localizedTitle : title,
            date: date,
            startDate: startDate,
            endDate: resolvedEndDate,
            department: department,
            unit: unit,
            type: type,
            workKind: workKind,
            notes: notes,
            isNightShift: isNightShift || workKind == .nightWork,
            isOfficialHoliday: isOfficialHoliday || workKind == .officialHoliday,
            isWeekend: calendar.isDateInWeekend(date) || workKind == .weekendWork,
            colorTag: colorTag ?? workKind.colorTag,
            reminderEnabled: reminderEnabled
        )
    }

    private func combine(day: Date, time: Date) -> Date {
        let dayComponents = calendar.dateComponents([.year, .month, .day], from: day)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        var merged = DateComponents()
        merged.year = dayComponents.year
        merged.month = dayComponents.month
        merged.day = dayComponents.day
        merged.hour = timeComponents.hour
        merged.minute = timeComponents.minute
        return calendar.date(from: merged) ?? day
    }
}
