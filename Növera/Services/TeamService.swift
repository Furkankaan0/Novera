// TeamService.swift
// Növera — Team Business Logic

import Foundation
import Combine

final class TeamService: ObservableObject {
    static let shared = TeamService()

    private let teamRepo = TeamRepository.shared
    private let userRepo = UserRepository.shared

    @Published var teams: [Team] = []
    @Published var announcements: [Announcement] = []
    @Published var swapRequests: [ShiftSwapRequest] = []

    init() {
        loadTeams()
    }

    // MARK: - Teams
    func loadTeams() {
        teams = teamRepo.getTeams()
    }

    func createTeam(name: String, description: String) {
        guard let user = userRepo.getCurrentUser() else { return }
        let member = TeamMember(
            id: UUID(),
            userId: user.id,
            name: user.name,
            profession: user.profession,
            role: .admin,
            joinedAt: Date()
        )
        let team = Team(name: name, description: description, members: [member], createdBy: user.id)
        teamRepo.saveTeam(team)
        loadTeams()
    }

    func joinTeam(inviteCode: String) throws {
        guard let user = userRepo.getCurrentUser() else { return }
        guard var team = teamRepo.getTeams().first(where: { $0.inviteCode == inviteCode.uppercased() }) else {
            throw TeamError.invalidInviteCode
        }
        guard !team.members.contains(where: { $0.userId == user.id }) else {
            throw TeamError.alreadyMember
        }
        let member = TeamMember(
            id: UUID(),
            userId: user.id,
            name: user.name,
            profession: user.profession,
            role: .member,
            joinedAt: Date()
        )
        team.members.append(member)
        team.updatedAt = Date()
        teamRepo.updateTeam(team)
        loadTeams()
    }

    // MARK: - Announcements
    func loadAnnouncements(for teamId: UUID) {
        announcements = teamRepo.getAnnouncements(for: teamId)
    }

    func postAnnouncement(teamId: UUID, title: String, message: String) {
        guard let user = userRepo.getCurrentUser() else { return }
        let announcement = Announcement(
            id: UUID(),
            teamId: teamId,
            title: title,
            message: message,
            createdBy: user.id,
            createdByName: user.name,
            createdAt: Date()
        )
        teamRepo.saveAnnouncement(announcement)
        NotificationService.shared.scheduleAnnouncementNotification(announcement)
        loadAnnouncements(for: teamId)
    }

    // MARK: - Swap Requests
    func loadSwapRequests() {
        guard let user = userRepo.getCurrentUser() else { return }
        swapRequests = teamRepo.getSwapRequests(for: user.id)
    }

    func createSwapRequest(shiftId: UUID, message: String, requestedTo: UUID? = nil) {
        guard let user = userRepo.getCurrentUser() else { return }
        let request = ShiftSwapRequest(
            id: UUID(),
            shiftId: shiftId,
            requestedBy: user.id,
            requestedByName: user.name,
            requestedTo: requestedTo,
            status: .pending,
            message: message,
            createdAt: Date(),
            updatedAt: Date()
        )
        teamRepo.saveSwapRequest(request)
        NotificationService.shared.scheduleSwapRequestNotification(request)
        loadSwapRequests()
    }

    func respondToSwapRequest(id: UUID, status: SwapStatus) {
        guard var request = swapRequests.first(where: { $0.id == id }) else { return }
        request.status = status
        request.updatedAt = Date()
        teamRepo.updateSwapRequest(request)
        loadSwapRequests()
    }
}

// MARK: - Team Errors
enum TeamError: Error, LocalizedError {
    case invalidInviteCode
    case alreadyMember

    var errorDescription: String? {
        switch self {
        case .invalidInviteCode: return "Geçersiz davet kodu."
        case .alreadyMember: return "Bu ekibin zaten üyesisiniz."
        }
    }
}
