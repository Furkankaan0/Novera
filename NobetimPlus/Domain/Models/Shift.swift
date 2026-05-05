import Foundation
import SwiftUI

enum ShiftType: String, Codable, CaseIterable, Identifiable, Hashable {
    case day
    case night
    case twentyFourHour
    case custom
    case overtime
    case officialHoliday
    case onCall
    case leave
    case report
    case training

    var id: String { rawValue }

    var localizedTitle: String {
        switch self {
        case .day: String(localized: "shift.type.day")
        case .night: String(localized: "shift.type.night")
        case .twentyFourHour: String(localized: "shift.type.twentyFourHour")
        case .custom: String(localized: "shift.type.custom")
        case .overtime: String(localized: "shift.type.overtime")
        case .officialHoliday: String(localized: "shift.type.officialHoliday")
        case .onCall: String(localized: "shift.type.onCall")
        case .leave: String(localized: "shift.type.leave")
        case .report: String(localized: "shift.type.report")
        case .training: String(localized: "shift.type.training")
        }
    }
}

enum WorkEntryKind: String, Codable, CaseIterable, Identifiable, Hashable {
    case normalShift
    case overtime
    case officialHoliday
    case nightWork
    case weekendWork
    case onCall
    case training
    case shortExtra
    case customDuration

    var id: String { rawValue }

    var localizedTitle: String {
        switch self {
        case .normalShift: String(localized: "work.kind.normalShift")
        case .overtime: String(localized: "work.kind.overtime")
        case .officialHoliday: String(localized: "work.kind.officialHoliday")
        case .nightWork: String(localized: "work.kind.nightWork")
        case .weekendWork: String(localized: "work.kind.weekendWork")
        case .onCall: String(localized: "work.kind.onCall")
        case .training: String(localized: "work.kind.training")
        case .shortExtra: String(localized: "work.kind.shortExtra")
        case .customDuration: String(localized: "work.kind.customDuration")
        }
    }

    var colorTag: ShiftColorTag {
        switch self {
        case .normalShift: .blue
        case .overtime: .purple
        case .officialHoliday: .amber
        case .nightWork: .navy
        case .weekendWork: .orange
        case .onCall: .orange
        case .training: .mint
        case .shortExtra: .purple
        case .customDuration: .teal
        }
    }
}

enum ShiftColorTag: String, Codable, CaseIterable, Identifiable, Hashable {
    case blue
    case mint
    case purple
    case amber
    case red
    case green
    case navy
    case orange
    case teal
    case gray

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .blue: DesignColors.primary
        case .mint: DesignColors.secondary
        case .purple: DesignColors.accent
        case .amber: DesignColors.warning
        case .red: DesignColors.danger
        case .green: DesignColors.success
        case .navy: DesignColors.navy
        case .orange: DesignColors.orange
        case .teal: DesignColors.teal
        case .gray: .secondary
        }
    }
}

enum SyncStatus: String, Codable, CaseIterable, Identifiable, Hashable {
    case local
    case pending
    case synced
    case failed

    var id: String { rawValue }
}

enum ShiftEntryMode: String, Codable, CaseIterable, Identifiable, Hashable {
    case timeRange
    case duration

    var id: String { rawValue }
}

enum PresetWorkDuration: Double, CaseIterable, Identifiable {
    case one = 1
    case two = 2
    case three = 3
    case four = 4
    case five = 5
    case six = 6
    case sevenAndHalf = 7.5
    case eight = 8
    case ten = 10
    case twelve = 12
    case sixteen = 16
    case twentyFour = 24

    var id: Double { rawValue }

    var localizedTitle: String {
        rawValue.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: String(localized: "duration.hours.integer"), Int(rawValue))
            : String(format: String(localized: "duration.hours.decimal"), rawValue)
    }
}

struct Shift: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var date: Date
    var startDate: Date
    var endDate: Date
    var department: String
    var unit: String
    var type: ShiftType
    var workKind: WorkEntryKind
    var notes: String
    var assignedUserId: UUID?
    var teamId: UUID?
    var isNightShift: Bool
    var isOfficialHoliday: Bool
    var isWeekend: Bool
    var colorTag: ShiftColorTag
    var reminderEnabled: Bool
    var breakMinutes: Int
    var createdAt: Date
    var updatedAt: Date
    var syncStatus: SyncStatus

    init(
        id: UUID = UUID(),
        title: String,
        date: Date,
        startDate: Date,
        endDate: Date,
        department: String,
        unit: String,
        type: ShiftType,
        workKind: WorkEntryKind = .normalShift,
        notes: String = "",
        assignedUserId: UUID? = nil,
        teamId: UUID? = nil,
        isNightShift: Bool = false,
        isOfficialHoliday: Bool = false,
        isWeekend: Bool = false,
        colorTag: ShiftColorTag = .blue,
        reminderEnabled: Bool = true,
        breakMinutes: Int = 0,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        syncStatus: SyncStatus = .local
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.startDate = startDate
        self.endDate = endDate
        self.department = department
        self.unit = unit
        self.type = type
        self.workKind = workKind
        self.notes = notes
        self.assignedUserId = assignedUserId
        self.teamId = teamId
        self.isNightShift = isNightShift
        self.isOfficialHoliday = isOfficialHoliday
        self.isWeekend = isWeekend
        self.colorTag = colorTag
        self.reminderEnabled = reminderEnabled
        self.breakMinutes = breakMinutes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.syncStatus = syncStatus
    }
}
