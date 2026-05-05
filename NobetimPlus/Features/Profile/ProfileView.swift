import SwiftUI

struct ProfileView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.large) {
                    profileHeader
                    PremiumPaywallCard {
                        appState.activeSheet = .premium
                    }
                    SettingsSummaryCard(appState: appState)
                    privacyCard
                }
                .padding(Spacing.large)
            }
            .navigationTitle("Profil")
            .toolbar {
                Button {
                    appState.activeSheet = .settings
                } label: {
                    Image(systemName: "slider.horizontal.3")
                }
                .accessibilityLabel("Ayarlar")
            }
        }
    }

    private var profileHeader: some View {
        HStack(spacing: Spacing.medium) {
            Circle()
                .fill(LinearGradient(colors: [DesignColors.primary, DesignColors.secondary], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 72, height: 72)
                .overlay(Text(String(appState.profile.fullName.prefix(1))).font(.title.bold()).foregroundStyle(.white))
            VStack(alignment: .leading, spacing: 6) {
                Text(appState.profile.fullName).font(Typography.title)
                Text("\(appState.profile.role.localizedTitle) • \(appState.profile.department)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                ShiftTypePill(title: appState.profile.premiumStatus.isPremium ? "Premium aktif" : "Ücretsiz plan", color: appState.profile.premiumStatus.isPremium ? DesignColors.success : DesignColors.warning, systemImage: "sparkles")
            }
            Spacer()
        }
        .padding(Spacing.large)
        .glassCard()
    }

    private var privacyCard: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Label("Gizlilik", systemImage: "lock.shield.fill")
                .font(Typography.title)
                .foregroundStyle(DesignColors.primary)
            Text("Nöbetim+ çalışma takibi verisi tutar, hasta verisi için tasarlanmamıştır. Veriler MVP’de cihazda saklanır; bildirim ve takvim izinleri yalnızca ilgili özellikler için istenir.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(Spacing.large)
        .glassCard()
    }
}

struct SettingsSummaryCard: View {
    @ObservedObject var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Text("Mesai ayarları").font(Typography.title)
            HStack {
                Text("Aylık normal saat")
                Spacer()
                Text("\(appState.profile.monthlyNormalHours, specifier: "%.0f")s").bold()
            }
            HStack {
                Text("Fazla mesai ücreti")
                Spacer()
                Text("\(appState.profile.overtimeHourlyRate, specifier: "%.0f") TRY").bold()
            }
            HStack {
                Text("Resmi tatil ücreti")
                Spacer()
                Text("\(appState.profile.holidayHourlyRate, specifier: "%.0f") TRY").bold()
            }
        }
        .padding(Spacing.large)
        .glassCard()
    }
}
