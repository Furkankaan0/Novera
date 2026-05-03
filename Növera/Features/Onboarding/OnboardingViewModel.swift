// OnboardingViewModel.swift
// Növera — Onboarding ViewModel

import SwiftUI
import Combine

final class OnboardingViewModel: ObservableObject {
    @Published var currentPage: Int = 0
    @Published var animateHero: Bool = false
    @Published var showGetStarted: Bool = false

    let pages: [OnboardingPage] = OnboardingPage.all

    var isLastPage: Bool {
        currentPage == pages.count - 1
    }

    var progress: Double {
        Double(currentPage + 1) / Double(pages.count)
    }

    func goNext() {
        guard !isLastPage else { return }
        withAnimation(NoveraAnimation.pageTransition) {
            currentPage += 1
        }
        HapticManager.selection()
    }

    func goBack() {
        guard currentPage > 0 else { return }
        withAnimation(NoveraAnimation.pageTransition) {
            currentPage -= 1
        }
        HapticManager.selection()
    }

    func goTo(page: Int) {
        guard page >= 0 && page < pages.count else { return }
        withAnimation(NoveraAnimation.pageTransition) {
            currentPage = page
        }
    }

    func onAppear() {
        withAnimation(NoveraAnimation.spring.delay(0.3)) {
            animateHero = true
        }
        withAnimation(NoveraAnimation.spring.delay(0.6)) {
            showGetStarted = true
        }
    }
}

// MARK: - Onboarding Page Model
struct OnboardingPage: Identifiable {
    let id: Int
    let icon: String
    let iconColors: [Color]
    let title: String
    let subtitle: String
    let gradientColors: [Color]
    let accentColor: Color

    static let all: [OnboardingPage] = [
        OnboardingPage(
            id: 0,
            icon: "moon.stars.fill",
            iconColors: [NoveraColors.primary, Color(hue: 0.62, saturation: 0.72, brightness: 0.85)],
            title: "Nöbetlerini\ntek bakışta yönet",
            subtitle: "Tüm vardiyalarını, nöbetlerini ve çalışma saatlerini tek ekranda görüntüle. Karmaşık çizelgelere son.",
            gradientColors: [
                Color(hue: 0.55, saturation: 0.75, brightness: 0.30),
                Color(hue: 0.62, saturation: 0.80, brightness: 0.15)
            ],
            accentColor: NoveraColors.primary
        ),
        OnboardingPage(
            id: 1,
            icon: "person.2.wave.2.fill",
            iconColors: [NoveraColors.accent, Color(hue: 0.78, saturation: 0.60, brightness: 0.85)],
            title: "Ekip durumunu\nanlık takip et",
            subtitle: "Kimin ne zaman çalıştığını görün, ekip duyurularını alın ve nöbet değişim taleplerini yönetin.",
            gradientColors: [
                Color(hue: 0.70, saturation: 0.70, brightness: 0.28),
                Color(hue: 0.78, saturation: 0.75, brightness: 0.15)
            ],
            accentColor: NoveraColors.accent
        ),
        OnboardingPage(
            id: 2,
            icon: "chart.bar.xaxis.ascending.badge.clock",
            iconColors: [NoveraColors.accentGreen, Color(hue: 0.48, saturation: 0.70, brightness: 0.80)],
            title: "Mesai ve gelir\nhesaplarını kontrol et",
            subtitle: "Normal saatler, fazla mesai, gece zammı ve resmi tatil ödemelerini otomatik hesapla.",
            gradientColors: [
                Color(hue: 0.40, saturation: 0.70, brightness: 0.25),
                Color(hue: 0.48, saturation: 0.75, brightness: 0.12)
            ],
            accentColor: NoveraColors.accentGreen
        ),
        OnboardingPage(
            id: 3,
            icon: "bell.badge.fill",
            iconColors: [NoveraColors.shiftOncall, Color(hue: 0.12, saturation: 0.80, brightness: 0.90)],
            title: "Hatırlatmalar\nve akıllı uyarılar",
            subtitle: "Yaklaşan nöbetleriniz için zamanında hatırlatmalar, ekip bildirimleri ve değişiklik uyarıları alın.",
            gradientColors: [
                Color(hue: 0.08, saturation: 0.75, brightness: 0.28),
                Color(hue: 0.12, saturation: 0.80, brightness: 0.15)
            ],
            accentColor: NoveraColors.shiftOncall
        ),
        OnboardingPage(
            id: 4,
            icon: "star.square.on.square.fill",
            iconColors: [Color(hue: 0.82, saturation: 0.70, brightness: 0.92), NoveraColors.primary],
            title: "Növera Pro ile\nprofesyonel deneyim",
            subtitle: "Sınırsız vardiya, gelişmiş analizler, ekip yönetimi, widget ve çok daha fazlası Pro ile açılır.",
            gradientColors: [
                Color(hue: 0.78, saturation: 0.65, brightness: 0.28),
                Color(hue: 0.55, saturation: 0.75, brightness: 0.15)
            ],
            accentColor: Color(hue: 0.82, saturation: 0.70, brightness: 0.92)
        )
    ]
}
