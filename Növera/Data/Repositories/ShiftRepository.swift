// ShiftRepository.swift
// Növera — Shift Repository (offline-first)

import Foundation
import Combine

protocol ShiftRepositoryProtocol {
    func getShifts() -> [Shift]
    func getShifts(for date: Date) -> [Shift]
    func getShifts(forMonth date: Date) -> [Shift]
    func addShift(_ shift: Shift)
    func updateShift(_ shift: Shift)
    func deleteShift(id: UUID)
    func syncPending() async
}

final class ShiftRepository: ShiftRepositoryProtocol, ObservableObject {
    static let shared = ShiftRepository()

    private let local = LocalShiftDataSource.shared
    private let remote: RemoteShiftDataSource

    @Published var shifts: [Shift] = []

    init(remote: RemoteShiftDataSource = StubRemoteShiftDataSource()) {
        self.remote = remote
        self.shifts = local.loadShifts()
    }

    func getShifts() -> [Shift] {
        local.loadShifts()
    }

    func getShifts(for date: Date) -> [Shift] {
        local.shiftForDate(date)
    }

    func getShifts(forMonth date: Date) -> [Shift] {
        local.shiftsForMonth(date)
    }

    func addShift(_ shift: Shift) {
        local.insertShift(shift)
        refreshPublished()
    }

    func updateShift(_ shift: Shift) {
        var updated = shift
        updated.updatedAt = Date()
        updated.syncStatus = .pendingUpload
        local.updateShift(updated)
        refreshPublished()
    }

    func deleteShift(id: UUID) {
        local.softDeleteShift(id: id)
        refreshPublished()
    }

    func syncPending() async {
        let pending = local.pendingSync()
        for var shift in pending {
            do {
                if shift.syncStatus == .pendingDelete {
                    try await remote.deleteShift(id: shift.id)
                } else {
                    let synced = try await remote.updateShift(shift)
                    shift = synced
                }
                shift.markSynced()
                local.updateShift(shift)
            } catch {
                // Keep as pending, retry later
                print("Sync failed for shift \(shift.id): \(error)")
            }
        }
        refreshPublished()
    }

    private func refreshPublished() {
        DispatchQueue.main.async {
            self.shifts = self.local.loadShifts()
        }
    }
}

// MARK: - Mock Repository (for tests)
final class MockShiftRepository: ShiftRepositoryProtocol {
    var shifts: [Shift] = []

    func getShifts() -> [Shift] { shifts }
    func getShifts(for date: Date) -> [Shift] {
        shifts.filter { Calendar.current.isDate($0.startDate, inSameDayAs: date) }
    }
    func getShifts(forMonth date: Date) -> [Shift] {
        shifts.filter { Calendar.current.isDate($0.startDate, equalTo: date, toGranularity: .month) }
    }
    func addShift(_ shift: Shift) { shifts.append(shift) }
    func updateShift(_ shift: Shift) {
        if let idx = shifts.firstIndex(where: { $0.id == shift.id }) {
            shifts[idx] = shift
        }
    }
    func deleteShift(id: UUID) { shifts.removeAll { $0.id == id } }
    func syncPending() async {}
}
