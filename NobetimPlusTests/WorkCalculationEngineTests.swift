import XCTest
@testable import NobetimPlus

final class WorkCalculationEngineTests: XCTestCase {
    private let calendar = Calendar(identifier: .gregorian)

    func testDayShiftTwelveHours() {
        let shift = makeShift(hour: 8, duration: 12)
        XCTAssertEqual(WorkCalculationEngine(calendar: calendar).calculateShiftDuration(shift), 12, accuracy: 0.01)
    }

    func testOvernightShiftTwelveHours() {
        let start = date(hour: 20)
        let end = date(hour: 8)
        let shift = Shift(title: "20-08", date: start, startDate: start, endDate: end, department: "Acil", unit: "Acil", type: .night, workKind: .nightWork, isNightShift: true)
        XCTAssertEqual(WorkCalculationEngine(calendar: calendar).calculateShiftDuration(shift), 12, accuracy: 0.01)
    }

    func testEightHourShift() {
        let shift = makeShift(hour: 8, duration: 8)
        XCTAssertEqual(WorkCalculationEngine(calendar: calendar).calculateShiftDuration(shift), 8, accuracy: 0.01)
    }

    func testDurationModeThreeHoursEndsAtTwenty() {
        let start = date(hour: 17)
        let end = WorkCalculationEngine(calendar: calendar).endDate(startDate: start, durationHours: 3)
        XCTAssertEqual(calendar.component(.hour, from: end), 20)
    }

    func testDurationModeTwelveHoursOvernightEndsAtEight() {
        let start = date(hour: 20)
        let end = WorkCalculationEngine(calendar: calendar).endDate(startDate: start, durationHours: 12)
        XCTAssertEqual(calendar.component(.hour, from: end), 8)
    }

    func testSevenAndHalfHourHolidayIsSeparated() {
        let shift = makeShift(hour: 9, duration: 7.5, kind: .officialHoliday, holiday: true)
        let hours = WorkCalculationEngine(calendar: calendar).calculateHolidayHours([shift])
        XCTAssertEqual(hours, 7.5, accuracy: 0.01)
    }

    func testMultipleShiftsSameDayAreSummed() {
        let shifts = [
            makeShift(hour: 8, duration: 8),
            makeShift(hour: 17, duration: 3, kind: .overtime)
        ]
        let total = WorkCalculationEngine(calendar: calendar).calculateMonthlyTotal(shifts: shifts, month: date(hour: 0))
        XCTAssertEqual(total, 11, accuracy: 0.01)
    }

    func testOvertimeIsReportedSeparatelyFromNormalShift() {
        let shifts = [
            makeShift(hour: 8, duration: 8, kind: .normalShift),
            makeShift(hour: 17, duration: 3, kind: .overtime)
        ]
        let summary = WorkCalculationEngine(calendar: calendar).makeMonthlySummary(
            shifts: shifts,
            month: date(hour: 0),
            settings: WorkCalculationSettings(monthlyNormalHours: 160, overtimeHourlyRate: 100, holidayHourlyRate: 150, nightWorkMultiplier: 1, additionalPayment: 0)
        )
        XCTAssertEqual(summary.normalShiftHours, 8, accuracy: 0.01)
        XCTAssertEqual(summary.overtimeHours, 3, accuracy: 0.01)
    }

    private func makeShift(hour: Int, duration: Double, kind: WorkEntryKind = .normalShift, holiday: Bool = false) -> Shift {
        let start = date(hour: hour)
        let end = start.addingTimeInterval(duration * 3600)
        return Shift(title: "Test", date: start, startDate: start, endDate: end, department: "Acil", unit: "Acil", type: .day, workKind: kind, isOfficialHoliday: holiday, colorTag: kind.colorTag)
    }

    private func date(hour: Int) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 5, day: 5, hour: hour, minute: 0))!
    }
}
