import Foundation

@MainActor
protocol ShiftRepositoryProtocol {
    func fetchShifts() throws -> [Shift]
    func upsert(_ shift: Shift) throws
    func delete(_ shift: Shift) throws
}
