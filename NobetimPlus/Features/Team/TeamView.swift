import SwiftUI

struct TeamView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        NavigationStack {
            ZStack {
                CinematicBackground()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: Spacing.large) {
                        inviteCard
                        teamSection("Bugün çalışanlar", members: members.filter(\.isOnDutyToday), color: DesignColors.secondary)
                        teamSection("İzinli olanlar", members: members.filter(\.isOnLeave), color: DesignColors.success)
                        teamSection("Yükü artanlar", members: members.sorted { $0.workloadScore > $1.workloadScore }.prefix(3).map { $0 }, color: DesignColors.warning)
                        announcements
                    }
                    .padding(Spacing.large)
                    .padding(.bottom, 110)
                }
            }
            .navigationTitle("Ekip")
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }

    private var members: [TeamMember] {
        appState.teams.first?.members ?? []
    }

    private var inviteCard: some View {
        PremiumGlassPanel(cornerRadius: 32) {
            VStack(alignment: .leading, spacing: Spacing.large) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        ShiftStatusCapsule(title: "Mock ekip", subtitle: appState.teams.first?.department, color: DesignColors.primary, systemImage: "person.3.fill")
                        Text(appState.teams.first?.name ?? "Ekip yok")
                            .font(.system(.title, design: .rounded, weight: .black))
                    }
                    Spacer()
                    Image("BrandLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                        .accessibilityHidden(true)
                }

                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Davet kodu")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.secondary)
                        Text(appState.teams.first?.inviteCode ?? "NOBET-PLUS")
                            .font(.title3.monospaced().weight(.black))
                            .foregroundStyle(DesignColors.secondary)
                    }
                    Spacer()
                    Button {
                        appState.showToast("Davet kodu mock olarak hazır")
                    } label: {
                        Label("Katıl", systemImage: "person.badge.plus")
                            .font(.subheadline.weight(.bold))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(DesignColors.primary)
                    .frame(minHeight: 44)
                }
            }
        }
    }

    private func teamSection(_ title: String, members: [TeamMember], color: Color) -> some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            HStack {
                Text(title)
                    .font(.system(.title3, design: .rounded, weight: .black))
                Spacer()
                ShiftStatusCapsule(title: "\(members.count)", color: color, systemImage: "circle.grid.2x2.fill")
            }
            if members.isEmpty {
                EmptyStateView(title: "Kayıt yok", message: "Bu bölüm ekip senkronizasyonu geldiğinde canlı veriye bağlanacak.", systemImage: "person.crop.circle.badge.questionmark")
            } else {
                ForEach(members) { member in
                    TeamMemberRow(member: member)
                }
            }
        }
    }

    private var announcements: some View {
        PremiumGlassPanel(cornerRadius: 28) {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                ShiftStatusCapsule(title: "Duyurular", subtitle: "P1", color: DesignColors.accent, systemImage: "megaphone.fill")
                Text("Ekip duyuruları ve nöbet takası bildirimleri backend eklendiğinde burada canlı çalışacak.")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
    }
}
