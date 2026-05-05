import Foundation

enum TeamPermissionRole: String, Codable, CaseIterable, Identifiable, Hashable {
    case owner
    case manager
    case member
    case viewer

    var id: String { rawValue }
}

struct TeamMember: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var role: TeamPermissionRole
    var department: String
    var avatarColor: ShiftColorTag
    var phoneOptional: String?
    var emailOptional: String?
    var workloadScore: Double
    var isOnDutyToday: Bool
    var isOnLeave: Bool
}
