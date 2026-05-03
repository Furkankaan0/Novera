// ProfileView.swift
// Növera — User Profile & Settings

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
                VStack(spacing: NoveraSpacing.lg) {
                    // Avatar & name
                    profileHeader

                    // Premium banner
                    if !appState.isPremiumUser {
                        premiumBanner
                            .padding(.horizontal, NoveraSpacing.md)
                    }

                    // Settings sections
                    settingsSections
                        .padding(.horizontal, NoveraSpacing.md)

                    // App info
                    appInfo
                        .padding(.horizontal, NoveraSpacing.md)

                    Spacer(minLength: 100)
                }
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
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
    var profileHeader: some View {
        VStack(spacing: NoveraSpacing.md) {
            // Background gradient
            ZStack(alignment: .bottom) {
                Rectangle()
                    .fill(NoveraColors.primaryGradient)
                    .frame(height: 140)
                    .ignoresSafeArea(edges: .top)

                VStack(spacing: NoveraSpacing.sm) {
                    ZStack {
                        Circle()
                            .fill(.white)
                            .frame(width: 90, height: 90)
                        Circle()
                            .fill(NoveraColors.primaryGradient)
                            .frame(width: 82, height: 82)
                        Text(user?.initials ?? "?")
                            .font(NoveraFonts.display(28, .bold))
                            .foregroundStyle(.white)
                    }
                    .noveraShadow(NoveraShadows.primary)
                    .offset(y: 30)
                }
            }
            .frame(height: 140)

            Spacer(minLength: 20)

            VStack(spacing: NoveraSpacing.xs) {
                Text(user?.name ?? "Kullanıcı")
                    .font(NoveraFonts.title2(.bold))
                Text(user?.profession.displayName ?? "")
                    .font(NoveraFonts.callout())
                    .foregroundStyle(NoveraColors.textSecondary)
                if let dept = user?.department, !dept.isEmpty {
                    Text(dept)
                        .font(NoveraFonts.subheadline())
                        .foregroundStyle(NoveraColors.textTertiary)
                }
            }

            Button(action: { showEditProfile = true }) {
                Label("Profili Düzenle", systemImage: "pencil")
                    .font(NoveraFonts.subheadline(.medium))
                    .foregroundStyle(NoveraColors.primary)
                    .padding(.horizontal, NoveraSpacing.md)
                    .padding(.vertical, NoveraSpacing.sm)
                    .background(Capsule().fill(NoveraColors.primary.opacity(0.1)))
            }
        }
    }

    // MARK: - Premium Banner
    var premiumBanner: some View {
        Button(action: { showPremium = true }) {
            HStack(spacing: NoveraSpacing.md) {
                Image(systemName: "star.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(NoveraColors.accentGradient)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Növera Pro'yu Keşfet")
                        .font(NoveraFonts.headline(.bold))
                    Text("Sınırsız vardiya, ekip yönetimi ve daha fazlası")
                        .font(NoveraFonts.caption())
                        .foregroundStyle(NoveraColors.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(NoveraColors.textTertiary)
            }
            .padding(NoveraSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: NoveraRadius.lg, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hue: 0.72, saturation: 0.12, brightness: 0.98),
                                Color(hue: 0.55, saturation: 0.08, brightness: 0.97)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: NoveraRadius.lg, style: .continuous)
                            .strokeBorder(NoveraColors.accent.opacity(0.2), lineWidth: 1)
                    )
            )
            .noveraShadow(NoveraShadows.soft)
        }
        .scaleOnPress()
    }

    // MARK: - Settings Sections
    var settingsSections: some View {
        VStack(spacing: NoveraSpacing.md) {
            SettingsSection(title: "Uygulama") {
                SettingsRow(icon: "bell.fill", color: NoveraColors.shiftOncall, title: "Bildirimler") {
                    showNotifications = true
                }
                SettingsRow(icon: "moon.fill", color: NoveraColors.shiftNight, title: "Görünüm") {
                    // TODO: Theme picker
                }
                SettingsRow(icon: "globe", color: NoveraColors.primary, title: "Dil") {
                    // TODO: Language picker
                }
            }

            SettingsSection(title: "Hesap") {
                SettingsRow(icon: "person.fill", color: NoveraColors.accent, title: "Profili Düzenle") {
                    showEditProfile = true
                }
                SettingsRow(icon: "lock.fill", color: NoveraColors.textSecondary, title: "Gizlilik ve Güvenlik") {}
                SettingsRow(icon: "rectangle.portrait.and.arrow.right", color: NoveraColors.error, title: "Çıkış Yap", isDestructive: true) {
                    authService.signOut()
                    appState.hasCompletedOnboarding = false
                }
            }

            SettingsSection(title: "Destek") {
                SettingsRow(icon: "questionmark.circle.fill", color: NoveraColors.info, title: "Yardım Merkezi") {}
                SettingsRow(icon: "envelope.fill", color: NoveraColors.primary, title: "Bize Ulaşın") {}
                SettingsRow(icon: "star.fill", color: NoveraColors.warning, title: "Uygulamayı Puanla") {}
            }
        }
    }

    // MARK: - App Info
    var appInfo: some View {
        VStack(spacing: 4) {
            Text("Növera")
                .font(NoveraFonts.headline(.semibold))
                .foregroundStyle(NoveraColors.textTertiary)
            Text("v\(NoveraConstants.appVersion) (\(NoveraConstants.buildNumber))")
                .font(NoveraFonts.caption())
                .foregroundStyle(NoveraColors.textTertiary)
            Text("© 2024 Növera. Tüm hakları saklıdır.")
                .font(NoveraFonts.caption())
                .foregroundStyle(NoveraColors.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(NoveraSpacing.md)
    }
}

// MARK: - Settings Section
struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: NoveraSpacing.xs) {
            Text(title.uppercased())
                .font(NoveraFonts.caption(.semibold))
                .foregroundStyle(NoveraColors.textTertiary)
                .padding(.horizontal, NoveraSpacing.sm)

            VStack(spacing: 0) {
                content()
            }
            .glassBackground(cornerRadius: NoveraRadius.lg)
            .noveraShadow(NoveraShadows.soft)
        }
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
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
            HStack(spacing: NoveraSpacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(color.opacity(0.12))
                        .frame(width: 32, height: 32)
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(color)
                }

                Text(title)
                    .font(NoveraFonts.callout())
                    .foregroundStyle(isDestructive ? NoveraColors.error : NoveraColors.textPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(NoveraColors.textTertiary)
            }
            .padding(.horizontal, NoveraSpacing.md)
            .padding(.vertical, NoveraSpacing.sm)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(title)
    }
}

// MARK: - Edit Profile View
struct EditProfileView: View {
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismiss) var dismiss
    @State private var name: String = ""
    @State private var department: String = ""
    @State private var profession: Profession = .nurse
    @State private var hourlyRate: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: NoveraSpacing.md) {
                    NoveraFormField(label: "Ad Soyad", isRequired: true) {
                        NoveraTextField(placeholder: "Adınız ve soyadınız", text: $name, icon: "person")
                    }
                    NoveraFormField(label: "Bölüm") {
                        NoveraTextField(placeholder: "Örn: Acil Servis", text: $department, icon: "building.2")
                    }
                    NoveraFormField(label: "Meslek") {
                        Picker("Meslek", selection: $profession) {
                            ForEach(Profession.allCases, id: \.self) { p in
                                Label(p.displayName, systemImage: p.icon).tag(p)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(.horizontal, NoveraSpacing.md)
                        .frame(height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: NoveraRadius.sm, style: .continuous)
                                .fill(Color(UIColor.tertiarySystemGroupedBackground))
                        )
                    }
                    NoveraFormField(label: "Saatlik Ücret (₺)") {
                        NoveraTextField(
                            placeholder: "Örn: 150",
                            text: $hourlyRate,
                            icon: "turkishlirasign",
                            keyboardType: .decimalPad
                        )
                    }
                    NoveraPrimaryButton("Kaydet", icon: "checkmark") {
                        authService.updateProfile(
                            name: name,
                            profession: profession,
                            department: department,
                            hourlyRate: Double(hourlyRate)
                        )
                        dismiss()
                    }
                }
                .padding(NoveraSpacing.md)
            }
            .navigationTitle("Profili Düzenle")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                }
            }
            .onAppear {
                if let user = authService.currentUser {
                    name = user.name
                    department = user.department
                    profession = user.profession
                    hourlyRate = user.hourlyRate.map { String(Int($0)) } ?? ""
                }
            }
        }
    }
}

// MARK: - Settings View (Tab placeholder)
struct SettingsView: View {
    var body: some View {
        ProfileView()
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthService())
        .environmentObject(AppState())
}
