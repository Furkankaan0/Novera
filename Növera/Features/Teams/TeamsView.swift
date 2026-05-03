// TeamsView.swift
// Növera — Team Management Screen

import SwiftUI

struct TeamsView: View {
    @StateObject private var vm = TeamsViewModel()
    @State private var showPostAnnouncement = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: NoveraSpacing.lg) {
                    if vm.teams.isEmpty {
                        noTeamState
                    } else {
                        // Team selector (if multiple)
                        if vm.teams.count > 1 {
                            teamSelectorSection
                                .padding(.horizontal, NoveraSpacing.md)
                        }

                        // Today on duty
                        todaySection
                            .padding(.horizontal, NoveraSpacing.md)

                        // Members
                        if let team = vm.selectedTeam {
                            membersSection(team)
                                .padding(.horizontal, NoveraSpacing.md)
                        }

                        // Announcements
                        announcementsSection
                            .padding(.horizontal, NoveraSpacing.md)

                        // Swap requests
                        if !vm.swapRequests.isEmpty {
                            swapRequestsSection
                                .padding(.horizontal, NoveraSpacing.md)
                        }
                    }

                    Spacer(minLength: 100)
                }
                .padding(.top, NoveraSpacing.sm)
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Ekip")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button("Ekip Oluştur", systemImage: "person.badge.plus") {
                            vm.showCreateTeam = true
                        }
                        Button("Ekibe Katıl", systemImage: "link") {
                            vm.showJoinTeam = true
                        }
                        if vm.selectedTeam != nil {
                            Button("Duyuru Yap", systemImage: "megaphone.fill") {
                                showPostAnnouncement = true
                            }
                        }
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(NoveraColors.primary)
                    }
                }
            }
            .onAppear { vm.loadData() }
            .sheet(isPresented: $vm.showCreateTeam) { createTeamSheet }
            .sheet(isPresented: $vm.showJoinTeam) { joinTeamSheet }
            .sheet(isPresented: $showPostAnnouncement) { announcementSheet }
        }
    }

    // MARK: - No Team State
    var noTeamState: some View {
        NoveraEmptyState(
            icon: "person.2.slash",
            title: "Henüz ekibiniz yok",
            subtitle: "Yeni bir ekip oluşturun veya davet koduyla mevcut bir ekibe katılın"
        )
        .padding(.top, NoveraSpacing.xl)
    }

    // MARK: - Team Selector
    var teamSelectorSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: NoveraSpacing.sm) {
                ForEach(vm.teams) { team in
                    TeamChip(
                        team: team,
                        isSelected: vm.selectedTeam?.id == team.id
                    ) { vm.selectTeam(team) }
                }
            }
        }
    }

    // MARK: - Today Section
    var todaySection: some View {
        VStack(alignment: .leading, spacing: NoveraSpacing.sm) {
            NoveraSectionHeader(
                title: "Bugün Görevde",
                subtitle: "\(vm.todayMembersWorking.count) kişi"
            )

            if vm.todayMembersWorking.isEmpty {
                Text("Bugün nöbette kimse yok")
                    .font(NoveraFonts.subheadline())
                    .foregroundStyle(NoveraColors.textSecondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .glassBackground(cornerRadius: NoveraRadius.md)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: NoveraSpacing.sm) {
                        ForEach(vm.todayMembersWorking) { member in
                            MemberAvatarCard(member: member)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Members Section
    func membersSection(_ team: Team) -> some View {
        VStack(alignment: .leading, spacing: NoveraSpacing.sm) {
            NoveraSectionHeader(
                title: "Ekip Üyeleri",
                subtitle: "\(team.memberCount) üye"
            )

            VStack(spacing: NoveraSpacing.xs) {
                ForEach(team.members) { member in
                    MemberRow(member: member)
                }
            }
            .padding(NoveraSpacing.sm)
            .glassBackground(cornerRadius: NoveraRadius.lg)
            .noveraShadow(NoveraShadows.soft)
        }
    }

    // MARK: - Announcements Section
    var announcementsSection: some View {
        VStack(alignment: .leading, spacing: NoveraSpacing.sm) {
            NoveraSectionHeader(title: "Duyurular")

            if vm.announcements.isEmpty {
                Text("Henüz duyuru yok")
                    .font(NoveraFonts.subheadline())
                    .foregroundStyle(NoveraColors.textSecondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .glassBackground(cornerRadius: NoveraRadius.md)
            } else {
                ForEach(vm.announcements) { announcement in
                    AnnouncementRow(announcement: announcement)
                }
            }
        }
    }

    // MARK: - Swap Requests
    var swapRequestsSection: some View {
        VStack(alignment: .leading, spacing: NoveraSpacing.sm) {
            NoveraSectionHeader(title: "Takas İstekleri")
            ForEach(vm.swapRequests) { request in
                SwapRequestRow(request: request) { status in
                    vm.respondToSwap(id: request.id, status: status)
                }
            }
        }
    }

    // MARK: - Create Team Sheet
    var createTeamSheet: some View {
        NavigationStack {
            VStack(spacing: NoveraSpacing.md) {
                NoveraFormField(label: "Ekip Adı", isRequired: true) {
                    NoveraTextField(placeholder: "Örn: Acil Servis Ekibi", text: $vm.newTeamName, icon: "person.2")
                }
                NoveraFormField(label: "Açıklama") {
                    NoveraTextField(placeholder: "Ekip açıklaması", text: $vm.newTeamDescription, icon: "text.alignleft")
                }
                NoveraPrimaryButton("Ekip Oluştur", icon: "checkmark") { vm.createTeam() }
            }
            .padding(NoveraSpacing.md)
            .navigationTitle("Yeni Ekip")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { vm.showCreateTeam = false }
                }
            }
        }
    }

    // MARK: - Join Team Sheet
    var joinTeamSheet: some View {
        NavigationStack {
            VStack(spacing: NoveraSpacing.md) {
                NoveraFormField(label: "Davet Kodu", isRequired: true) {
                    NoveraTextField(placeholder: "6 haneli kod (örn: ABC123)", text: $vm.inviteCode, icon: "link")
                }
                if let error = vm.errorMessage {
                    Text(error)
                        .font(NoveraFonts.subheadline())
                        .foregroundStyle(NoveraColors.error)
                }
                NoveraPrimaryButton("Katıl", icon: "arrow.right") { vm.joinTeam() }
            }
            .padding(NoveraSpacing.md)
            .navigationTitle("Ekibe Katıl")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { vm.showJoinTeam = false }
                }
            }
        }
    }

    // MARK: - Announcement Sheet
    var announcementSheet: some View {
        NavigationStack {
            VStack(spacing: NoveraSpacing.md) {
                NoveraFormField(label: "Başlık", isRequired: true) {
                    NoveraTextField(placeholder: "Duyuru başlığı", text: $vm.announcementTitle, icon: "megaphone")
                }
                NoveraFormField(label: "Mesaj") {
                    NoveraTextField(placeholder: "Duyuru içeriği...", text: $vm.announcementMessage, icon: "text.alignleft")
                }
                NoveraPrimaryButton("Duyuru Yap", icon: "megaphone.fill") {
                    vm.postAnnouncement()
                    showPostAnnouncement = false
                }
            }
            .padding(NoveraSpacing.md)
            .navigationTitle("Duyuru")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { showPostAnnouncement = false }
                }
            }
        }
    }
}

// MARK: - Team Chip
struct TeamChip: View {
    let team: Team
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(team.name)
                .font(NoveraFonts.subheadline(.medium))
                .foregroundStyle(isSelected ? .white : NoveraColors.primary)
                .padding(.horizontal, NoveraSpacing.md)
                .padding(.vertical, NoveraSpacing.sm)
                .background(
                    Capsule()
                        .fill(isSelected ? NoveraColors.primary : NoveraColors.primary.opacity(0.12))
                )
        }
        .scaleOnPress()
    }
}

// MARK: - Member Avatar Card
struct MemberAvatarCard: View {
    let member: TeamMember

    var body: some View {
        VStack(spacing: NoveraSpacing.xs) {
            ZStack {
                Circle()
                    .fill(NoveraColors.primaryGradient)
                    .frame(width: 52, height: 52)
                Text(member.name.prefix(2).uppercased())
                    .font(NoveraFonts.headline(.bold))
                    .foregroundStyle(.white)
            }
            Text(member.name.components(separatedBy: " ").first ?? "")
                .font(NoveraFonts.caption(.medium))
                .foregroundStyle(NoveraColors.textPrimary)
                .lineLimit(1)
        }
        .frame(width: 64)
    }
}

// MARK: - Member Row
struct MemberRow: View {
    let member: TeamMember

    var body: some View {
        HStack(spacing: NoveraSpacing.sm) {
            ZStack {
                Circle()
                    .fill(NoveraColors.primaryGradient)
                    .frame(width: 40, height: 40)
                Text(member.name.prefix(2).uppercased())
                    .font(NoveraFonts.footnote(.bold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(member.name)
                    .font(NoveraFonts.subheadline(.semibold))
                Text(member.profession.displayName)
                    .font(NoveraFonts.caption())
                    .foregroundStyle(NoveraColors.textSecondary)
            }

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: member.role.icon)
                    .font(.system(size: 11))
                Text(member.role.displayName)
                    .font(NoveraFonts.caption(.semibold))
            }
            .foregroundStyle(member.role.color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Capsule().fill(member.role.color.opacity(0.12)))
        }
        .padding(NoveraSpacing.sm)
        .accessibilityLabel("\(member.name), \(member.profession.displayName), \(member.role.displayName)")
    }
}

// MARK: - Swap Request Row
struct SwapRequestRow: View {
    let request: ShiftSwapRequest
    let respond: (SwapStatus) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: NoveraSpacing.sm) {
            HStack {
                Image(systemName: "arrow.left.arrow.right")
                    .foregroundStyle(NoveraColors.primary)
                VStack(alignment: .leading, spacing: 2) {
                    Text(request.requestedByName)
                        .font(NoveraFonts.subheadline(.semibold))
                    Text(request.message)
                        .font(NoveraFonts.caption())
                        .foregroundStyle(NoveraColors.textSecondary)
                        .lineLimit(2)
                }
                Spacer()
                SwapStatusBadge(status: request.status)
            }

            if request.status == .pending {
                HStack(spacing: NoveraSpacing.sm) {
                    Button("Kabul Et") { respond(.accepted) }
                        .font(NoveraFonts.subheadline(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(Capsule().fill(NoveraColors.success))

                    Button("Reddet") { respond(.rejected) }
                        .font(NoveraFonts.subheadline(.semibold))
                        .foregroundStyle(NoveraColors.error)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(Capsule().fill(NoveraColors.error.opacity(0.12)))
                }
            }
        }
        .padding(NoveraSpacing.md)
        .glassBackground(cornerRadius: NoveraRadius.md)
        .noveraShadow(NoveraShadows.soft)
    }
}

// MARK: - Swap Status Badge
struct SwapStatusBadge: View {
    let status: SwapStatus

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.icon)
                .font(.system(size: 11, weight: .semibold))
            Text(status.displayName)
                .font(NoveraFonts.caption(.semibold))
        }
        .foregroundStyle(status.color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Capsule().fill(status.color.opacity(0.12)))
    }
}

#Preview {
    TeamsView()
        .environmentObject(AppState())
}
