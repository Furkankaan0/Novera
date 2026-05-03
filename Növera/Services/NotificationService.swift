// NotificationService.swift
// Növera — APNs & Local Notification Manager

import Foundation
import UserNotifications

final class NotificationService: NSObject, ObservableObject {
    static let shared = NotificationService()
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    @Published var isAuthorized: Bool = false
    @Published var pendingNotifications: [UNNotificationRequest] = []

    // MARK: - Permission
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                self.isAuthorized = granted
            }
        }
    }

    func checkStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }

    // MARK: - Shift Reminder
    func scheduleShiftReminder(for shift: Shift) {
        guard isAuthorized else { return }

        // Schedule 1 hour before
        let reminderDate = shift.startDate.addingTimeInterval(
            -TimeInterval(NoveraConstants.reminderMinutesBefore * 60)
        )
        guard reminderDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Nöbet Hatırlatması 🏥"
        content.body = "\(shift.title) — \(shift.location) • \(shift.startDate.timeFormatted)"
        content.sound = .default
        content.badge = 1
        content.userInfo = ["shiftId": shift.id.uuidString]

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: reminderDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: "\(NoveraConstants.NotificationIDs.shiftReminder).\(shift.id.uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Cancel Reminder
    func cancelReminder(for shiftId: UUID) {
        let identifier = "\(NoveraConstants.NotificationIDs.shiftReminder).\(shiftId.uuidString)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    // MARK: - Team Announcement
    func scheduleAnnouncementNotification(_ announcement: Announcement) {
        guard isAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = "Ekip Duyurusu 📢"
        content.body = announcement.title
        content.sound = .default
        content.userInfo = ["announcementId": announcement.id.uuidString]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "\(NoveraConstants.NotificationIDs.teamAnnouncement).\(announcement.id.uuidString)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Swap Request
    func scheduleSwapRequestNotification(_ request: ShiftSwapRequest) {
        guard isAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = "Nöbet Takas İsteği 🔄"
        content.body = "\(request.requestedByName) takas isteği gönderdi."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let req = UNNotificationRequest(
            identifier: "\(NoveraConstants.NotificationIDs.swapRequest).\(request.id.uuidString)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(req)
    }

    // MARK: - Clear Badge
    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0) { _ in }
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // TODO: Deep link to relevant screen
        completionHandler()
    }
}
