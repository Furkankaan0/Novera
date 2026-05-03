// AppRouter.swift
// Növera — Navigation & Route Management

import SwiftUI

struct AppRouter: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authService: AuthService

    var body: some View {
        Group {
            if appState.hasCompletedOnboarding {
                MainTabView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            } else {
                OnboardingView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.85), value: appState.hasCompletedOnboarding)
    }
}
