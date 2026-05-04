// TeamsView.swift
// Növera — Premium Team Management

import SwiftUI

struct TeamsView: View {
    @StateObject private var vm = TeamsViewModel()
    @State private var showPostAnnouncement = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: NSpacing.xl) {
                    if vm.teams.isEmpty {
                        noTeamState
                            .entrance(delay: 0.05)
                    } else {
                        // Team selector
                        if vm.teams.count > 1 {
                            teamSelectorSection
                                .padding(.horizontal, NSpacing.base)
                                .entrance(delay: 0.03)
                        }

                        // Today on duty
                        todaySection
                            .padding(.horizontal, NSpacing.base)
                            .entrance(delay: 0.06)

                        // Members
                        if let team = vm.selectedTeam {
                            membersSection(team)
                                .padding(.horizontal, NSpacing.base)
                                .entrance(delay: 0.09)
                        }

                        // Announcements
                        announcementsSection
                            .padding(.horizontal, NSpacing.base)
                            .entrance(delay: 0.12)

                        // Swap requests
                        if !vm.swapRequests.isEmpty {
                            swapRequestsSection
                                .padding(.horizontal, NSpacing.base)
                                .entrance(delay: 0.15)
                        }
                    }

                    Spacer(minLength: 120)
                }
                .padding(.top, NSpacing.sm)
            }
            .screenBackground()
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
                            .foregroundStyle(NColor.primaryFallback)
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
        PremiumEmptyState(
            icon: "person.2.slash",
            title: "Henüz ekibiniz yok",
            subtitle: "Yeni bir ekip oluşturun veya davet koduyla mevcut bir ekibe katılın"
        )
        .padding(.top, NSpacing.xxl)
    }

    // MARK: - Team Selector
    var teamSelectorSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: NSpacing.sm) {
                ForEach(vm.teams) { team in
                    PremiumTeamChip(
                        team: team,
                        isSelected: vm.selectedTeam?.id == team.id
                    ) { vm.selectTeam(team) }
                }
            }
        }
    }

    // MARK: - Today Section
    var todaySection: some View {
        VStack(alignment: .leading, spacing: NSpacing.md) {
            PremiumSectionHeader(
                title: "Bugün Görevde",
                subtitle: "\(vm.todayMembersWorking.count) kişi"
            )

            if vm.todayMembersWorking.isEmpty {
                HStack(spacing: NSpacing.md) {
                    Soft3DIcon(icon: "moon.zzz.fill", size: .small, color: NColor.textTertiary)
                    Text("Bugün nöbette kimse yok")
                        .font(NFont.subheadline())
                        .foregroundStyle(NColor.textSecondary)
                }
                .premiumGlass(radius: NRadius.medium, padding: NSpacing.base)
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: NSpacing.md) {
                        ForEach(vm.todayMembersWorking) { member in
                            PremiumMemberAvatarCard(member: member)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Members Section
    func membersSection(_ team: Team) -> some View {
        VStack(alignment: .leading, spacing: NSpacing.md) {
            PremiumSectionHeader(
                title: "Ekip Üyeleri",
                subtitle: "\(team.memberCount) üye"
            )

            VStack(spacing: 0) {
                ForEach(team.members) { member in
                    PremiumMemberRow(member: member)
                    if member.id != team.members.last?.id {
                        Divider()
                            .padding(.horizontal, NSpacing.base)
                            .opacity(0.4)
                    }
                }
            }
            .premiumGlass(radius: NRadius.large, padding: 0)
        }
    }

    // MARK: - Announcements Section
    var announcementsSection: some View {
        VStack(alignment: .leading, spacing: NSpacing.md) {
            PremiumSectionHeader(title: "Duyurular")

            if vm.announcements.isEmpty {
                HStack(spacing: NSpacing.md) {
                    Soft3DIcon(icon: "megaphone", size: .small, color: NColor.textTertiary)
                    Text("Henüz duyuru yok")
                        .font(NFont.subheadline())
                        .foregroundStyle(NColor.textSecondary)
                }
                .premiumGlass(radius: NRadius.medium, padding: NSpacing.base)
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ForEach(vm.announcements) { announcement in
                    PremiumAnnouncementRow(announcement: announcement)
                }
            }
        }
    }

    // MARK: - Swap Requests
    var swapRequestsSection: some View {
        VStack(alignment: .leading, spacing: NSpacing.md) {
            PremiumSectionHeader(title: "Takas İstekleri")
            ForEach(vm.swapRequests) { request in
                PremiumSwapRequestRow(request: request) { status in
                    vm.respondToSwap(id: request.id, status: status)
                }
            }
        }
    }

    // MARK: - Create Team Sheet
    var createTeamSheet: some View {
        NavigationStack {
            VStack(spacing: NSpacing.lg) {
                PremiumFormField(label: "Ekip Adı", isRequired: true) {
                    NoveraTextField(placeholder: "Örn: Acil Servis Ekibi", text: $vm.newTeamName, icon: "person.2")
                }
                PremiumFormField(label: "Açıklama") {
                    NoveraTextField(placeholder: "Ekip açıklaması", text: $vm.newTeamDescription, icon: "text.alignleft")
                }
                PremiumPrimaryButton(title: "Ekip Oluştur", icon: "checkmark") { vm.createTeam() }
            }
            .padding(NSpacing.lg)
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
            VStack(spacing: NSpacing.lg) {
                PremiumFormField(label: "Davet Kodu", isRequired: true) {
                    NoveraTextField(placeholder: "6 haneli kod (örn: ABC123)", text: $vm.inviteCode, icon: "link")
                }
                if let error = vm.errorMessage {
                    Text(error)
                        .font(NFont.subheadline())
                        .foregroundStyle(NColor.danger)
                }
                PremiumPrimaryButton(title: "Katıl", icon: "arrow.right") { vm.joinTeam() }
            }
            .padding(NSpacing.lg)
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
            VStack(spacing: NSpacing.lg) {
                PremiumFormField(label: "Başlık", isRequired: true) {
                    NoveraTextField(placeholder: "Duyuru başlığı", text: $vm.announcementTitle, icon: "megaphone")
                }
                PremiumFormField(label: "Mesaj") {
                    NoveraTextField(placeholder: "Duyuru içeriği...", text: $vm.announcementMessage, icon: "text.alignleft")
                }
                PremiumPrimaryButton(title: "Duyuru Yap", icon: "megaphone.fill") {
                    vm.postAnnouncement()
                    showPostAnnouncement = false
                }
            }
            .padding(NSpacing.lg)
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

// MARK: - Premium Team Chip
struct PremiumTeamChip: View {
    let team: Team
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: {
            HapticManager.selection()
            action()
        }) {
            Text(team.name)
                .font(NFont.subheadline(.semibold))
                .foregroundStyle(isSelected ? .white : NColor.primaryFallback)
                .padding(.horizontal, NSpacing.lg)
                .padding(.vertical, NSpacing.md)
                .background(
                    Capsule()
                        .fill(isSelected ? AnyShapeStyle(NColor.primaryGradient) : AnyShapeStyle(Color.clear))
                        .overlay(
                            Capsule()
                                .strokeBorder(
                                    isSelected
                                    ? .clear
                                    : NColor.primaryFallback.opacity(0.3),
                                    lineWidth: 1
                                )
                        )
                )
                .shadow(
                    color: isSelected ? NColor.primaryFallback.opacity(0.3) : .clear,
                    radius: 8, x: 0, y: 4
                )
        }
        .pressEffect()
    }
}

// MARK: - Premium Member Avatar Card
struct PremiumMemberAvatarCard: View {
    let member: TeamMember
    @State private var showGlow = false

    var body: some View {
        VStack(spacing: NSpacing.sm) {
            ZStack {
                // Glow
                Circle()
                    .fill(NColor.primaryFallback.opacity(showGlow ? 0.15 : 0))
                    .frame(width: 64, height: 64)
                    .blur(radius: 8)

                Circle()
                    .fill(NColor.primaryGradient)
                    .frame(width: 56, height: 56)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.4), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .nShadow(.soft)

                Text(member.name.prefix(2).uppercased())
                    .font(NFont.headline(.bold))
                    .foregroundStyle(.white)
            }

            Text(member.name.components(separatedBy: " ").first ?? "")
                .font(NFont.caption(.medium))
                .foregroundStyle(NColor.textPrimary)
                .lineLimit(1)
        }
        .frame(width: 72)
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                showGlow = true
            }
        }
    }
}

// MARK: - Premium Member Row
struct PremiumMemberRow: View {
    let member: TeamMember

    var body: some View {
        HStack(spacing: NSpacing.md) {
            ZStack {
                Circle()
                    .fill(NColor.primaryGradient)
                    .frame(width: 42, height: 42)
                    .overlay(
                        Circle()
                            .stroke(.white.opacity(0.2), lineWidth: 0.5)
                    )
                Text(member.name.prefix(2).uppercased())
                    .font(NFont.footnote(.bold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(member.name)
                    .font(NFont.subheadline(.semibold))
                    .foregroundStyle(NColor.textPrimary)
                Text(member.profession.displayName)
                    .font(NFont.caption())
                    .foregroundStyle(NColor.textSecondary)
            }

            Spacer()

            // Role badge
            HStack(spacing: 4) {
                Image(systemName: member.role.icon)
                    .font(.system(size: 11, weight: .bold))
                Text(member.role.displayName)
                    .font(NFont.caption2(.bold))
            }
            .foregroundStyle(member.role.color)
            .padding(.horizontal, NSpacing.sm)
            .padding(.vertical, NSpacing.xs)
            .background(
                Capsule()
                    .fill(member.role.color.opacity(0.12))
                    .overlay(Capsule().stroke(member.role.color.opacity(0.2), lineWidth: 0.5))
            )
        }
        .padding(.horizontal, NSpacing.base)
        .padding(.vertical, NSpacing.md)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(member.name), \(member.profession.displayName), \(member.role.displayName)")
    }
}

// MARK: - Premium Swap Request Row
struct PremiumSwapRequestRow: View {
    let request: ShiftSwapRequest
    let respond: (SwapStatus) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: NSpacing.md) {
            HStack {
                Soft3DIcon(icon: "arrow.left.arrow.right", size: .small, color: NColor.primaryFallback)

                VStack(alignment: .leading, spacing: 2) {
                    Text(request.requestedByName)
                        .font(NFont.subheadline(.semibold))
                        .foregroundStyle(NColor.textPrimary)
                    Text(request.message)
                        .font(NFont.caption())
                        .foregroundStyle(NColor.textSecondary)
                        .lineLimit(2)
                }
                Spacer()
                PremiumSwapBadge(status: request.status)
            }

            if request.status == .pending {
                HStack(spacing: NSpacing.md) {
                    Button(action: {
                        HapticManager.notification(.success)
                        respond(.accepted)
                    }) {
                        Text("Kabul Et")
                            .font(NFont.subheadline(.semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(
                                Capsule()
                                    .fill(NColor.success)
                                    .shadow(color: NColor.success.opacity(0.3), radius: 6, x: 0, y: 3)
                            )
                    }

                    Button(action: {
                        HapticManager.notification(.warning)
                        respond(.rejected)
                    }) {
                        Text("Reddet")
                            .font(NFont.subheadline(.semibold))
                            .foregroundStyle(NColor.danger)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(
                                Capsule()
                                    .fill(NColor.danger.opacity(0.12))
                                    .overlay(Capsule().stroke(NColor.danger.opacity(0.3), lineWidth: 0.8))
                            )
                    }
                }
            }
        }
        .premiumGlass(radius: NRadius.medium, padding: NSpacing.base)
    }
}

// MARK: - Premium Swap Badge
struct PremiumSwapBadge: View {
    let status: SwapStatus

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.icon)
                .font(.system(size: 10, weight: .bold))
            Text(status.displayName)
                .font(NFont.caption2(.bold))
        }
        .foregroundStyle(status.color)
        .padding(.horizontal, NSpacing.sm)
        .padding(.vertical, NSpacing.xs)
        .background(
            Capsule()
                .fill(status.color.opacity(0.12))
                .overlay(Capsule().stroke(status.color.opacity(0.2), lineWidth: 0.5))
        )
    }
}

// Legacy aliases
typealias TeamChip = PremiumTeamChip
typealias MemberAvatarCard = PremiumMemberAvatarCard
typealias MemberRow = PremiumMemberRow
typealias SwapRequestRow = PremiumSwapRequestRow
typealias SwapStatusBadge = PremiumSwapBadge

#Preview("Teams - Light") {
    TeamsView()
        .environmentObject(AppState())
}

#Preview("Teams - Dark") {
    TeamsView()
        .environmentObject(AppState())
        .preferredColorScheme(.dark)
}
