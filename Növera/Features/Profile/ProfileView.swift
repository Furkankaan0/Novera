// ProfileView.swift
// Növera — Premium User Profile & Settings

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var appState: AppState
    @State private var showEditProfile = false
    @State private var showPremium = false
    @State private var showNotifications = false

    var user: User? { authService.currentUser }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: NSpacing.xl) {
                    // Premium avatar header
                    premiumProfileHeader
                        .entrance(delay: 0)

                    // Premium banner
                    if !appState.isPremiumUser {
                        premiumBanner
                            .padding(.horizontal, NSpacing.base)
                            .entrance(delay: 0.05)
                    }

                    // Settings
                    premiumSettings
                        .padding(.horizontal, NSpacing.base)
                        .entrance(delay: 0.10)

                    // App info
                    premiumAppInfo
                        .padding(.horizontal, NSpacing.base)
                        .entrance(delay: 0.15)

                    Spacer(minLength: 120)
                }
            }
            .screenBackground()
            .navigationBarHidden(true)
            .sheet(isPresented: $showEditProfile) {
                EditProfileView()
                    .environmentObject(authService)
            }
            .sheet(isPresented: $showPremium) {
                PremiumView()
            }
            .sheet(isPresented: $showNotifications) {
                NotificationsView()
                    .environmentObject(NotificationService.shared)
            }
        }
    }

    // MARK: - Profile Header
    var premiumProfileHeader: some View {
        VStack(spacing: NSpacing.lg) {
            ZStack(alignment: .bottom) {
                // Background gradient
                RoundedRectangle(cornerRadius: 0, style: .continuous)
                    .fill(NColor.primaryGradient)
                    .frame(height: 150)
                    .overlay(
                        LinearGradient(
                            colors: [.clear, NColor.background.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .ignoresSafeArea(edges: .top)

                // Avatar
                ZStack {
                    Circle()
                        .fill(NColor.background)
                        .frame(width: 96, height: 96)
                        .nShadow(.floating)

                    Circle()
                        .fill(NColor.primaryGradient)
                        .frame(width: 86, height: 86)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [.white.opacity(0.4), .clear],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )

                    Text(user?.initials ?? "?")
                        .font(NFont.display(30, .bold))
                        .foregroundStyle(.white)
                }
                .offset(y: 36)
            }
            .frame(height: 150)

            Spacer(minLength: 28)

            VStack(spacing: NSpacing.xs) {
                Text(user?.name ?? "Kullanıcı")
                    .font(NFont.title2(.bold))
                    .foregroundStyle(NColor.textPrimary)
                Text(user?.profession.displayName ?? "")
                    .font(NFont.callout(.medium))
                    .foregroundStyle(NColor.textSecondary)
                if let dept = user?.department, !dept.isEmpty {
                    Text(dept)
                        .font(NFont.subheadline())
                        .foregroundStyle(NColor.textTertiary)
                }
            }

            PremiumSecondaryButton(title: "Profili Düzenle", icon: "pencil") {
                showEditProfile = true
            }
            .frame(maxWidth: 200)
        }
    }

    // MARK: - Premium Banner
    var premiumBanner: some View {
        Button(action: { showPremium = true }) {
            HStack(spacing: NSpacing.md) {
                Soft3DIcon(icon: "star.fill", size: .medium, color: NColor.accent)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Növera Pro'yu Keşfet")
                        .font(NFont.headline(.bold))
                        .foregroundStyle(NColor.textPrimary)
                    Text("Sınırsız vardiya, ekip yönetimi ve daha fazlası")
                        .font(NFont.caption())
                        .foregroundStyle(NColor.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(NColor.textTertiary)
            }
            .premiumGlass(radius: NRadius.large, padding: NSpacing.base)
            .overlay(
                RoundedRectangle(cornerRadius: NRadius.large, style: .continuous)
                    .strokeBorder(NColor.accent.opacity(0.25), lineWidth: 1)
            )
        }
        .pressEffect()
    }

    // MARK: - Settings Sections
    var premiumSettings: some View {
        VStack(spacing: NSpacing.lg) {
            PremiumSettingsSection(title: "Uygulama") {
                PremiumSettingsRow(icon: "bell.fill", color: NColor.shiftOncall, title: "Bildirimler") {
                    showNotifications = true
                }
                PremiumSettingsRow(icon: "moon.fill", color: NColor.shiftNight, title: "Görünüm") {}
                PremiumSettingsRow(icon: "globe", color: NColor.primaryFallback, title: "Dil") {}
            }

            PremiumSettingsSection(title: "Hesap") {
                PremiumSettingsRow(icon: "person.fill", color: NColor.accent, title: "Profili Düzenle") {
                    showEditProfile = true
                }
                PremiumSettingsRow(icon: "lock.fill", color: NColor.textSecondary, title: "Gizlilik ve Güvenlik") {}
                PremiumSettingsRow(icon: "rectangle.portrait.and.arrow.right", color: NColor.danger, title: "Çıkış Yap", isDestructive: true) {
                    authService.signOut()
                    appState.hasCompletedOnboarding = false
                }
            }

            PremiumSettingsSection(title: "Destek") {
                PremiumSettingsRow(icon: "questionmark.circle.fill", color: NColor.info, title: "Yardım Merkezi") {}
                PremiumSettingsRow(icon: "envelope.fill", color: NColor.primaryFallback, title: "Bize Ulaşın") {}
                PremiumSettingsRow(icon: "star.fill", color: NColor.warning, title: "Uygulamayı Puanla") {}
            }
        }
    }

    // MARK: - App Info
    var premiumAppInfo: some View {
        VStack(spacing: 4) {
            Text("Növera")
                .font(NFont.headline(.semibold))
                .foregroundStyle(NColor.textTertiary)
            Text("v\(NoveraConstants.appVersion) (\(NoveraConstants.buildNumber))")
                .font(NFont.caption())
                .foregroundStyle(NColor.textTertiary)
            Text("© 2024 Növera. Tüm hakları saklıdır.")
                .font(NFont.caption())
                .foregroundStyle(NColor.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(NSpacing.base)
    }
}

// MARK: - Premium Settings Section
struct PremiumSettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: NSpacing.sm) {
            Text(title.uppercased())
                .font(NFont.caption(.bold))
                .foregroundStyle(NColor.textTertiary)
                .padding(.horizontal, NSpacing.sm)

            VStack(spacing: 0) {
                content()
            }
            .premiumGlass(radius: NRadius.large, padding: 0)
        }
    }
}

// MARK: - Premium Settings Row
struct PremiumSettingsRow: View {
    let icon: String
    let color: Color
    let title: String
    var isDestructive: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.selection()
            action()
        }) {
            HStack(spacing: NSpacing.md) {
                Soft3DIcon(icon: icon, size: .small, color: isDestructive ? NColor.danger : color)

                Text(title)
                    .font(NFont.callout(.medium))
                    .foregroundStyle(isDestructive ? NColor.danger : NColor.textPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(NColor.textTertiary)
            }
            .padding(.horizontal, NSpacing.base)
            .padding(.vertical, NSpacing.md)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}

// MARK: - Settings View (backward compat)
struct SettingsView: View {
    var body: some View {
        ProfileView()
    }
}

// MARK: - Edit Profile View (Stub)
struct EditProfileView: View {
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismiss) var dismiss

    @State private var name: String = ""
    @State private var department: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: NSpacing.lg) {
                    PremiumFormField(label: "Ad Soyad", isRequired: true) {
                        NoveraTextField(placeholder: "Adınız", text: $name, icon: "person")
                    }
                    PremiumFormField(label: "Departman") {
                        NoveraTextField(placeholder: "Departmanınız", text: $department, icon: "building.2")
                    }
                    PremiumPrimaryButton(title: "Kaydet", icon: "checkmark") {
                        // TODO: Save profile
                        HapticManager.notification(.success)
                        dismiss()
                    }
                }
                .padding(NSpacing.base)
            }
            .screenBackground()
            .navigationTitle("Profili Düzenle")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                }
            }
            .onAppear {
                name = authService.currentUser?.name ?? ""
                department = authService.currentUser?.department ?? ""
            }
        }
    }
}

#Preview("Profile - Light") {
    ProfileView()
        .environmentObject(AuthService())
        .environmentObject(AppState())
}

#Preview("Profile - Dark") {
    ProfileView()
        .environmentObject(AuthService())
        .environmentObject(AppState())
        .preferredColorScheme(.dark)
}
