// PremiumView.swift
// Növera — Premium / Pro Paywall Screen

import SwiftUI
import StoreKit

struct PremiumView: View {
    @StateObject private var storeKit = StoreKitService.shared
    @Environment(\.dismiss) var dismiss
    @State private var selectedPlan: String = NoveraConstants.Products.annualPro
    @State private var isProcessing: Bool = false
    @State private var errorMessage: String? = nil
    @State private var animateHero: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Hero
                    heroSection

                    // Feature list
                    featureSection
                        .padding(.horizontal, NSpacing.base)
                        .padding(.top, NSpacing.lg)
                        .entrance(delay: 0.05)

                    // Plans
                    plansSection
                        .padding(.horizontal, NSpacing.base)
                        .padding(.top, NSpacing.lg)
                        .entrance(delay: 0.10)

                    // CTA
                    ctaSection
                        .padding(.horizontal, NSpacing.base)
                        .padding(.top, NSpacing.md)
                        .entrance(delay: 0.15)

                    // Fine print
                    finePrint
                        .padding(.top, NSpacing.md)
                        .padding(.bottom, NSpacing.xl)
                }
            }
            .screenBackground()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(NColor.textTertiary)
                            .font(.system(size: 22))
                    }
                }
            }
            .onAppear {
                withAnimation(NMotion.premium.delay(0.2)) {
                    animateHero = true
                }
            }
        }
    }

    // MARK: - Hero
    var heroSection: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hue: 0.72, saturation: 0.70, brightness: 0.30),
                    Color(hue: 0.55, saturation: 0.75, brightness: 0.20)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 280)

            VStack(spacing: NSpacing.lg) {
                ZStack {
                    // Glow
                    Circle()
                        .fill(NColor.accent.opacity(0.2))
                        .frame(width: 140, height: 140)
                        .blur(radius: 30)

                    Image(systemName: "star.square.on.square.fill")
                        .font(.system(size: 64, weight: .light))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(hue: 0.82, saturation: 0.4, brightness: 1.0),
                                    NColor.primaryFallback
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .symbolRenderingMode(.hierarchical)
                        .shadow(color: NColor.accent.opacity(0.4), radius: 12, x: 0, y: 6)
                }
                .scaleEffect(animateHero ? 1 : 0.6)
                .opacity(animateHero ? 1 : 0)

                VStack(spacing: NSpacing.xs) {
                    Text("Növera Pro")
                        .font(NFont.largeTitle(.bold))
                        .foregroundStyle(.white)
                    Text("Profesyonel sağlık çalışanları için")
                        .font(NFont.callout())
                        .foregroundStyle(.white.opacity(0.75))
                }
                .opacity(animateHero ? 1 : 0)
                .offset(y: animateHero ? 0 : 10)
            }
        }
    }

    // MARK: - Features
    var featureSection: some View {
        VStack(spacing: NSpacing.md) {
            PremiumSectionHeader(title: "Pro ile neler açılır?")

            let features: [(String, String, Color)] = [
                ("infinity", "Sınırsız vardiya kaydı", NColor.primaryFallback),
                ("person.2.fill", "Ekip yönetimi ve üye ekleme", NColor.accent),
                ("chart.bar.xaxis", "Gelişmiş gelir/mesai analizi", NColor.success),
                ("arrow.left.arrow.right", "Nöbet takas sistemi", NColor.shiftOncall),
                ("rectangle.3.group.fill", "iOS Widget desteği", NColor.shiftNight),
                ("lightbulb.fill", "Akıllı vardiya önerileri", NColor.warning),
                ("doc.text.fill", "Aylık detaylı raporlar", NColor.info),
            ]

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: NSpacing.sm) {
                ForEach(features, id: \.1) { icon, title, color in
                    HStack(spacing: NSpacing.sm) {
                        Soft3DIcon(icon: icon, size: .small, color: color)
                        Text(title)
                            .font(NFont.caption(.medium))
                            .foregroundStyle(NColor.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                    }
                    .premiumGlass(radius: NRadius.small, padding: NSpacing.sm)
                }
            }
        }
    }

    // MARK: - Plans
    var plansSection: some View {
        VStack(spacing: NSpacing.md) {
            PremiumSectionHeader(title: "Plan Seçin")

            if storeKit.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if storeKit.products.isEmpty {
                VStack(spacing: NSpacing.sm) {
                    PremiumPlanCard(
                        title: "Aylık",
                        price: "₺79.99/ay",
                        tag: nil,
                        isSelected: selectedPlan == NoveraConstants.Products.monthlyPro
                    ) {
                        selectedPlan = NoveraConstants.Products.monthlyPro
                    }
                    PremiumPlanCard(
                        title: "Yıllık",
                        price: "₺599.99/yıl",
                        tag: "En İyi Değer",
                        isSelected: selectedPlan == NoveraConstants.Products.annualPro
                    ) {
                        selectedPlan = NoveraConstants.Products.annualPro
                    }
                    PremiumPlanCard(
                        title: "Ömür Boyu",
                        price: "₺999.99",
                        tag: "Tek Seferlik",
                        isSelected: selectedPlan == NoveraConstants.Products.lifetimePro
                    ) {
                        selectedPlan = NoveraConstants.Products.lifetimePro
                    }
                }
            } else {
                ForEach(storeKit.products) { product in
                    PremiumPlanCard(
                        title: product.displayName,
                        price: product.displayPrice,
                        tag: product.id == NoveraConstants.Products.annualPro ? "En İyi Değer" : nil,
                        isSelected: selectedPlan == product.id
                    ) {
                        selectedPlan = product.id
                    }
                }
            }
        }
    }

    // MARK: - CTA
    var ctaSection: some View {
        VStack(spacing: NSpacing.md) {
            if let error = errorMessage {
                Text(error)
                    .font(NFont.subheadline())
                    .foregroundStyle(NColor.danger)
                    .multilineTextAlignment(.center)
            }

            ZStack {
                PremiumPrimaryButton(
                    title: "Pro'ya Geç",
                    icon: "star.fill"
                ) {
                    Task { await purchase() }
                }
                .disabled(isProcessing)

                if isProcessing {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                }
            }

            PremiumGhostButton(title: "Satın Alımları Geri Yükle") {
                Task {
                    await storeKit.restore()
                }
            }
        }
    }

    // MARK: - Fine Print
    var finePrint: some View {
        VStack(spacing: NSpacing.xs) {
            Text("Abonelik her dönem otomatik olarak yenilenir. İstediğiniz zaman iptal edebilirsiniz.")
                .font(NFont.caption())
                .foregroundStyle(NColor.textTertiary)
                .multilineTextAlignment(.center)
            HStack(spacing: NSpacing.md) {
                Button("Gizlilik Politikası") {}
                    .font(NFont.caption(.medium))
                    .foregroundStyle(NColor.primaryFallback)
                Button("Kullanım Koşulları") {}
                    .font(NFont.caption(.medium))
                    .foregroundStyle(NColor.primaryFallback)
            }
        }
        .padding(.horizontal, NSpacing.xl)
    }

    // MARK: - Purchase
    func purchase() async {
        guard let product = storeKit.products.first(where: { $0.id == selectedPlan }) else {
            return
        }
        isProcessing = true
        do {
            let success = try await storeKit.purchase(product)
            if success {
                HapticManager.notification(.success)
                dismiss()
            }
        } catch {
            errorMessage = error.localizedDescription
            HapticManager.notification(.error)
        }
        isProcessing = false
    }
}

// MARK: - Premium Plan Card
struct PremiumPlanCard: View {
    let title: String
    let price: String
    let tag: String?
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: {
            HapticManager.selection()
            action()
        }) {
            HStack {
                VStack(alignment: .leading, spacing: NSpacing.xs) {
                    HStack(spacing: NSpacing.sm) {
                        Text(title)
                            .font(NFont.headline(.semibold))
                            .foregroundStyle(NColor.textPrimary)
                        if let tag {
                            Text(tag)
                                .font(NFont.caption2(.bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, NSpacing.sm)
                                .padding(.vertical, 3)
                                .background(
                                    Capsule()
                                        .fill(NColor.success)
                                        .shadow(color: NColor.success.opacity(0.3), radius: 4, x: 0, y: 2)
                                )
                        }
                    }
                    Text(price)
                        .font(NFont.subheadline())
                        .foregroundStyle(NColor.textSecondary)
                }
                Spacer()
                ZStack {
                    Circle()
                        .strokeBorder(
                            isSelected ? NColor.primaryFallback : NColor.textTertiary.opacity(0.4),
                            lineWidth: 2
                        )
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Circle()
                            .fill(NColor.primaryFallback)
                            .frame(width: 12, height: 12)
                            .shadow(color: NColor.primaryFallback.opacity(0.4), radius: 4, x: 0, y: 2)
                    }
                }
            }
            .premiumGlass(radius: NRadius.medium, padding: NSpacing.base)
            .overlay(
                RoundedRectangle(cornerRadius: NRadius.medium, style: .continuous)
                    .strokeBorder(
                        isSelected ? NColor.primaryFallback.opacity(0.4) : .clear,
                        lineWidth: 1.5
                    )
            )
            .nShadow(isSelected ? .glow : .soft)
        }
        .pressEffect()
        .accessibilityLabel("\(title): \(price)")
        .accessibilityValue(isSelected ? "Seçili" : "Seçili değil")
    }
}

// Legacy alias
typealias PlanCard = PremiumPlanCard

#Preview {
    PremiumView()
}
