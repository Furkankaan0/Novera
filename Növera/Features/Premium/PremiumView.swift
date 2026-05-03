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
                        .padding(.horizontal, NoveraSpacing.md)
                        .padding(.top, NoveraSpacing.lg)

                    // Plans
                    plansSection
                        .padding(.horizontal, NoveraSpacing.md)
                        .padding(.top, NoveraSpacing.lg)

                    // CTA
                    ctaSection
                        .padding(.horizontal, NoveraSpacing.md)
                        .padding(.top, NoveraSpacing.md)

                    // Fine print
                    finePrint
                        .padding(.top, NoveraSpacing.md)
                        .padding(.bottom, NoveraSpacing.xl)
                }
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(NoveraColors.textTertiary)
                            .font(.system(size: 22))
                    }
                }
            }
            .onAppear {
                withAnimation(NoveraAnimation.spring.delay(0.2)) {
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
            .frame(height: 260)

            VStack(spacing: NoveraSpacing.md) {
                Image(systemName: "star.square.on.square.fill")
                    .font(.system(size: 64, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(hue: 0.82, saturation: 0.4, brightness: 1.0),
                                NoveraColors.primary
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .symbolRenderingMode(.hierarchical)
                    .scaleEffect(animateHero ? 1 : 0.6)
                    .opacity(animateHero ? 1 : 0)

                VStack(spacing: 4) {
                    Text("Növera Pro")
                        .font(NoveraFonts.largeTitle(.bold))
                        .foregroundStyle(.white)
                    Text("Profesyonel sağlık çalışanları için")
                        .font(NoveraFonts.callout())
                        .foregroundStyle(.white.opacity(0.75))
                }
                .opacity(animateHero ? 1 : 0)
                .offset(y: animateHero ? 0 : 10)
            }
        }
    }

    // MARK: - Features
    var featureSection: some View {
        VStack(spacing: NoveraSpacing.sm) {
            NoveraSectionHeader(title: "Pro ile neler açılır?")

            let features: [(String, String, Color)] = [
                ("infinity", "Sınırsız vardiya kaydı", NoveraColors.primary),
                ("person.2.fill", "Ekip yönetimi ve üye ekleme", NoveraColors.accent),
                ("chart.bar.xaxis", "Gelişmiş gelir/mesai analizi", NoveraColors.accentGreen),
                ("arrow.left.arrow.right", "Nöbet takas sistemi", NoveraColors.shiftOncall),
                ("rectangle.3.group.fill", "iOS Widget desteği", NoveraColors.shiftNight),
                ("lightbulb.fill", "Akıllı vardiya önerileri", NoveraColors.warning),
                ("doc.text.fill", "Aylık detaylı raporlar", NoveraColors.info),
            ]

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: NoveraSpacing.sm) {
                ForEach(features, id: \.1) { icon, title, color in
                    HStack(spacing: NoveraSpacing.sm) {
                        Image(systemName: icon)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(color)
                            .frame(width: 20)
                        Text(title)
                            .font(NoveraFonts.caption(.medium))
                            .foregroundStyle(NoveraColors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                    }
                    .padding(NoveraSpacing.sm)
                    .glassBackground(cornerRadius: NoveraRadius.sm)
                }
            }
        }
    }

    // MARK: - Plans
    var plansSection: some View {
        VStack(spacing: NoveraSpacing.sm) {
            NoveraSectionHeader(title: "Plan Seçin")

            if storeKit.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if storeKit.products.isEmpty {
                // Placeholder plans when StoreKit products aren't loaded
                VStack(spacing: NoveraSpacing.sm) {
                    PlanCard(
                        title: "Aylık",
                        price: "₺79.99/ay",
                        tag: nil,
                        isSelected: selectedPlan == NoveraConstants.Products.monthlyPro
                    ) {
                        selectedPlan = NoveraConstants.Products.monthlyPro
                    }
                    PlanCard(
                        title: "Yıllık",
                        price: "₺599.99/yıl",
                        tag: "En İyi Değer",
                        isSelected: selectedPlan == NoveraConstants.Products.annualPro
                    ) {
                        selectedPlan = NoveraConstants.Products.annualPro
                    }
                    PlanCard(
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
                    PlanCard(
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
        VStack(spacing: NoveraSpacing.sm) {
            if let error = errorMessage {
                Text(error)
                    .font(NoveraFonts.subheadline())
                    .foregroundStyle(NoveraColors.error)
                    .multilineTextAlignment(.center)
            }

            NoveraPrimaryButton(
                "Pro'ya Geç",
                icon: "star.fill",
                isLoading: isProcessing
            ) {
                Task { await purchase() }
            }

            NoveraGhostButton("Satın Alımları Geri Yükle") {
                Task {
                    await storeKit.restore()
                }
            }
        }
    }

    // MARK: - Fine Print
    var finePrint: some View {
        VStack(spacing: 4) {
            Text("Abonelik her dönem otomatik olarak yenilenir. İstediğiniz zaman iptal edebilirsiniz.")
                .font(NoveraFonts.caption())
                .foregroundStyle(NoveraColors.textTertiary)
                .multilineTextAlignment(.center)
            HStack(spacing: NoveraSpacing.md) {
                Button("Gizlilik Politikası") {}
                    .font(NoveraFonts.caption(.medium))
                    .foregroundStyle(NoveraColors.primary)
                Button("Kullanım Koşulları") {}
                    .font(NoveraFonts.caption(.medium))
                    .foregroundStyle(NoveraColors.primary)
            }
        }
        .padding(.horizontal, NoveraSpacing.xl)
    }

    // MARK: - Purchase
    func purchase() async {
        guard let product = storeKit.products.first(where: { $0.id == selectedPlan }) else {
            // Fallback for when products aren't loaded from App Store
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

// MARK: - Plan Card
struct PlanCard: View {
    let title: String
    let price: String
    let tag: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.selection()
            action()
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: NoveraSpacing.sm) {
                        Text(title)
                            .font(NoveraFonts.headline(.semibold))
                        if let tag {
                            Text(tag)
                                .font(NoveraFonts.caption(.bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(NoveraColors.accentGreen))
                        }
                    }
                    Text(price)
                        .font(NoveraFonts.subheadline())
                        .foregroundStyle(NoveraColors.textSecondary)
                }
                Spacer()
                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? NoveraColors.primary : NoveraColors.textTertiary.opacity(0.4), lineWidth: 2)
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Circle()
                            .fill(NoveraColors.primary)
                            .frame(width: 12, height: 12)
                    }
                }
            }
            .padding(NoveraSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: NoveraRadius.md, style: .continuous)
                    .fill(isSelected ? NoveraColors.primary.opacity(0.08) : Color(UIColor.tertiarySystemGroupedBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: NoveraRadius.md, style: .continuous)
                            .strokeBorder(
                                isSelected ? NoveraColors.primary.opacity(0.4) : Color.clear,
                                lineWidth: 1.5
                            )
                    )
            )
            .noveraShadow(isSelected ? NoveraShadows.soft : ShadowStyle(color: .clear, radius: 0, x: 0, y: 0))
        }
        .scaleOnPress()
        .accessibilityLabel("\(title): \(price)")
        .accessibilityValue(isSelected ? "Seçili" : "Seçili değil")
    }
}

#Preview {
    PremiumView()
}
