// OnboardingView.swift
// Növera — Premium 5-Screen Onboarding

import SwiftUI

struct OnboardingView: View {
    @StateObject private var vm = OnboardingViewModel()
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authService: AuthService

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background gradient (animated per page)
                LinearGradient(
                    colors: vm.pages[vm.currentPage].gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .animation(NoveraAnimation.smooth, value: vm.currentPage)

                // Subtle orbs
                OrbsBackground()
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Skip button
                    HStack {
                        Spacer()
                        if !vm.isLastPage {
                            Button(action: completeOnboarding) {
                                Text("Atla")
                                    .font(NoveraFonts.callout(.medium))
                                    .foregroundStyle(.white.opacity(0.7))
                                    .padding(.horizontal, NoveraSpacing.md)
                                    .padding(.vertical, NoveraSpacing.sm)
                            }
                        }
                    }
                    .padding(.top, NoveraSpacing.sm)
                    .padding(.trailing, NoveraSpacing.md)

                    Spacer()

                    // Hero icon area
                    TabView(selection: $vm.currentPage) {
                        ForEach(vm.pages) { page in
                            OnboardingPageView(page: page, animate: vm.animateHero)
                                .tag(page.id)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(height: geo.size.height * 0.62)
                    .animation(NoveraAnimation.pageTransition, value: vm.currentPage)
                    .onChange(of: vm.currentPage) { _, _ in
                        HapticManager.selection()
                    }

                    Spacer()

                    // Bottom controls
                    VStack(spacing: NoveraSpacing.lg) {
                        // Page indicator
                        NoveraPageIndicator(
                            count: vm.pages.count,
                            currentIndex: vm.currentPage,
                            accentColor: vm.pages[vm.currentPage].accentColor
                        )

                        // Action buttons
                        if vm.isLastPage {
                            VStack(spacing: NoveraSpacing.sm) {
                                NoveraPrimaryButton("Başla", icon: "arrow.right") {
                                    completeOnboarding()
                                }
                                .opacity(vm.showGetStarted ? 1 : 0)
                                .offset(y: vm.showGetStarted ? 0 : 20)
                                .animation(NoveraAnimation.spring.delay(0.2), value: vm.showGetStarted)

                                NoveraSecondaryButton("Pro'yu Keşfet", icon: "star.fill") {
                                    completeOnboarding()
                                    // TODO: Show premium sheet after navigation
                                }
                                .opacity(vm.showGetStarted ? 1 : 0)
                                .offset(y: vm.showGetStarted ? 0 : 20)
                                .animation(NoveraAnimation.spring.delay(0.35), value: vm.showGetStarted)
                            }
                        } else {
                            NoveraPrimaryButton("Devam", icon: "arrow.right") {
                                vm.goNext()
                            }
                        }
                    }
                    .padding(.horizontal, NoveraSpacing.lg)
                    .padding(.bottom, NoveraSpacing.xl)
                }
            }
        }
        .onAppear { vm.onAppear() }
    }

    private func completeOnboarding() {
        HapticManager.notification(.success)
        withAnimation(NoveraAnimation.pageTransition) {
            appState.hasCompletedOnboarding = true
        }
    }
}

// MARK: - Single Page View
struct OnboardingPageView: View {
    let page: OnboardingPage
    let animate: Bool

    @State private var iconRotation: Double = -5
    @State private var iconFloat: CGFloat = 0

    var body: some View {
        VStack(spacing: NoveraSpacing.xl) {
            // 3D-feel icon card
            ZStack {
                // Outer glow
                Circle()
                    .fill(page.accentColor.opacity(0.12))
                    .frame(width: 180, height: 180)
                    .blur(radius: 20)

                // Glass card
                RoundedRectangle(cornerRadius: 36, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 36, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [.white.opacity(0.4), .white.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .frame(width: 140, height: 140)
                    .shadow(color: page.accentColor.opacity(0.3), radius: 30, x: 0, y: 10)

                // Icon with gradient
                Image(systemName: page.icon)
                    .font(.system(size: 56, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: page.iconColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .symbolRenderingMode(.hierarchical)
            }
            .offset(y: iconFloat)
            .rotation3DEffect(.degrees(iconRotation), axis: (x: 0, y: 1, z: 0))
            .scaleEffect(animate ? 1.0 : 0.7)
            .opacity(animate ? 1.0 : 0)
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 3.5).repeatForever(autoreverses: true)
                ) {
                    iconFloat = -10
                }
                withAnimation(
                    Animation.easeInOut(duration: 5).repeatForever(autoreverses: true).delay(0.5)
                ) {
                    iconRotation = 5
                }
            }

            // Text content
            VStack(spacing: NoveraSpacing.sm) {
                Text(page.title)
                    .font(NoveraFonts.largeTitle(.bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .scaleEffect(animate ? 1.0 : 0.9)
                    .opacity(animate ? 1.0 : 0)

                Text(page.subtitle)
                    .font(NoveraFonts.callout())
                    .foregroundStyle(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, NoveraSpacing.md)
                    .opacity(animate ? 1.0 : 0)
            }
        }
        .padding(.horizontal, NoveraSpacing.md)
    }
}

// MARK: - Page Indicator
struct NoveraPageIndicator: View {
    let count: Int
    let currentIndex: Int
    let accentColor: Color

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(index == currentIndex ? accentColor : .white.opacity(0.3))
                    .frame(width: index == currentIndex ? 24 : 8, height: 8)
                    .animation(NoveraAnimation.springFast, value: currentIndex)
            }
        }
    }
}

// MARK: - Orbs Background
struct OrbsBackground: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            Circle()
                .fill(.white.opacity(0.04))
                .frame(width: 300, height: 300)
                .offset(x: animate ? -80 : -60, y: animate ? -200 : -220)
                .blur(radius: 2)

            Circle()
                .fill(.white.opacity(0.03))
                .frame(width: 200, height: 200)
                .offset(x: animate ? 120 : 100, y: animate ? 300 : 320)
                .blur(radius: 2)

            Circle()
                .fill(.white.opacity(0.05))
                .frame(width: 150, height: 150)
                .offset(x: animate ? 100 : 80, y: animate ? -350 : -330)
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppState())
        .environmentObject(AuthService())
}
