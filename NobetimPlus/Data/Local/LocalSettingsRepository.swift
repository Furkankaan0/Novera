import Foundation

@MainActor
final class LocalSettingsRepository: SettingsRepositoryProtocol {
    private let key = "nobetimplus.userProfile"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadProfile() -> UserProfile {
        guard
            let data = defaults.data(forKey: key),
            let profile = try? JSONDecoder().decode(UserProfile.self, from: data)
        else {
            return .demo
        }
        return profile
    }

    func saveProfile(_ profile: UserProfile) {
        let data = try? JSONEncoder().encode(profile)
        defaults.set(data, forKey: key)
    }
}
