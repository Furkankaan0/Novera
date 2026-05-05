import Foundation

@MainActor
protocol SettingsRepositoryProtocol {
    func loadProfile() -> UserProfile
    func saveProfile(_ profile: UserProfile)
}
