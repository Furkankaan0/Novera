import AuthenticationServices
import SwiftUI

struct OnboardingView: View {
    @ObservedObject var appState: AppState
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var page = 0

    private let pages: [OnboardingPageModel] = [
        .init(title: "Nöbet düzenini tek bakışta yönet", message: "Vardiya, izin, rapor ve ek mesailer tek premium çalışma takviminde birleşir.", accent: DesignColors.primary, symbol: "calendar.badge.clock"),
        .init(title: "Mesai yükünü gerçekten gör", message: "Fazla mesai, UBGT ve gece çalışmaları bilgilendirme amaçlı net özetlenir.", accent: DesignColors.accent, symbol: "chart.line.uptrend.xyaxis"),
        .init(title: "Ekibinle aynı ritimde kal", message: "Bugün kim çalışıyor, kim izinli ve ekip yoğunluğu nasıl, hızlıca fark edilir.", accent: DesignColors.secondary, symbol: "person.3.sequence.fill"),
        .init(title: "Hatırlatmalar hep hazır", message: "Nöbet yaklaşınca haber verir; widget altyapısı sıradaki vardiyayı göz önünde tutar.", accent: DesignColors.warning, symbol: "bell.badge.fill"),
        .init(title: "Nöbetim+ Premium ile tam kontrol", message: "Sınırsız nöbet, gelişmiş analiz, ekip yönetimi, akıllı içgörüler ve premium temalar açılır.", accent: DesignColors.cinematicViolet, symbol: "sparkles")
    ]

    var body: some View {
        ZStack {
            CinematicBackground(isAnimated: true)

            VStack(spacing: Spacing.large) {
                TabView(selection: $page) {
                    ForEach(pages.indices, id: \.self) { index in
                        OnboardingPageContent(model: pages[index], isFinal: index == pages.count - 1)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                VStack(spacing: Spacing.medium) {
                    pageIndicator

                    if page == pages.count - 1 {
                        finalPermissionStack
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    HStack(spacing: Spacing.medium) {
                        Button("Atla") {
                            appState.completeOnboarding()
                        }
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(minWidth: 86, minHeight: 52)
                        .accessibilityLabel("Onboarding'i atla")

                        PremiumCTAButton(
                            title: page == pages.count - 1 ? "Başla" : "Devam",
                            systemImage: page == pages.count - 1 ? "checkmark" : "arrow.right"
                        ) {
                            advance()
                        }
                    }
                }
                .padding(.horizontal, Spacing.large)
                .padding(.bottom, Spacing.large)
            }
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(pages.indices, id: \.self) { index in
                Capsule()
                    .fill(index == page ? pages[index].accent : Color.white.opacity(0.20))
                    .frame(width: index == page ? 28 : 8, height: 8)
                    .shadow(color: pages[index].accent.opacity(index == page ? 0.48 : 0), radius: 8)
            }
        }
        .animation(reduceMotion ? .default : .spring(response: 0.34, dampingFraction: 0.82), value: page)
        .accessibilityLabel("Onboarding ilerleme \(page + 1) / \(pages.count)")
    }

    private var finalPermissionStack: some View {
        PremiumGlassPanel(cornerRadius: 24) {
            VStack(spacing: Spacing.medium) {
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

                Button {
                    appState.requestNotifications()
                } label: {
                    HStack {
                        Image(systemName: "bell.badge.fill")
                            .font(.headline.weight(.bold))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Nöbet hatırlatmalarını aç")
                                .font(.subheadline.weight(.bold))
                            Text("İzin vermezsen de uygulama offline çalışır.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.secondary)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .frame(minHeight: 52)
                .accessibilityLabel("Bildirim izni ver")
            }
        }
        .padding(.horizontal, Spacing.large)
    }

    private func advance() {
        if page == pages.count - 1 {
            appState.completeOnboarding()
        } else {
            withAnimation(reduceMotion ? .default : .spring(response: 0.38, dampingFraction: 0.84)) {
                page += 1
            }
        }
    }
}

private struct OnboardingPageContent: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var entered = false
    var model: OnboardingPageModel
    var isFinal: Bool

    var body: some View {
        VStack(spacing: Spacing.xLarge) {
            Spacer(minLength: 12)

            BrandHeroMark(
                size: isFinal ? 236 : 220,
                showTitle: false
            )
            .scaleEffect(entered ? 1 : 0.94)
            .opacity(entered ? 1 : 0.0)

            PremiumGlassPanel(cornerRadius: 30) {
                VStack(alignment: .leading, spacing: Spacing.large) {
                    ShiftStatusCapsule(title: "Premium çalışma takibi", subtitle: model.symbolText, color: model.accent, systemImage: model.symbol)

                    VStack(alignment: .leading, spacing: Spacing.medium) {
                        Text(model.title)
                            .font(.system(.largeTitle, design: .rounded, weight: .black))
                            .lineLimit(3)
                            .minimumScaleFactor(0.70)

                        Text(model.message)
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    HStack(spacing: 10) {
                        MiniFeaturePill(text: "Offline-first", color: DesignColors.secondary)
                        MiniFeaturePill(text: "Akıllı özet", color: model.accent)
                    }
                }
            }
            .padding(.horizontal, Spacing.large)
            .offset(y: entered ? 0 : 18)
            .opacity(entered ? 1 : 0)

            Spacer(minLength: 16)
        }
        .onAppear {
            if reduceMotion {
                entered = true
            } else {
                withAnimation(.spring(response: 0.62, dampingFraction: 0.86).delay(0.06)) {
                    entered = true
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}

private struct MiniFeaturePill: View {
    var text: String
    var color: Color

    var body: some View {
        Text(text)
            .font(.caption.weight(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 11)
            .padding(.vertical, 7)
            .background(color.opacity(0.24), in: Capsule())
            .overlay(Capsule().stroke(color.opacity(0.56), lineWidth: 1))
    }
}

private struct OnboardingPageModel: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let accent: Color
    let symbol: String

    var symbolText: String {
        switch symbol {
        case "calendar.badge.clock": "Takvim"
        case "chart.line.uptrend.xyaxis": "Analiz"
        case "person.3.sequence.fill": "Ekip"
        case "bell.badge.fill": "Bildirim"
        default: "Premium"
        }
    }
}
