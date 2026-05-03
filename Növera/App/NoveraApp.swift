// NoveraApp.swift
// Növera — Premium Nöbet & Vardiya Yönetimi
// iOS 17+, SwiftUI, MVVM

import SwiftUI

@main
struct NoveraApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var authService = AuthService()
    @StateObject private var notificationService = NotificationService.shared

    var body: some Scene {
        WindowGroup {
            AppRouter()
                .environmentObject(appState)
                .environmentObject(authService)
                .environmentObject(notificationService)
                .preferredColorScheme(appState.colorScheme)
                .onAppear {
                    configureAppearance()
                    notificationService.requestAuthorization()
                }
        }
    }

    private func configureAppearance() {
        // Custom navigation bar appearance
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithTransparentBackground()
        navAppearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold),
            .foregroundColor: UIColor.label
        ]
        navAppearance.largeTitleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 34, weight: .bold),
            .foregroundColor: UIColor.label
        ]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance

        // Custom tab bar appearance
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithTransparentBackground()
        UITabBar.appearance().standardAppearance = tabAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        }
    }
}
