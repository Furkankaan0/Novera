import SwiftUI

struct ProfileView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        NavigationStack {
            ZStack {
                CinematicBackground()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: Spacing.large) {
                        profileHeader
                        PremiumPaywallCard {
                            appState.activeSheet = .premium
                        }
                        SettingsSummaryCard(appState: appState)
                        privacyCard
                    }
                    .padding(Spacing.large)
                    .padding(.bottom, 110)
                }
            }
            .navigationTitle("Profil")
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                Button {
                    appState.activeSheet = .settings
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundStyle(DesignColors.secondary)
                }
                .accessibilityLabel("Ayarlar")
            }
        }
    }

    private var profileHeader: some View {
        PremiumGlassPanel(cornerRadius: 32) {
            HStack(spacing: Spacing.medium) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [DesignColors.primary, DesignColors.accent, DesignColors.secondary], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 76, height: 76)
                    Text(String(appState.profile.fullName.prefix(1)))
                        .font(.title.bold())
                        .foregroundStyle(.white)
                }
                .shadow(color: DesignColors.accent.opacity(0.32), radius: 16, y: 8)

                VStack(alignment: .leading, spacing: 7) {
                    Text(appState.profile.fullName)
                        .font(.system(.title2, design: .rounded, weight: .black))
                    Text("\(appState.profile.role.localizedTitle) • \(appState.profile.department)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                    ShiftStatusCapsule(
                        title: appState.profile.premiumStatus.isPremium ? "Premium aktif" : "Ücretsiz plan",
                        color: appState.profile.premiumStatus.isPremium ? DesignColors.success : DesignColors.warning,
                        systemImage: "sparkles"
                    )
                }
                Spacer()
            }
        }
    }

    private var privacyCard: some View {
        PremiumGlassPanel(cornerRadius: 28) {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                Label("Gizlilik", systemImage: "lock.shield.fill")
                    .font(Typography.title)
                    .foregroundStyle(DesignColors.secondary)
                Text("Nöbetim+ çalışma takibi verisi tutar; hasta verisi için tasarlanmamıştır. Veriler MVP’de cihazda saklanır. Bildirim ve takvim izinleri yalnızca ilgili özellikler için istenir.")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct SettingsSummaryCard: View {
    @ObservedObject var appState: AppState

    var body: some View {
        PremiumGlassPanel(cornerRadius: 28) {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                Text("Mesai ayarları")
                    .font(Typography.title)
                summaryRow("Aylık normal saat", String(format: "%.0fs", appState.profile.monthlyNormalHours))
                summaryRow("Fazla mesai ücreti", String(format: "%.0f TRY", appState.profile.overtimeHourlyRate))
                summaryRow("Resmi tatil ücreti", String(format: "%.0f TRY", appState.profile.holidayHourlyRate))
            }
        }
    }

    private func summaryRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline.monospacedDigit().weight(.black))
        }
    }
}
