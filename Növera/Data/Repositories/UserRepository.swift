// UserRepository.swift
// Növera — User Repository

import Foundation

protocol UserRepositoryProtocol {
    func getCurrentUser() -> User?
    func saveUser(_ user: User)
    func updateUser(_ user: User)
    func clearUser()
}

final class UserRepository: UserRepositoryProtocol {
    static let shared = UserRepository()
    private init() {}

    private let key = "novera.currentUser"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func getCurrentUser() -> User? {
        guard let data = UserDefaults.standard.data(forKey: key),
              let user = try? decoder.decode(User.self, from: data) else {
            return nil
        }
        return user
    }

    func saveUser(_ user: User) {
        guard let data = try? encoder.encode(user) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    func updateUser(_ user: User) {
        var updated = user
        updated.updatedAt = Date()
        saveUser(updated)
    }

    func clearUser() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

// MARK: - Team Repository
protocol TeamRepositoryProtocol {
    func getTeams() -> [Team]
    func getTeam(by id: UUID) -> Team?
    func saveTeam(_ team: Team)
    func updateTeam(_ team: Team)
    func deleteTeam(id: UUID)
    func getAnnouncements(for teamId: UUID) -> [Announcement]
    func saveAnnouncement(_ announcement: Announcement)
    func getSwapRequests(for userId: UUID) -> [ShiftSwapRequest]
    func saveSwapRequest(_ request: ShiftSwapRequest)
    func updateSwapRequest(_ request: ShiftSwapRequest)
}

final class TeamRepository: TeamRepositoryProtocol {
    static let shared = TeamRepository()
    private init() {}

    private let teamsKey = "novera.teams"
    private let announcementsKey = "novera.announcements"
    private let swapKey = "novera.swapRequests"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func getTeams() -> [Team] {
        guard let data = UserDefaults.standard.data(forKey: teamsKey),
              let teams = try? decoder.decode([Team].self, from: data) else {
            return []
        }
        return teams
    }

    func getTeam(by id: UUID) -> Team? {
        getTeams().first { $0.id == id }
    }

    func saveTeam(_ team: Team) {
        var current = getTeams()
        current.append(team)
        persist(current, key: teamsKey)
    }

    func updateTeam(_ team: Team) {
        var current = getTeams()
        if let idx = current.firstIndex(where: { $0.id == team.id }) {
            current[idx] = team
        }
        persist(current, key: teamsKey)
    }

    func deleteTeam(id: UUID) {
        let updated = getTeams().filter { $0.id != id }
        persist(updated, key: teamsKey)
    }

    func getAnnouncements(for teamId: UUID) -> [Announcement] {
        guard let data = UserDefaults.standard.data(forKey: announcementsKey),
              let all = try? decoder.decode([Announcement].self, from: data) else {
            return []
        }
        return all.filter { $0.teamId == teamId }.sorted { $0.createdAt > $1.createdAt }
    }

    func saveAnnouncement(_ announcement: Announcement) {
        var current: [Announcement] = {
            guard let data = UserDefaults.standard.data(forKey: announcementsKey),
                  let all = try? decoder.decode([Announcement].self, from: data) else { return [] }
            return all
        }()
        current.append(announcement)
        persist(current, key: announcementsKey)
    }

    func getSwapRequests(for userId: UUID) -> [ShiftSwapRequest] {
        guard let data = UserDefaults.standard.data(forKey: swapKey),
              let all = try? decoder.decode([ShiftSwapRequest].self, from: data) else {
            return []
        }
        return all.filter { $0.requestedBy == userId || $0.requestedTo == userId }
    }

    func saveSwapRequest(_ request: ShiftSwapRequest) {
        var current = loadAllSwapRequests()
        current.append(request)
        persist(current, key: swapKey)
    }

    func updateSwapRequest(_ request: ShiftSwapRequest) {
        var current = loadAllSwapRequests()
        if let idx = current.firstIndex(where: { $0.id == request.id }) {
            current[idx] = request
        }
        persist(current, key: swapKey)
    }

    private func loadAllSwapRequests() -> [ShiftSwapRequest] {
        guard let data = UserDefaults.standard.data(forKey: swapKey),
              let all = try? decoder.decode([ShiftSwapRequest].self, from: data) else {
            return []
        }
        return all
    }

    private func persist<T: Encodable>(_ value: T, key: String) {
        guard let data = try? encoder.encode(value) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
