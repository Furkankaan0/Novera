// ShiftService.swift
// Növera — Shift Business Logic

import Foundation
import Combine

final class ShiftService: ObservableObject {
    static let shared = ShiftService()

    private let repository: ShiftRepositoryProtocol

    init(repository: ShiftRepositoryProtocol = ShiftRepository.shared) {
        self.repository = repository
    }

    // MARK: - CRUD
    func addShift(_ shift: Shift) throws {
        // Overlap validation
        let existing = repository.getShifts(for: shift.startDate)
        let hasOverlap = existing.contains { DateHelper.shared.overlaps(shift, with: $0) && $0.id != shift.id }
        if hasOverlap {
            throw ShiftError.overlappingShift
        }
        repository.addShift(shift)
        NotificationService.shared.scheduleShiftReminder(for: shift)
    }

    func updateShift(_ shift: Shift) throws {
        repository.updateShift(shift)
        NotificationService.shared.scheduleShiftReminder(for: shift)
    }

    func deleteShift(id: UUID) {
        repository.deleteShift(id: id)
        NotificationService.shared.cancelReminder(for: id)
    }

    // MARK: - Queries
    func shiftsForToday(userId: UUID) -> [Shift] {
        repository.getShifts(for: Date()).filter { $0.userId == userId }
    }

    func upcomingShifts(userId: UUID, limit: Int = 5) -> [Shift] {
        repository.getShifts()
            .filter { $0.userId == userId && $0.isUpcoming }
            .sorted { $0.startDate < $1.startDate }
            .prefix(limit)
            .map { $0 }
    }

    func nextShift(userId: UUID) -> Shift? {
        upcomingShifts(userId: userId, limit: 1).first
    }

    func shiftsThisWeek(userId: UUID) -> [Shift] {
        let start = Date().startOfWeek
        let end = Calendar.current.date(byAdding: .day, value: 7, to: start) ?? start
        return repository.getShifts()
            .filter { $0.userId == userId && $0.startDate >= start && $0.startDate < end }
    }

    func totalHoursThisWeek(userId: UUID) -> Double {
        shiftsThisWeek(userId: userId)
            .reduce(0) { $0 + $1.durationInHours }
    }

    func shiftsThisMonth(userId: UUID) -> [Shift] {
        repository.getShifts(forMonth: Date())
            .filter { $0.userId == userId }
    }

    func totalShiftsThisMonth(userId: UUID) -> Int {
        shiftsThisMonth(userId: userId).count
    }
}

// MARK: - Shift Errors
enum ShiftError: Error, LocalizedError {
    case overlappingShift
    case invalidDateRange
    case freeTierLimitReached

    var errorDescription: String? {
        switch self {
        case .overlappingShift: return "Bu tarih aralığında başka bir vardiya mevcut."
        case .invalidDateRange: return "Bitiş zamanı başlangıçtan önce olamaz."
        case .freeTierLimitReached: return "Ücretsiz planda en fazla \(NoveraConstants.freeShiftLimit) vardiya ekleyebilirsiniz."
        }
    }
}
