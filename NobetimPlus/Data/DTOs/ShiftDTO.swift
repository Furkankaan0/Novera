import Foundation

struct ShiftDTO: Codable, Hashable {
    var id: UUID
    var title: String
    var startDate: Date
    var endDate: Date
    var department: String
    var unit: String
    var type: String
}
