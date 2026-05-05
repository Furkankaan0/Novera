import EventKit
import Foundation

final class CalendarExportService {
    private let eventStore = EKEventStore()

    func requestAccess() async throws -> Bool {
        if #available(iOS 17.0, *) {
            return try await eventStore.requestWriteOnlyAccessToEvents()
        } else {
            return try await eventStore.requestAccess(to: .event)
        }
    }

    func exportToAppleCalendar(_ shift: Shift) throws {
        let event = EKEvent(eventStore: eventStore)
        event.title = "Nöbetim+ • \(shift.title)"
        event.startDate = shift.startDate
        event.endDate = shift.endDate
        event.notes = shift.notes
        event.calendar = eventStore.defaultCalendarForNewEvents
        try eventStore.save(event, span: .thisEvent)
    }

    func makeICS(shifts: [Shift]) -> String {
        var lines = ["BEGIN:VCALENDAR", "VERSION:2.0", "PRODID:-//NobetimPlus//TR"]
        for shift in shifts {
            lines.append("BEGIN:VEVENT")
            lines.append("UID:\(shift.id.uuidString)")
            lines.append("SUMMARY:\(shift.title)")
            lines.append("DTSTART:\(icsDate(shift.startDate))")
            lines.append("DTEND:\(icsDate(shift.endDate))")
            lines.append("DESCRIPTION:\(shift.unit)")
            lines.append("END:VEVENT")
        }
        lines.append("END:VCALENDAR")
        return lines.joined(separator: "\r\n")
    }

    private func icsDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        return formatter.string(from: date)
    }
}
