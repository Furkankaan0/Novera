import Foundation
import UserNotifications

final class NotificationService {
    func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    func scheduleShiftReminder(for shift: Shift) {
        guard shift.reminderEnabled else { return }
        schedule(identifier: "\(shift.id)-day-before", date: shift.startDate.addingTimeInterval(-24 * 3600), title: "Yarın nöbetin var", body: "Yarın \(shift.startDate.formatted(date: .omitted, time: .shortened))’de nöbetin var.")
        schedule(identifier: "\(shift.id)-two-hours", date: shift.startDate.addingTimeInterval(-2 * 3600), title: "Nöbetine 2 saat kaldı", body: "\(shift.unit) vardiyan yaklaşıyor.")
        schedule(identifier: "\(shift.id)-start", date: shift.startDate, title: "Bugünkü vardiyanı unutma", body: "\(shift.title) şimdi başlıyor.")
    }

    func cancelReminder(for shift: Shift) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [
            "\(shift.id)-day-before",
            "\(shift.id)-two-hours",
            "\(shift.id)-start"
        ])
    }

    func rescheduleAll(shifts: [Shift]) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        shifts.forEach(scheduleShiftReminder)
    }

    private func schedule(identifier: String, date: Date, title: String, body: String) {
        guard date > .now else { return }
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: identifier, content: content, trigger: trigger))
    }
}
