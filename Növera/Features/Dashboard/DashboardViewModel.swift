// DashboardViewModel.swift
// Növera — Dashboard ViewModel

import SwiftUI
import Combine

final class DashboardViewModel: ObservableObject {
    @Published var todayShifts: [Shift] = []
    @Published var upcomingShift: Shift? = nil
    @Published var weeklyHours: Double = 0
    @Published var monthlyShiftCount: Int = 0
    @Published var estimatedOvertime: Double = 0
    @Published var weeklyData: [(String, Double)] = []
    @Published var recentAnnouncements: [Announcement] = []
    @Published var isLoading: Bool = false
    @Published var currentUser: User? = nil

    private let shiftService = ShiftService.shared
    private let revenueService = RevenueCalculationService.shared
    private let teamService = TeamService.shared
    private let userRepo = UserRepository.shared

    func loadData() {
        isLoading = true
        currentUser = userRepo.getCurrentUser()

        guard let user = currentUser else {
            isLoading = false
            return
        }

        let userId = user.id
        todayShifts = shiftService.shiftsForToday(userId: userId)
        upcomingShift = shiftService.nextShift(userId: userId)
        weeklyHours = shiftService.totalHoursThisWeek(userId: userId)
        monthlyShiftCount = shiftService.totalShiftsThisMonth(userId: userId)

        let allShifts = ShiftRepository.shared.getShifts()
        estimatedOvertime = revenueService.overtimeHoursForMonth(
            shifts: allShifts,
            month: Date()
        )
        weeklyData = revenueService.weeklyHoursBreakdown(shifts: allShifts, userId: userId)

        // Load first team announcements
        teamService.loadTeams()
        if let team = teamService.teams.first {
            recentAnnouncements = teamService
                .teamRepo_getAnnouncements(teamId: team.id)
                .prefix(3)
                .map { $0 }
        }

        isLoading = false
    }

    var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Günaydın"
        case 12..<17: return "İyi öğleden sonralar"
        case 17..<22: return "İyi akşamlar"
        default: return "İyi geceler"
        }
    }

    var userName: String {
        currentUser?.name.components(separatedBy: " ").first ?? "Merhaba"
    }

    var todayDateString: String {
        Date().fullDateFormatted
    }

    var weeklyHoursFormatted: String {
        weeklyHours.hoursFormatted
    }

    var overtimeFormatted: String {
        estimatedOvertime.hoursFormatted
    }
}

// MARK: - TeamService extension for ViewModel access
extension TeamService {
    func teamRepo_getAnnouncements(teamId: UUID) -> [Announcement] {
        TeamRepository.shared.getAnnouncements(for: teamId)
    }
}
