import Foundation

@MainActor
protocol TeamRepositoryProtocol {
    func fetchTeams() throws -> [Team]
    func upsert(_ team: Team) throws
}
