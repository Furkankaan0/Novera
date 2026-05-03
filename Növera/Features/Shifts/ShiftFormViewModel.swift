// ShiftFormViewModel.swift
// Növera — Add/Edit Shift ViewModel

import SwiftUI
import Combine

final class ShiftFormViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var location: String = ""
    @Published var notes: String = ""
    @Published var startDate: Date = Date()
    @Published var endDate: Date = Calendar.current.date(byAdding: .hour, value: 8, to: Date()) ?? Date()
    @Published var shiftType: ShiftType = .day
    @Published var isHoliday: Bool = false
    @Published var isOvertime: Bool = false
    @Published var hourlyRate: String = ""
    @Published var isSaving: Bool = false
    @Published var errorMessage: String? = nil
    @Published var didSave: Bool = false
    @Published var addToCalendar: Bool = false

    private let shiftService = ShiftService.shared
    private let calendarSync = CalendarSyncService.shared
    private let userRepo = UserRepository.shared

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty && endDate > startDate
    }

    var durationPreview: String {
        guard endDate > startDate else { return "—" }
        let hours = DateHelper.shared.hours(from: startDate, to: endDate)
        return hours.hoursFormatted
    }

    // MARK: - Prefill for edit
    func loadShift(_ shift: Shift) {
        title = shift.title
        location = shift.location
        notes = shift.notes
        startDate = shift.startDate
        endDate = shift.endDate
        shiftType = shift.shiftType
        isHoliday = shift.isHoliday
        isOvertime = shift.isOvertime
        hourlyRate = shift.hourlyRate.map { String($0) } ?? ""
    }

    // MARK: - Auto title suggestion
    func suggestTitle() {
        if title.isEmpty {
            title = shiftType.displayName + " Vardiyası"
        }
    }

    // MARK: - Save
    func save(preselectedDate: Date? = nil, editing: Shift? = nil) {
        guard isValid else {
            errorMessage = "Lütfen vardiya adını ve geçerli bir zaman aralığını girin."
            return
        }

        isSaving = true
        errorMessage = nil

        guard let user = userRepo.getCurrentUser() else {
            errorMessage = "Kullanıcı bilgisi bulunamadı."
            isSaving = false
            return
        }

        let rate = Double(hourlyRate) ?? user.hourlyRate

        let shift = Shift(
            id: editing?.id ?? UUID(),
            userId: user.id,
            title: title,
            startDate: startDate,
            endDate: endDate,
            shiftType: shiftType,
            location: location,
            notes: notes,
            isHoliday: isHoliday,
            isOvertime: isOvertime,
            hourlyRate: rate
        )

        do {
            if editing != nil {
                try shiftService.updateShift(shift)
            } else {
                try shiftService.addShift(shift)
            }

            if addToCalendar {
                calendarSync.addShift(shift)
            }

            HapticManager.notification(.success)
            didSave = true
        } catch ShiftError.overlappingShift {
            errorMessage = "Bu tarih aralığında başka bir vardiya mevcut."
            HapticManager.notification(.error)
        } catch {
            errorMessage = error.localizedDescription
            HapticManager.notification(.error)
        }

        isSaving = false
    }
}
