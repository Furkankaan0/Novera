// RevenueCalculationTests.swift
// NöveraTests — Revenue Calculation Service Unit Tests

import XCTest
@testable import Növera

final class RevenueCalculationTests: XCTestCase {
    var service: RevenueCalculationService!
    var testUserId: UUID!

    override func setUp() {
        super.setUp()
        service = RevenueCalculationService.shared
        testUserId = UUID()
    }

    // MARK: - Basic Revenue Tests
    func testNormalHoursRevenue() {
        let shifts = [makeShift(hours: 8, type: .day)]
        let summary = service.calculateMonthlySummary(
            shifts: shifts,
            for: Date(),
            hourlyRate: 100.0
        )
        XCTAssertEqual(summary.normalHours, 8, accuracy: 0.1)
        XCTAssertEqual(summary.normalRevenue, 800.0, accuracy: 0.1)
    }

    func testOvertimeRevenue() {
        let shifts = [makeShift(hours: 10, type: .overtime, isOvertime: true)]
        let summary = service.calculateMonthlySummary(
            shifts: shifts,
            for: Date(),
            hourlyRate: 100.0,
            overtimeMultiplier: 1.5
        )
        XCTAssertEqual(summary.overtimeRevenue, 1500.0, accuracy: 0.1)
    }

    func testHolidayRevenue() {
        let shifts = [makeShift(hours: 8, type: .holiday, isHoliday: true)]
        let summary = service.calculateMonthlySummary(
            shifts: shifts,
            for: Date(),
            hourlyRate: 100.0,
            holidayMultiplier: 2.0
        )
        XCTAssertEqual(summary.holidayRevenue, 1600.0, accuracy: 0.1)
    }

    func testNightBonus() {
        // Night shift: 22:00 - 06:00
        let start = Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: Date())!
        let end = Calendar.current.date(bySettingHour: 6, minute: 0, second: 0, of: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)!
        let shift = Shift(
            userId: testUserId,
            title: "Gece",
            startDate: start,
            endDate: end,
            shiftType: .night
        )
        let summary = service.calculateMonthlySummary(
            shifts: [shift],
            for: Date(),
            hourlyRate: 100.0,
            nightBonusRate: 0.25
        )
        XCTAssertGreaterThan(summary.nightHours, 0)
        XCTAssertGreaterThan(summary.nightBonus, 0)
    }

    func testEmptyMonthReturnsZero() {
        let summary = service.calculateMonthlySummary(
            shifts: [],
            for: Date(),
            hourlyRate: 150.0
        )
        XCTAssertEqual(summary.estimatedRevenue, 0)
        XCTAssertEqual(summary.totalHours, 0)
    }

    func testTotalRevenueIsSum() {
        let shifts = [
            makeShift(hours: 8, type: .day),
            makeShift(hours: 4, type: .overtime, isOvertime: true)
        ]
        let summary = service.calculateMonthlySummary(
            shifts: shifts,
            for: Date(),
            hourlyRate: 100.0,
            overtimeMultiplier: 1.5
        )
        let expected = summary.normalRevenue + summary.overtimeRevenue + summary.holidayRevenue + summary.nightBonus
        XCTAssertEqual(summary.estimatedRevenue, expected, accuracy: 0.01)
    }

    // MARK: - Overtime Detection Tests
    func testOvertimeDetectionOverStandardWeek() {
        // 50 hours in a week → 5 overtime hours
        let weekStart = Date().startOfWeek
        var shifts: [Shift] = []
        for day in 0..<5 {
            let start = Calendar.current.date(byAdding: .day, value: day, to: weekStart)!
            let end = Calendar.current.date(byAdding: .hour, value: 10, to: start)!
            shifts.append(Shift(userId: testUserId, title: "Test", startDate: start, endDate: end))
        }
        let overtime = service.overtimeHoursForMonth(shifts: shifts, month: Date(), standardWeeklyHours: 45)
        XCTAssertGreaterThan(overtime, 0)
    }

    func testNoOvertimeUnderStandard() {
        let weekStart = Date().startOfWeek
        var shifts: [Shift] = []
        for day in 0..<5 {
            let start = Calendar.current.date(byAdding: .day, value: day, to: weekStart)!
            let end = Calendar.current.date(byAdding: .hour, value: 8, to: start)!
            shifts.append(Shift(userId: testUserId, title: "Test", startDate: start, endDate: end))
        }
        // 40h < 45h standard
        let overtime = service.overtimeHoursForMonth(shifts: shifts, month: Date(), standardWeeklyHours: 45)
        XCTAssertEqual(overtime, 0, accuracy: 0.1)
    }

    // MARK: - Helper
    private func makeShift(
        hours: Double,
        type: ShiftType = .day,
        isHoliday: Bool = false,
        isOvertime: Bool = false
    ) -> Shift {
        let start = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!
        let end = Calendar.current.date(byAdding: .hour, value: Int(hours), to: start)!
        return Shift(
            userId: testUserId,
            title: "Test Shift",
            startDate: start,
            endDate: end,
            shiftType: type,
            isHoliday: isHoliday,
            isOvertime: isOvertime
        )
    }
}
