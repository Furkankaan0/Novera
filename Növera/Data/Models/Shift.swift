// Shift.swift
// Növera — Shift/Vardiya Data Model

import Foundation
import SwiftUI

// MARK: - Shift Type
enum ShiftType: String, Codable, CaseIterable {
    case day = "day"
    case night = "night"
    case oncall = "oncall"
    case holiday = "holiday"
    case overtime = "overtime"

    var displayName: String {
        switch self {
        case .day: return "Gündüz"
        case .night: return "Gece"
        case .oncall: return "İcap"
        case .holiday: return "Tatil Nöbeti"
        case .overtime: return "Fazla Mesai"
        }
    }

    var icon: String {
        switch self {
        case .day: return "sun.max.fill"
        case .night: return "moon.stars.fill"
        case .oncall: return "phone.fill"
        case .holiday: return "flag.fill"
        case .overtime: return "clock.badge.plus"
        }
    }

    var color: Color {
        switch self {
        case .day: return NoveraColors.shiftDay
        case .night: return NoveraColors.shiftNight
        case .oncall: return NoveraColors.shiftOncall
        case .holiday: return NoveraColors.shiftHoliday
        case .overtime: return NoveraColors.shiftOvertime
        }
    }
}

// MARK: - Sync Status
enum SyncStatus: String, Codable {
    case synced = "synced"
    case pendingUpload = "pendingUpload"
    case pendingDelete = "pendingDelete"
    case conflict = "conflict"
}

// MARK: - Shift Model
struct Shift: Identifiable, Codable, Equatable {
    var id: UUID
    var userId: UUID
    var teamId: UUID?
    var title: String
    var startDate: Date
    var endDate: Date
    var shiftType: ShiftType
    var location: String
    var notes: String
    var isHoliday: Bool
    var isOvertime: Bool
    var hourlyRate: Double?
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
    var syncStatus: SyncStatus

    init(
        id: UUID = UUID(),
        userId: UUID,
        teamId: UUID? = nil,
        title: String,
        startDate: Date,
        endDate: Date,
        shiftType: ShiftType = .day,
        location: String = "",
        notes: String = "",
        isHoliday: Bool = false,
        isOvertime: Bool = false,
        hourlyRate: Double? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        deletedAt: Date? = nil,
        syncStatus: SyncStatus = .pendingUpload
    ) {
        self.id = id
        self.userId = userId
        self.teamId = teamId
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.shiftType = shiftType
        self.location = location
        self.notes = notes
        self.isHoliday = isHoliday
        self.isOvertime = isOvertime
        self.hourlyRate = hourlyRate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.syncStatus = syncStatus
    }

    // MARK: - Computed Properties
    var durationInHours: Double {
        DateHelper.shared.hours(from: startDate, to: endDate)
    }

    var timeRangeFormatted: String {
        "\(startDate.timeFormatted) - \(endDate.timeFormatted)"
    }

    var isActive: Bool {
        let now = Date()
        return startDate <= now && endDate >= now
    }

    var isUpcoming: Bool {
        startDate > Date()
    }

    // MARK: - Mutations
    mutating func markDeleted() {
        deletedAt = Date()
        syncStatus = .pendingDelete
        updatedAt = Date()
    }

    mutating func markSynced() {
        syncStatus = .synced
    }

    // MARK: - Preview Stubs
    static let previewDay = Shift(
        userId: UUID(),
        title: "Acil Servis Nöbeti",
        startDate: Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date(),
        endDate: Calendar.current.date(bySettingHour: 16, minute: 0, second: 0, of: Date()) ?? Date(),
        shiftType: .day,
        location: "Acil Servis - Blok A"
    )

    static let previewNight = Shift(
        userId: UUID(),
        title: "Gece Nöbeti",
        startDate: Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: Date()) ?? Date(),
        endDate: Calendar.current.date(bySettingHour: 6, minute: 0, second: 0, of: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()) ?? Date(),
        shiftType: .night,
        location: "Yoğun Bakım"
    )

    static let previewArray: [Shift] = [previewDay, previewNight]
}
