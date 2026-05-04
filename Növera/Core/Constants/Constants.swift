// Constants.swift
// Növera — App Constants

import Foundation

enum NoveraConstants {
    // MARK: - App
    static let appName = "Növera"
    static let bundleID = "com.novera.app"
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    static let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

    // MARK: - Free Tier Limits
    static let freeShiftLimit = 10
    static let freeTeamMemberLimit = 3

    // MARK: - StoreKit Product IDs
    enum Products {
        static let monthlyPro = "com.novera.app.pro.monthly"
        static let annualPro = "com.novera.app.pro.annual"
        static let lifetimePro = "com.novera.app.pro.lifetime"
    }

    // MARK: - UserDefaults Keys
    enum Keys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let isPremiumUser = "isPremiumUser"
        static let currentUserID = "currentUserID"
        static let colorScheme = "colorSchemePreference"
        static let notificationsEnabled = "notificationsEnabled"
        static let hourlyRate = "userHourlyRate"
        static let overtimeMultiplier = "overtimeMultiplier"
        static let holidayMultiplier = "holidayMultiplier"
    }

    // MARK: - Notification IDs
    enum NotificationIDs {
        static let shiftReminder = "novera.shift.reminder"
        static let teamAnnouncement = "novera.team.announcement"
        static let swapRequest = "novera.swap.request"
        static let overtimeAlert = "novera.overtime.alert"
    }

    // MARK: - Earning Defaults (Turkey)
    static let defaultHourlyRate: Double = 150.0       // ₺150/saat
    static let defaultOvertimeMultiplier: Double = 1.5  // x1.5 fazla mesai
    static let defaultHolidayMultiplier: Double = 2.0   // x2.0 resmi tatil
    static let defaultNightBonusRate: Double = 0.25     // +%25 gece zammı
    static let defaultTargetMonthlyEarnings: Double = 15000.0 // ₺15.000 aylık hedef
    static let standardWeeklyHours: Double = 45.0       // Türkiye: 45 saat/hafta
    static let standardDailyHours: Double = 9.0         // 45/5

    // MARK: - Shift Types
    static let shiftTypeColors: [String: String] = [
        "day": "#3AADE4",
        "night": "#7C6AE8",
        "oncall": "#F09F3B",
        "holiday": "#42C47A",
        "overtime": "#E85A7C"
    ]

    // MARK: - Animation Durations
    static let onboardingTransitionDuration: Double = 0.5
    static let cardAnimationDelay: Double = 0.1

    // MARK: - Calendar
    static let maxVisibleMonthsAhead: Int = 12
    static let reminderMinutesBefore: Int = 60
}
