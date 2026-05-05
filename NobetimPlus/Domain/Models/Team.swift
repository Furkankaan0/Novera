import Foundation

struct Team: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var department: String
    var inviteCode: String
    var members: [TeamMember]
    var createdBy: UUID
    var createdAt: Date
}
