import Foundation

enum UserRole: String, Codable, CaseIterable, Identifiable, Hashable {
    case nurse
    case doctor
    case clinicalSupport
    case security
    case technician
    case cleaning
    case shiftWorker
    case teamLead
    case manager

    var id: String { rawValue }

    var localizedTitle: String {
        switch self {
        case .nurse: String(localized: "role.nurse")
        case .doctor: String(localized: "role.doctor")
        case .clinicalSupport: String(localized: "role.clinicalSupport")
        case .security: String(localized: "role.security")
        case .technician: String(localized: "role.technician")
        case .cleaning: String(localized: "role.cleaning")
        case .shiftWorker: String(localized: "role.shiftWorker")
        case .teamLead: String(localized: "role.teamLead")
        case .manager: String(localized: "role.manager")
        }
    }
}

enum PreferredTheme: String, Codable, CaseIterable, Identifiable, Hashable {
    case system
    case light
    case dark

    var id: String { rawValue }
}

enum PremiumStatus: String, Codable, CaseIterable, Identifiable, Hashable {
    case free
    case monthly
    case yearly
    case lifetime

    var id: String { rawValue }

    var isPremium: Bool { self != .free }
}

struct UserProfile: Identifiable, Codable, Hashable {
    var id: UUID
    var appleUserIdentifier: String?
    var fullName: String
    var email: String?
    var role: UserRole
    var department: String
    var monthlyNormalHours: Double
    var overtimeHourlyRate: Double
    var holidayHourlyRate: Double
    var nightWorkMultiplier: Double
    var additionalPayment: Double
    var currencyCode: String
    var preferredTheme: PreferredTheme
    var premiumStatus: PremiumStatus
    var hapticsEnabled: Bool
    var appLockEnabled: Bool

    static let demo = UserProfile(
        id: UUID(),
        appleUserIdentifier: nil,
        fullName: "Ayşe Demir",
        email: "ayse@example.com",
        role: .nurse,
        department: "Acil Servis",
        monthlyNormalHours: 160,
        overtimeHourlyRate: 115,
        holidayHourlyRate: 180,
        nightWorkMultiplier: 1.15,
        additionalPayment: 0,
        currencyCode: "TRY",
        preferredTheme: .system,
        premiumStatus: .free,
        hapticsEnabled: true,
        appLockEnabled: false
    )
}
