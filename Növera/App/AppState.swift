// AppState.swift
// Növera — Global Application State

import SwiftUI
import Combine

final class AppState: ObservableObject {
    // MARK: - Onboarding
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false

    // MARK: - Theme
    @AppStorage("colorSchemePreference") private var colorSchemePreference: String = "system"

    var colorScheme: ColorScheme? {
        switch colorSchemePreference {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    func setColorScheme(_ scheme: String) {
        colorSchemePreference = scheme
        objectWillChange.send()
    }

    // MARK: - Premium
    @AppStorage("isPremiumUser") var isPremiumUser: Bool = false

    // MARK: - Tab Selection
    @Published var selectedTab: TabItem = .dashboard

    // MARK: - User Profile
    @Published var currentUser: User? = nil

    func loadCurrentUser() {
        // Load from UserRepository / local storage
        if let data = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            currentUser = user
        }
    }

    func saveCurrentUser(_ user: User) {
        currentUser = user
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: "currentUser")
        }
    }

    // MARK: - Tab Items
    enum TabItem: String, CaseIterable {
        case dashboard = "Dashboard"
        case calendar = "Takvim"
        case teams = "Ekip"
        case earnings = "Gelir"
        case profile = "Profil"

        var icon: String {
            switch self {
            case .dashboard: return "house.fill"
            case .calendar: return "calendar"
            case .teams: return "person.2.fill"
            case .earnings: return "chart.bar.fill"
            case .profile: return "person.crop.circle.fill"
            }
        }

        var title: String { rawValue }
    }
}
