// ShiftRepositoryTests.swift
// NöveraTests — Shift Repository & Overlap Tests

import XCTest
@testable import Növera

final class ShiftRepositoryTests: XCTestCase {
    var repository: MockShiftRepository!
    var service: ShiftService!
    var userId: UUID!

    override func setUp() {
        super.setUp()
        repository = MockShiftRepository()
        service = ShiftService(repository: repository)
        userId = UUID()
    }

    // MARK: - CRUD
    func testAddShift() throws {
        let shift = makeShift(startHour: 8, endHour: 16)
        try service.addShift(shift)
        XCTAssertEqual(repository.shifts.count, 1)
    }

    func testDeleteShift() throws {
        let shift = makeShift(startHour: 8, endHour: 16)
        try service.addShift(shift)
        service.deleteShift(id: shift.id)
        XCTAssertTrue(repository.shifts.isEmpty)
    }

    // MARK: - Overlap Detection
    func testOverlapThrowsError() throws {
        let shift1 = makeShift(startHour: 8, endHour: 16)
        try service.addShift(shift1)

        let shift2 = makeShift(startHour: 12, endHour: 20) // Overlaps with shift1
        XCTAssertThrowsError(try service.addShift(shift2)) { error in
            XCTAssertEqual(error as? ShiftError, ShiftError.overlappingShift)
        }
    }

    func testNonOverlappingShiftsAllowed() throws {
        let shift1 = makeShift(startHour: 8, endHour: 16)
        let shift2 = makeShift(startHour: 16, endHour: 24)
        try service.addShift(shift1)
        XCTAssertNoThrow(try service.addShift(shift2))
        XCTAssertEqual(repository.shifts.count, 2)
    }

    func testAdjacentShiftsNoOverlap() throws {
        // End of shift1 = start of shift2 (no overlap)
        let shift1 = makeShift(startHour: 8, endHour: 16)
        let shift2 = makeShift(startHour: 16, endHour: 22)
        try service.addShift(shift1)
        XCTAssertNoThrow(try service.addShift(shift2))
    }

    func testCompleteOverlapThrows() throws {
        let shift1 = makeShift(startHour: 6, endHour: 22)
        try service.addShift(shift1)

        let shift2 = makeShift(startHour: 8, endHour: 16) // Fully inside shift1
        XCTAssertThrowsError(try service.addShift(shift2))
    }

    // MARK: - Date Calculation
    func testShiftDurationCalculation() {
        let shift = makeShift(startHour: 8, endHour: 16)
        XCTAssertEqual(shift.durationInHours, 8.0, accuracy: 0.01)
    }

    func testOvernightShiftDuration() {
        let start = Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: Date())!
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let end = Calendar.current.date(bySettingHour: 6, minute: 0, second: 0, of: nextDay)!
        let shift = Shift(userId: userId, title: "Gece", startDate: start, endDate: end)
        XCTAssertEqual(shift.durationInHours, 8.0, accuracy: 0.01)
    }

    func testUpcomingShiftQuery() throws {
        let pastShift = makeShift(startHour: 0, endHour: 1, daysOffset: -1)
        let futureShift = makeShift(startHour: 14, endHour: 22, daysOffset: 1)
        try service.addShift(pastShift)
        try service.addShift(futureShift)

        let upcoming = service.upcomingShifts(userId: userId)
        XCTAssertEqual(upcoming.count, 1)
        XCTAssertEqual(upcoming.first?.id, futureShift.id)
    }

    // MARK: - Date Helper Tests
    func testDateHelperOverlap() {
        let helper = DateHelper.shared
        let shift1 = makeShift(startHour: 8, endHour: 16)
        let shift2 = makeShift(startHour: 12, endHour: 20)
        XCTAssertTrue(helper.overlaps(shift1, with: shift2))
    }

    func testDateHelperNoOverlap() {
        let helper = DateHelper.shared
        let shift1 = makeShift(startHour: 8, endHour: 16)
        let shift2 = makeShift(startHour: 16, endHour: 22)
        XCTAssertFalse(helper.overlaps(shift1, with: shift2))
    }

    // MARK: - Helper
    private func makeShift(
        startHour: Int,
        endHour: Int,
        daysOffset: Int = 0
    ) -> Shift {
        var base = Calendar.current.date(byAdding: .day, value: daysOffset, to: Date())!
        let start = Calendar.current.date(bySettingHour: startHour, minute: 0, second: 0, of: base)!
        let endBase = endHour >= 24
            ? Calendar.current.date(byAdding: .day, value: 1, to: base)!
            : base
        let end = Calendar.current.date(
            bySettingHour: endHour % 24,
            minute: 0,
            second: 0,
            of: endBase
        )!
        return Shift(userId: userId, title: "Test", startDate: start, endDate: end)
    }
}

// MARK: - ShiftError Equatable
extension ShiftError: Equatable {
    public static func == (lhs: ShiftError, rhs: ShiftError) -> Bool {
        switch (lhs, rhs) {
        case (.overlappingShift, .overlappingShift): return true
        case (.invalidDateRange, .invalidDateRange): return true
        case (.freeTierLimitReached, .freeTierLimitReached): return true
        default: return false
        }
    }
}
