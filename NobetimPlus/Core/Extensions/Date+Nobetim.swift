import Foundation

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    func addingDays(_ value: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: value, to: self) ?? self
    }
}

extension Array where Element == Shift {
    func shifts(on date: Date, calendar: Calendar = .current) -> [Shift] {
        filter { calendar.isDate($0.date, inSameDayAs: date) }
            .sorted { $0.startDate < $1.startDate }
    }
}
