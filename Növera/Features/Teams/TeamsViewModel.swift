// TeamsViewModel.swift
// Növera — Teams ViewModel

import SwiftUI
import Combine

final class TeamsViewModel: ObservableObject {
    @Published var teams: [Team] = []
    @Published var selectedTeam: Team? = nil
    @Published var announcements: [Announcement] = []
    @Published var swapRequests: [ShiftSwapRequest] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var showCreateTeam: Bool = false
    @Published var showJoinTeam: Bool = false
    @Published var newTeamName: String = ""
    @Published var newTeamDescription: String = ""
    @Published var inviteCode: String = ""
    @Published var announcementTitle: String = ""
    @Published var announcementMessage: String = ""

    private let teamService = TeamService.shared

    func loadData() {
        teamService.loadTeams()
        teams = teamService.teams
        if let first = teams.first {
            selectTeam(first)
        }
        teamService.loadSwapRequests()
        swapRequests = teamService.swapRequests
    }

    func selectTeam(_ team: Team) {
        selectedTeam = team
        teamService.loadAnnouncements(for: team.id)
        announcements = teamService.announcements
    }

    func createTeam() {
        guard !newTeamName.isEmpty else { return }
        teamService.createTeam(name: newTeamName, description: newTeamDescription)
        teams = teamService.teams
        newTeamName = ""
        newTeamDescription = ""
        showCreateTeam = false
        HapticManager.notification(.success)
    }

    func joinTeam() {
        do {
            try teamService.joinTeam(inviteCode: inviteCode)
            teams = teamService.teams
            inviteCode = ""
            showJoinTeam = false
            HapticManager.notification(.success)
        } catch {
            errorMessage = error.localizedDescription
            HapticManager.notification(.error)
        }
    }

    func postAnnouncement() {
        guard let team = selectedTeam, !announcementTitle.isEmpty else { return }
        teamService.postAnnouncement(teamId: team.id, title: announcementTitle, message: announcementMessage)
        announcements = teamService.announcements
        announcementTitle = ""
        announcementMessage = ""
        HapticManager.notification(.success)
    }

    func respondToSwap(id: UUID, status: SwapStatus) {
        teamService.respondToSwapRequest(id: id, status: status)
        swapRequests = teamService.swapRequests
        HapticManager.notification(.success)
    }

    var todayMembersWorking: [TeamMember] {
        guard let team = selectedTeam else { return [] }
        let todayShifts = ShiftRepository.shared.getShifts(for: Date())
        let workingUserIds = Set(todayShifts.map { $0.userId })
        return team.members.filter { workingUserIds.contains($0.userId) }
    }
}
