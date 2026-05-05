import Foundation

struct WorkSummary: Identifiable, Codable, Hashable {
    var id: String { monthIdentifier }
    var month: Date
    var monthIdentifier: String
    var totalWorkHours: Double
    var normalShiftHours: Double
    var overtimeHours: Double
    var officialHolidayHours: Double
    var nightShiftHours: Double
    var weekendHours: Double
    var onCallHours: Double
    var trainingHours: Double
    var customDurationHours: Double
    var estimatedOvertimeIncome: Double
    var estimatedHolidayIncome: Double
    var estimatedTotalExtraIncome: Double

    static let empty = WorkSummary(
        month: .now,
        monthIdentifier: "",
        totalWorkHours: 0,
        normalShiftHours: 0,
        overtimeHours: 0,
        officialHolidayHours: 0,
        nightShiftHours: 0,
        weekendHours: 0,
        onCallHours: 0,
        trainingHours: 0,
        customDurationHours: 0,
        estimatedOvertimeIncome: 0,
        estimatedHolidayIncome: 0,
        estimatedTotalExtraIncome: 0
    )
}

struct WeeklyWorkPoint: Identifiable, Hashable {
    var id = UUID()
    var label: String
    var hours: Double
}

struct ShiftTypeDistribution: Identifiable, Hashable {
    var id = UUID()
    var label: String
    var hours: Double
    var colorTag: ShiftColorTag
}
