import Foundation

@MainActor
final class LocalTeamRepository: TeamRepositoryProtocol {
    private var teams: [Team]

    init(teams: [Team] = MockData.teams) {
        self.teams = teams
    }

    func fetchTeams() throws -> [Team] {
        teams
    }

    func upsert(_ team: Team) throws {
        if let index = teams.firstIndex(where: { $0.id == team.id }) {
            teams[index] = team
        } else {
            teams.append(team)
        }
    }
}
