import Foundation
import SwiftData

@Model
final class LocalShiftEntity {
    @Attribute(.unique) var id: UUID
    var title: String
    var date: Date
    var startDate: Date
    var endDate: Date
    var department: String
    var unit: String
    var typeRawValue: String
    var workKindRawValue: String
    var notes: String
    var assignedUserId: UUID?
    var teamId: UUID?
    var isNightShift: Bool
    var isOfficialHoliday: Bool
    var isWeekend: Bool
    var colorTagRawValue: String
    var reminderEnabled: Bool
    var breakMinutes: Int
    var createdAt: Date
    var updatedAt: Date
    var syncStatusRawValue: String

    init(shift: Shift) {
        self.id = shift.id
        self.title = shift.title
        self.date = shift.date
        self.startDate = shift.startDate
        self.endDate = shift.endDate
        self.department = shift.department
        self.unit = shift.unit
        self.typeRawValue = shift.type.rawValue
        self.workKindRawValue = shift.workKind.rawValue
        self.notes = shift.notes
        self.assignedUserId = shift.assignedUserId
        self.teamId = shift.teamId
        self.isNightShift = shift.isNightShift
        self.isOfficialHoliday = shift.isOfficialHoliday
        self.isWeekend = shift.isWeekend
        self.colorTagRawValue = shift.colorTag.rawValue
        self.reminderEnabled = shift.reminderEnabled
        self.breakMinutes = shift.breakMinutes
        self.createdAt = shift.createdAt
        self.updatedAt = shift.updatedAt
        self.syncStatusRawValue = shift.syncStatus.rawValue
    }

    func update(from shift: Shift) {
        title = shift.title
        date = shift.date
        startDate = shift.startDate
        endDate = shift.endDate
        department = shift.department
        unit = shift.unit
        typeRawValue = shift.type.rawValue
        workKindRawValue = shift.workKind.rawValue
        notes = shift.notes
        assignedUserId = shift.assignedUserId
        teamId = shift.teamId
        isNightShift = shift.isNightShift
        isOfficialHoliday = shift.isOfficialHoliday
        isWeekend = shift.isWeekend
        colorTagRawValue = shift.colorTag.rawValue
        reminderEnabled = shift.reminderEnabled
        breakMinutes = shift.breakMinutes
        updatedAt = .now
        syncStatusRawValue = shift.syncStatus.rawValue
    }

    var domainModel: Shift {
        Shift(
            id: id,
            title: title,
            date: date,
            startDate: startDate,
            endDate: endDate,
            department: department,
            unit: unit,
            type: ShiftType(rawValue: typeRawValue) ?? .custom,
            workKind: WorkEntryKind(rawValue: workKindRawValue) ?? .customDuration,
            notes: notes,
            assignedUserId: assignedUserId,
            teamId: teamId,
            isNightShift: isNightShift,
            isOfficialHoliday: isOfficialHoliday,
            isWeekend: isWeekend,
            colorTag: ShiftColorTag(rawValue: colorTagRawValue) ?? .blue,
            reminderEnabled: reminderEnabled,
            breakMinutes: breakMinutes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: SyncStatus(rawValue: syncStatusRawValue) ?? .local
        )
    }
}
