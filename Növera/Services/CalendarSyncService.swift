// CalendarSyncService.swift
// Növera — EventKit Calendar Integration

import Foundation
import EventKit

final class CalendarSyncService {
    static let shared = CalendarSyncService()
    private init() {}

    private let store = EKEventStore()
    private let calendarTitle = "Növera Nöbetleri"

    // MARK: - Permission
    func requestAccess() async -> Bool {
        if #available(iOS 17.0, *) {
            let granted = try? await store.requestWriteOnlyAccessToEvents()
            return granted ?? false
        } else {
            return await withCheckedContinuation { continuation in
                store.requestAccess(to: .event) { granted, _ in
                    continuation.resume(returning: granted)
                }
            }
        }
    }

    // MARK: - Get or create Növera calendar
    private func noveraCalendar() -> EKCalendar? {
        // Find existing
        if let existing = store.calendars(for: .event).first(where: { $0.title == calendarTitle }) {
            return existing
        }
        // Create new
        let calendar = EKCalendar(for: .event, eventStore: store)
        calendar.title = calendarTitle
        calendar.source = store.defaultCalendarForNewEvents?.source
        try? store.saveCalendar(calendar, commit: true)
        return calendar
    }

    // MARK: - Add shift to calendar
    func addShift(_ shift: Shift) {
        guard let calendar = noveraCalendar() else { return }

        let event = EKEvent(eventStore: store)
        event.title = "🏥 \(shift.title)"
        event.startDate = shift.startDate
        event.endDate = shift.endDate
        event.calendar = calendar
        event.notes = shift.notes.isEmpty ? nil : shift.notes
        event.location = shift.location.isEmpty ? nil : shift.location

        // Add alarm
        let alarm = EKAlarm(relativeOffset: -TimeInterval(NoveraConstants.reminderMinutesBefore * 60))
        event.addAlarm(alarm)

        // Store event identifier in UserDefaults for later removal
        try? store.save(event, span: .thisEvent)
        if let id = event.eventIdentifier {
            saveEventID(id, for: shift.id)
        }
    }

    // MARK: - Remove shift from calendar
    func removeShift(_ shiftId: UUID) {
        guard let eventID = loadEventID(for: shiftId),
              let event = store.event(withIdentifier: eventID) else { return }
        try? store.remove(event, span: .thisEvent)
        removeEventID(for: shiftId)
    }

    // MARK: - EventID Persistence
    private func saveEventID(_ eventID: String, for shiftId: UUID) {
        var map = loadEventIDMap()
        map[shiftId.uuidString] = eventID
        if let data = try? JSONEncoder().encode(map) {
            UserDefaults.standard.set(data, forKey: "novera.calendarEventMap")
        }
    }

    private func loadEventID(for shiftId: UUID) -> String? {
        loadEventIDMap()[shiftId.uuidString]
    }

    private func removeEventID(for shiftId: UUID) {
        var map = loadEventIDMap()
        map.removeValue(forKey: shiftId.uuidString)
        if let data = try? JSONEncoder().encode(map) {
            UserDefaults.standard.set(data, forKey: "novera.calendarEventMap")
        }
    }

    private func loadEventIDMap() -> [String: String] {
        guard let data = UserDefaults.standard.data(forKey: "novera.calendarEventMap"),
              let map = try? JSONDecoder().decode([String: String].self, from: data) else {
            return [:]
        }
        return map
    }
}
