// NotificationsView.swift
// Növera — Notifications & Permission Screen

import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject var notificationService: NotificationService
    @State private var pendingCount: Int = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: NoveraSpacing.lg) {
                    if notificationService.isAuthorized {
                        authorizedState
                    } else {
                        permissionRequest
                    }
                }
                .padding(NoveraSpacing.md)
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Bildirimler")
            .navigationBarTitleDisplayMode(.large)
            .onAppear { notificationService.checkStatus() }
        }
    }

    // MARK: - Permission Request
    var permissionRequest: some View {
        VStack(spacing: NoveraSpacing.xl) {
            Spacer(minLength: 40)

            ZStack {
                Circle()
                    .fill(NoveraColors.primary.opacity(0.08))
                    .frame(width: 140, height: 140)
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 60, weight: .light))
                    .foregroundStyle(NoveraColors.primaryGradient)
                    .symbolRenderingMode(.hierarchical)
            }

            VStack(spacing: NoveraSpacing.sm) {
                Text("Bildirimlerinizi açın")
                    .font(NoveraFonts.title1(.bold))
                    .multilineTextAlignment(.center)

                Text("Yaklaşan nöbetler, ekip duyuruları ve takas istekleri için zamanında bildirimler alın.")
                    .font(NoveraFonts.callout())
                    .foregroundStyle(NoveraColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, NoveraSpacing.md)
            }

            VStack(spacing: NoveraSpacing.md) {
                NotificationFeatureRow(
                    icon: "clock.fill",
                    title: "Nöbet Hatırlatmaları",
                    subtitle: "1 saat öncesinden bildirim",
                    color: NoveraColors.primary
                )
                NotificationFeatureRow(
                    icon: "megaphone.fill",
                    title: "Ekip Duyuruları",
                    subtitle: "Ekibinizdeki yeni paylaşımlar",
                    color: NoveraColors.accent
                )
                NotificationFeatureRow(
                    icon: "arrow.left.arrow.right",
                    title: "Takas İstekleri",
                    subtitle: "Nöbet değişim talepleri",
                    color: NoveraColors.shiftOncall
                )
            }

            NoveraPrimaryButton("Bildirimlere İzin Ver", icon: "bell.fill") {
                notificationService.requestAuthorization()
            }

            NoveraGhostButton("Şimdi değil") {}
        }
    }

    // MARK: - Authorized State
    var authorizedState: some View {
        VStack(spacing: NoveraSpacing.md) {
            // Status card
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(NoveraColors.success)
                    .font(.system(size: 20))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Bildirimler Aktif")
                        .font(NoveraFonts.headline(.semibold))
                    Text("Tüm bildirimler etkin")
                        .font(NoveraFonts.caption())
                        .foregroundStyle(NoveraColors.textSecondary)
                }
                Spacer()
            }
            .padding(NoveraSpacing.md)
            .glassBackground(cornerRadius: NoveraRadius.md)
            .noveraShadow(NoveraShadows.soft)

            NoveraEmptyState(
                icon: "bell.slash",
                title: "Bildirim geçmişi",
                subtitle: "Geçmiş bildirimler burada görünecek"
            )
        }
    }
}

// MARK: - Feature Row
struct NotificationFeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        HStack(spacing: NoveraSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(color.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(NoveraFonts.headline(.medium))
                Text(subtitle)
                    .font(NoveraFonts.subheadline())
                    .foregroundStyle(NoveraColors.textSecondary)
            }
            Spacer()
        }
        .padding(NoveraSpacing.md)
        .glassBackground(cornerRadius: NoveraRadius.md)
        .noveraShadow(NoveraShadows.soft)
    }
}

#Preview {
    NotificationsView()
        .environmentObject(NotificationService.shared)
}
