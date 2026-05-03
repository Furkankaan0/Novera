// LocalShiftDataSource.swift
// Növera — Local Shift Persistence (UserDefaults-based for MVP)
// TODO: Migrate to SwiftData in next version

import Foundation

final class LocalShiftDataSource {
    static let shared = LocalShiftDataSource()
    private init() {}

    private let key = "novera.shifts"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func loadShifts() -> [Shift] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let shifts = try? decoder.decode([Shift].self, from: data) else {
            return []
        }
        return shifts.filter { $0.deletedAt == nil }
    }

    func saveShifts(_ shifts: [Shift]) {
        guard let data = try? encoder.encode(shifts) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    func insertShift(_ shift: Shift) {
        var current = loadAllShifts()
        current.append(shift)
        saveShifts(current)
    }

    func updateShift(_ shift: Shift) {
        var current = loadAllShifts()
        if let index = current.firstIndex(where: { $0.id == shift.id }) {
            current[index] = shift
        } else {
            current.append(shift)
        }
        saveShifts(current)
    }

    func softDeleteShift(id: UUID) {
        var current = loadAllShifts()
        if let index = current.firstIndex(where: { $0.id == id }) {
            current[index].markDeleted()
        }
        saveShifts(current)
    }

    func shiftForDate(_ date: Date) -> [Shift] {
        loadShifts().filter {
            Calendar.current.isDate($0.startDate, inSameDayAs: date)
        }
    }

    func shiftsForMonth(_ date: Date) -> [Shift] {
        loadShifts().filter {
            Calendar.current.isDate($0.startDate, equalTo: date, toGranularity: .month)
        }
    }

    func pendingSync() -> [Shift] {
        loadAllShifts().filter { $0.syncStatus != .synced && $0.deletedAt == nil }
    }

    // Includes soft-deleted (for sync)
    private func loadAllShifts() -> [Shift] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let shifts = try? decoder.decode([Shift].self, from: data) else {
            return []
        }
        return shifts
    }
}
