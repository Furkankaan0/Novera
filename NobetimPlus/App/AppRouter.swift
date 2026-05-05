import Foundation

enum AppTab: String, CaseIterable, Identifiable {
    case today
    case calendar
    case team
    case analytics
    case profile

    var id: String { rawValue }

    var title: String {
        switch self {
        case .today: String(localized: "tab.today")
        case .calendar: String(localized: "tab.calendar")
        case .team: String(localized: "tab.team")
        case .analytics: String(localized: "tab.analytics")
        case .profile: String(localized: "tab.profile")
        }
    }

    var systemImage: String {
        switch self {
        case .today: "house.fill"
        case .calendar: "calendar"
        case .team: "person.3.fill"
        case .analytics: "chart.bar.xaxis"
        case .profile: "person.crop.circle"
        }
    }
}

enum AppSheet: Identifiable {
    case addShift
    case premium
    case settings

    var id: String {
        switch self {
        case .addShift: "addShift"
        case .premium: "premium"
        case .settings: "settings"
        }
    }
}
