import AuthenticationServices
import SwiftUI

struct OnboardingView: View {
    @ObservedObject var appState: AppState
    @Environment(\.colorScheme) private var colorScheme
    @State private var page = 0

    private let pages = [
        ("Nöbetlerini akıllıca takip et", "Vardiya, izin, rapor ve ek mesailerini tek premium takvimde gör.", "calendar.badge.clock"),
        ("Mesai ve resmi tatil saatlerini gör", "Fazla mesai, UBGT ve gelir tahminlerini bilgilendirme amaçlı hesapla.", "chart.line.uptrend.xyaxis"),
        ("Ekibinle aynı takvimde buluş", "Bugün kim çalışıyor, kim izinli, ekip yoğunluğu nasıl, hızlıca takip et.", "person.3.sequence.fill"),
        ("Widget ve bildirimlerle hiçbir şeyi kaçırma", "Nöbet yaklaşınca hatırlat, iPhone ana ekranında sıradaki vardiyanı gör.", "bell.badge.fill"),
        ("Nöbetim+ Premium ile tam kontrol", "Sınırsız nöbet, gelişmiş analiz, widget, ekip ve premium temaları aç.", "sparkles")
    ]

    var body: some View {
        VStack(spacing: Spacing.large) {
            TabView(selection: $page) {
                ForEach(pages.indices, id: \.self) { index in
                    onboardingPage(pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            if page == pages.count - 1 {
                VStack(spacing: 12) {
                    SignInWithAppleButton(.signIn) { request in
                        appState.appleSignInManager.makeRequest(request)
                    } onCompletion: { result in
                        if case let .success(authorization) = result,
                           let profile = appState.appleSignInManager.handleAuthorization(authorization, currentProfile: appState.profile) {
                            appState.updateProfile(profile)
                        }
                    }
                    .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                    .frame(height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .accessibilityLabel("Apple ile Giriş Yap")

                    Button("Bildirim izni ver") {
                        appState.requestNotifications()
                    }
                    .buttonStyle(.bordered)
                    .frame(minHeight: 44)
                }
            }

            HStack {
                Button("Atla") {
                    appState.completeOnboarding()
                }
                .frame(minHeight: 44)

                Spacer()

                Button(page == pages.count - 1 ? "Başla" : "Devam") {
                    if page == pages.count - 1 {
                        appState.completeOnboarding()
                    } else {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                            page += 1
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(DesignColors.primary)
                .frame(minHeight: 44)
            }
            .padding(.horizontal, Spacing.large)
            .padding(.bottom, Spacing.large)
        }
        .background(AppBackground())
    }

    private func onboardingPage(_ item: (String, String, String)) -> some View {
        VStack(spacing: Spacing.xLarge) {
            Spacer()
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [DesignColors.primary.opacity(0.75), DesignColors.secondary.opacity(0.65), DesignColors.accent.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 168, height: 168)
                    .blur(radius: 0.5)
                Image(systemName: item.2)
                    .font(.system(size: 64, weight: .bold))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.18), radius: 12, y: 8)
            }
            .accessibilityHidden(true)

            VStack(spacing: Spacing.medium) {
                Text(item.0)
                    .font(Typography.hero)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.75)
                Text(item.1)
                    .font(Typography.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.large)
            }
            Spacer()
        }
        .padding(Spacing.large)
        .accessibilityElement(children: .combine)
    }
}
