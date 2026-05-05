import Combine
import Foundation

@MainActor
final class AppState: ObservableObject {
    @Published var selectedTab: AppTab = .today
    @Published var activeSheet: AppSheet?
    @Published var shifts: [Shift] = []
    @Published var teams: [Team] = []
    @Published var profile: UserProfile
    @Published var hasCompletedOnboarding: Bool
    @Published var toastMessage: String?
    @Published var isLoading = false
    @Published var errorMessage: String?

    let calculator = WorkCalculationEngine()
    let insightEngine = SmartInsightEngine()
    let notificationService = NotificationService()
    let appleSignInManager = AppleSignInManager()

    private let shiftRepository: ShiftRepositoryProtocol
    private let teamRepository: TeamRepositoryProtocol
    private let settingsRepository: SettingsRepositoryProtocol

    init(
        shiftRepository: ShiftRepositoryProtocol,
        teamRepository: TeamRepositoryProtocol,
        settingsRepository: SettingsRepositoryProtocol
    ) {
        self.shiftRepository = shiftRepository
        self.teamRepository = teamRepository
        self.settingsRepository = settingsRepository
        self.profile = settingsRepository.loadProfile()
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "nobetimplus.hasCompletedOnboarding")
    }

    func bootstrap() {
        isLoading = true
        do {
            shifts = try shiftRepository.fetchShifts()
            teams = try teamRepository.fetchTeams()
            if shifts.isEmpty {
                try MockData.shifts.forEach { try shiftRepository.upsert($0) }
                shifts = try shiftRepository.fetchShifts()
            }
            errorMessage = nil
        } catch {
            shifts = MockData.shifts
            teams = MockData.teams
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: "nobetimplus.hasCompletedOnboarding")
    }

    func addShift(_ shift: Shift) {
        do {
            try shiftRepository.upsert(shift)
            shifts = try shiftRepository.fetchShifts()
            notificationService.scheduleShiftReminder(for: shift)
            showToast("Nöbet kaydedildi")
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteShift(_ shift: Shift) {
        do {
            try shiftRepository.delete(shift)
            shifts = try shiftRepository.fetchShifts()
            notificationService.cancelReminder(for: shift)
            showToast("Nöbet silindi")
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func updateProfile(_ profile: UserProfile) {
        self.profile = profile
        settingsRepository.saveProfile(profile)
    }

    func workSettings() -> WorkCalculationSettings {
        WorkCalculationSettings(
            monthlyNormalHours: profile.monthlyNormalHours,
            overtimeHourlyRate: profile.overtimeHourlyRate,
            holidayHourlyRate: profile.holidayHourlyRate,
            nightWorkMultiplier: profile.nightWorkMultiplier,
            additionalPayment: profile.additionalPayment
        )
    }

    func monthlySummary(month: Date = .now) -> WorkSummary {
        calculator.makeMonthlySummary(shifts: shifts, month: month, settings: workSettings())
    }

    func insights(month: Date = .now) -> [SmartInsight] {
        insightEngine.generateInsights(shifts: shifts, profile: profile, month: month)
    }

    func requestNotifications() {
        Task {
            let granted = await notificationService.requestPermission()
            showToast(granted ? "Bildirimler açıldı" : "Bildirim izni verilmedi")
        }
    }

    func showToast(_ message: String) {
        toastMessage = message
        Task {
            try? await Task.sleep(for: .seconds(2))
            if toastMessage == message {
                toastMessage = nil
            }
        }
    }
}
