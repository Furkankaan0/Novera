import SwiftUI

struct TeamView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.large) {
                    inviteCard
                    teamSection("Bugün çalışanlar", members: members.filter(\.isOnDutyToday))
                    teamSection("İzinli olanlar", members: members.filter(\.isOnLeave))
                    teamSection("En yoğun çalışanlar", members: members.sorted { $0.workloadScore > $1.workloadScore }.prefix(3).map { $0 })
                    EmptyStateView(title: "Ekip duyuruları", message: "Duyuru paylaşımı ve nöbet takası bildirimleri backend eklendiğinde bu alana bağlanacak.", systemImage: "megaphone.fill")
                }
                .padding(Spacing.large)
            }
            .navigationTitle("Ekip")
        }
    }

    private var members: [TeamMember] {
        appState.teams.first?.members ?? []
    }

    private var inviteCard: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Text(appState.teams.first?.name ?? "Ekip yok")
                .font(Typography.title)
            Text("Davet kodu")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(appState.teams.first?.inviteCode ?? "NOBET-PLUS")
                .font(.title3.monospaced().weight(.bold))
                .foregroundStyle(DesignColors.primary)
            Button {
                appState.showToast("Davet kodu mock olarak hazır")
            } label: {
                Label("Davet kodu ile katıl", systemImage: "person.badge.plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(DesignColors.primary)
        }
        .padding(Spacing.large)
        .glassCard()
    }

    private func teamSection(_ title: String, members: [TeamMember]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Text(title).font(Typography.title)
            ForEach(members) { member in
                TeamMemberRow(member: member)
            }
        }
    }
}
