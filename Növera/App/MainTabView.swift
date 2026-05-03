// MainTabView.swift
// Növera — Main Tab Navigation

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var tabBarVisible = true

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
                .tag(AppState.TabItem.dashboard)

            CalendarView()
                .tabItem {
                    Label("Takvim", systemImage: "calendar")
                }
                .tag(AppState.TabItem.calendar)

            TeamsView()
                .tabItem {
                    Label("Ekip", systemImage: "person.2.fill")
                }
                .tag(AppState.TabItem.teams)

            EarningsView()
                .tabItem {
                    Label("Gelir", systemImage: "chart.bar.fill")
                }
                .tag(AppState.TabItem.earnings)

            ProfileView()
                .tabItem {
                    Label("Profil", systemImage: "person.crop.circle.fill")
                }
                .tag(AppState.TabItem.profile)
        }
        .tint(NoveraColors.primary)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppState())
        .environmentObject(AuthService())
}
