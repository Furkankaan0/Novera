import SwiftUI

struct RootTabView: View {
    @ObservedObject var appState: AppState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isFabExpanded = false

    var body: some View {
        ZStack(alignment: .bottom) {
            CinematicBackground()

            if appState.hasCompletedOnboarding {
                selectedContent
                    .transition(.opacity.combined(with: .scale(scale: reduceMotion ? 1 : 0.985)))
                    .task { appState.bootstrap() }

                VStack(alignment: .trailing, spacing: 12) {
                    if isFabExpanded {
                        fabMenu
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    GlassDockTabBar(selection: $appState.selectedTab) {
                        HapticService.selection(enabled: appState.profile.hapticsEnabled)
                        withAnimation(reduceMotion ? .default : .spring(response: 0.32, dampingFraction: 0.76)) {
                            isFabExpanded.toggle()
                        }
                    }
                }
            } else {
                OnboardingView(appState: appState)
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

    @ViewBuilder
    private var selectedContent: some View {
        switch appState.selectedTab {
        case .today:
            DashboardView(appState: appState)
        case .calendar:
            CalendarView(appState: appState)
        case .team:
            TeamView(appState: appState)
        case .analytics:
            AnalyticsView(appState: appState)
        case .profile:
            ProfileView(appState: appState)
        }
    }

    private var fabMenu: some View {
        VStack(alignment: .trailing, spacing: 10) {
            fabAction("Yeni nöbet", systemImage: "calendar.badge.plus") { openAddShift() }
            fabAction("Hızlı vardiya", systemImage: "bolt.fill") { openAddShift() }
            fabAction("İzin / rapor", systemImage: "figure.mind.and.body") { openAddShift() }
            fabAction("Gelir ayarı", systemImage: "banknote.fill") { appState.activeSheet = .settings }
        }
        .padding(12)
        .glassCard(cornerRadius: 26)
        .padding(.horizontal, 18)
        .padding(.bottom, 84)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }

    private func fabAction(_ title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(reduceMotion ? .default : .spring(response: 0.28, dampingFraction: 0.82)) {
                isFabExpanded = false
            }
            action()
        } label: {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .frame(minHeight: 44)
                .background(DesignColors.primary.opacity(0.28), in: Capsule())
                .overlay(Capsule().stroke(Color.white.opacity(0.20), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }

    private func openAddShift() {
        appState.activeSheet = .addShift
    }
}

#Preview {
    PreviewRoot.makeRoot()
}
