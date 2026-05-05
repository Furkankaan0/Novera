import SwiftUI

struct RootTabView: View {
    @ObservedObject var appState: AppState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isFabExpanded = false

    var body: some View {
        ZStack(alignment: .bottom) {
            AppBackground()

            if appState.hasCompletedOnboarding {
                TabView(selection: $appState.selectedTab) {
                    DashboardView(appState: appState)
                        .tag(AppTab.today)
                        .tabItem { Label(AppTab.today.title, systemImage: AppTab.today.systemImage) }

                    CalendarView(appState: appState)
                        .tag(AppTab.calendar)
                        .tabItem { Label(AppTab.calendar.title, systemImage: AppTab.calendar.systemImage) }

                    TeamView(appState: appState)
                        .tag(AppTab.team)
                        .tabItem { Label(AppTab.team.title, systemImage: AppTab.team.systemImage) }

                    AnalyticsView(appState: appState)
                        .tag(AppTab.analytics)
                        .tabItem { Label(AppTab.analytics.title, systemImage: AppTab.analytics.systemImage) }

                    ProfileView(appState: appState)
                        .tag(AppTab.profile)
                        .tabItem { Label(AppTab.profile.title, systemImage: AppTab.profile.systemImage) }
                }
                .tint(DesignColors.primary)
                .task { appState.bootstrap() }
            } else {
                OnboardingView(appState: appState)
            }

            if appState.hasCompletedOnboarding {
                VStack(alignment: .trailing, spacing: 12) {
                    if isFabExpanded {
                        fabMenu
                            .transition(.scale.combined(with: .opacity))
                    }
                    FloatingAddButton(expanded: isFabExpanded) {
                        HapticService.selection(enabled: appState.profile.hapticsEnabled)
                        withAnimation(reduceMotion ? .default : .spring(response: 0.32, dampingFraction: 0.72)) {
                            isFabExpanded.toggle()
                        }
                    }
                }
                .padding(.trailing, 20)
                .padding(.bottom, 82)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }

            if let toast = appState.toastMessage {
                VStack {
                    AnimatedToast(message: toast, systemImage: "checkmark.circle.fill")
                    Spacer()
                }
                .padding(.top, 18)
            }
        }
        .sheet(item: $appState.activeSheet) { sheet in
            switch sheet {
            case .addShift:
                AddShiftView(appState: appState)
            case .premium:
                PremiumPaywallView(appState: appState)
            case .settings:
                SettingsView(appState: appState)
            }
        }
    }

    private var fabMenu: some View {
        VStack(alignment: .trailing, spacing: 10) {
            fabAction("Yeni nöbet ekle", systemImage: "calendar.badge.plus") { openAddShift() }
            fabAction("Hızlı vardiya ekle", systemImage: "bolt.fill") { openAddShift() }
            fabAction("İzin ekle", systemImage: "figure.mind.and.body") { openAddShift() }
            fabAction("Gelir kalemi ekle", systemImage: "banknote.fill") { appState.activeSheet = .settings }
        }
        .padding(10)
        .glassCard(cornerRadius: 24)
    }

    private func fabAction(_ title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button {
            isFabExpanded = false
            action()
        } label: {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .frame(minHeight: 44)
        }
        .buttonStyle(.borderedProminent)
        .tint(DesignColors.primary)
        .accessibilityLabel(title)
    }

    private func openAddShift() {
        appState.activeSheet = .addShift
    }
}

#Preview {
    PreviewRoot.makeRoot()
}
