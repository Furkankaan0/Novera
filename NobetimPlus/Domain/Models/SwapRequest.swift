import Foundation

enum SwapRequestStatus: String, Codable, CaseIterable, Identifiable, Hashable {
    case pending
    case approved
    case rejected
    case cancelled

    var id: String { rawValue }
}

struct SwapRequest: Identifiable, Codable, Hashable {
    var id: UUID
    var fromUserId: UUID
    var toUserId: UUID
    var shiftId: UUID
    var reason: String
    var status: SwapRequestStatus
    var createdAt: Date
}
