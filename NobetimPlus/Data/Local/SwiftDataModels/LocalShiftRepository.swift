import Foundation
import SwiftData

@MainActor
final class LocalShiftRepository: ShiftRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchShifts() throws -> [Shift] {
        let descriptor = FetchDescriptor<LocalShiftEntity>(sortBy: [SortDescriptor(\.startDate)])
        return try modelContext.fetch(descriptor).map(\.domainModel)
    }

    func upsert(_ shift: Shift) throws {
        let id = shift.id
        var descriptor = FetchDescriptor<LocalShiftEntity>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1

        if let existing = try modelContext.fetch(descriptor).first {
            existing.update(from: shift)
        } else {
            modelContext.insert(LocalShiftEntity(shift: shift))
        }

        try modelContext.save()
    }

    func delete(_ shift: Shift) throws {
        let id = shift.id
        let descriptor = FetchDescriptor<LocalShiftEntity>(predicate: #Predicate { $0.id == id })
        for entity in try modelContext.fetch(descriptor) {
            modelContext.delete(entity)
        }
        try modelContext.save()
    }
}
