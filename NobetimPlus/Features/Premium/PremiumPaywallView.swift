import StoreKit
import SwiftUI

@MainActor
final class SubscriptionManager: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var premiumStatus: PremiumStatus = .free
    var mockMode = true

    func loadProducts() async {
        guard !mockMode else { return }
        do {
            products = try await Product.products(for: PremiumPlanKind.allCases.map(\.productID))
            await refreshEntitlements()
        } catch {
            products = []
        }
    }

    func purchase(_ plan: PremiumPlanKind) async -> PremiumStatus {
        guard !mockMode else {
            premiumStatus = plan == .lifetime ? .lifetime : (plan == .yearly ? .yearly : .monthly)
            return premiumStatus
        }

        guard let product = products.first(where: { $0.id == plan.productID }) else { return .free }
        do {
            let result = try await product.purchase()
            if case let .success(verification) = result,
               case let .verified(transaction) = verification {
                await transaction.finish()
                premiumStatus = plan == .lifetime ? .lifetime : (plan == .yearly ? .yearly : .monthly)
            }
        } catch {
            return .free
        }
        return premiumStatus
    }

    func restorePurchases() async -> PremiumStatus {
        guard !mockMode else {
            premiumStatus = .yearly
            return premiumStatus
        }
        try? await AppStore.sync()
        await refreshEntitlements()
        return premiumStatus
    }

    private func refreshEntitlements() async {
        premiumStatus = .free
        for await entitlement in Transaction.currentEntitlements {
            guard case let .verified(transaction) = entitlement else { continue }
            if transaction.productID == PremiumPlanKind.lifetime.productID {
                premiumStatus = .lifetime
            } else if transaction.productID == PremiumPlanKind.yearly.productID {
                premiumStatus = .yearly
            } else if transaction.productID == PremiumPlanKind.monthly.productID {
                premiumStatus = .monthly
            }
        }
    }
}

struct PremiumPaywallView: View {
    @ObservedObject var appState: AppState
    @StateObject private var subscriptionManager = SubscriptionManager()

    var body: some View {
        NavigationStack {
            ZStack {
                CinematicBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: Spacing.large) {
                        BrandHeroMark(size: 184, showTitle: true, subtitle: "Sınırsız çalışma görünürlüğü")

                        PremiumGlassPanel(cornerRadius: 30) {
                            VStack(alignment: .leading, spacing: Spacing.medium) {
                                Text("Premium ile tüm kontrol sende")
                                    .font(.system(.title2, design: .rounded, weight: .black))
                                Text("Nöbetim+ Premium ile sınırsız nöbet, gelişmiş mesai analizi, resmi tatil hesaplama, widget’lar, ekip yönetimi, akıllı içgörüler ve premium temalar açılır.")
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)

                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                    PlanFeatureRow(title: "Sınırsız nöbet", icon: "infinity", color: DesignColors.primary)
                                    PlanFeatureRow(title: "Gelir analizi", icon: "banknote.fill", color: DesignColors.success)
                                    PlanFeatureRow(title: "Ekip yönetimi", icon: "person.3.fill", color: DesignColors.secondary)
                                    PlanFeatureRow(title: "Akıllı içgörü", icon: "sparkles", color: DesignColors.accent)
                                }
                            }
                        }

                        ForEach(PremiumPlan.recommendedTurkeyPlans) { plan in
                            planCard(plan)
                        }

                        Button("Satın alımları geri yükle") {
                            Task {
                                let status = await subscriptionManager.restorePurchases()
                                var profile = appState.profile
                                profile.premiumStatus = status
                                appState.updateProfile(profile)
                                appState.showToast("Satın alımlar kontrol edildi")
                            }
                        }
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(DesignColors.secondary)
                        .frame(minHeight: 44)

                        Text("7 gün deneme ve yasal metinler App Store Connect ürünleriyle etkinleştirilecektir.")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(Spacing.large)
                    .padding(.bottom, Spacing.large)
                }
            }
            .navigationTitle("Premium")
            .toolbarBackground(.hidden, for: .navigationBar)
            .task { await subscriptionManager.loadProducts() }
        }
    }

    private func planCard(_ plan: PremiumPlan) -> some View {
        let tint = planTint(plan.id)
        let isHighlighted = plan.id == .yearly || plan.id == .lifetime

        return Button {
            Task {
                let status = await subscriptionManager.purchase(plan.id)
                var profile = appState.profile
                profile.premiumStatus = status
                appState.updateProfile(profile)
                appState.showToast("Premium etkinleştirildi")
            }
        } label: {
            PremiumGlassPanel(cornerRadius: 26) {
                VStack(alignment: .leading, spacing: Spacing.medium) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 7) {
                            if let badge = plan.badge {
                                ShiftStatusCapsule(title: badge, color: tint, systemImage: plan.id == .lifetime ? "crown.fill" : "star.fill")
                            } else {
                                ShiftStatusCapsule(title: "Esnek kullanım", color: tint, systemImage: "bolt.fill")
                            }
                            Text(plan.title)
                                .font(.system(.title3, design: .rounded, weight: .black))
                            Text(plan.subtitle)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(plan.priceText)
                            .font(.system(.title3, design: .rounded, weight: .black))
                            .foregroundStyle(tint)
                    }

                    if isHighlighted {
                        Divider().opacity(0.35)
                        Text(plan.id == .lifetime ? "Tek sefer öde, Premium alanları kalıcı aç." : "Aylığa göre daha avantajlı yıllık deneyim.")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(tint.opacity(isHighlighted ? 0.70 : 0.26), lineWidth: isHighlighted ? 1.4 : 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(plan.title), \(plan.priceText)")
    }

    private func planTint(_ kind: PremiumPlanKind) -> Color {
        switch kind {
        case .monthly: DesignColors.primary
        case .yearly: DesignColors.accent
        case .lifetime: DesignColors.warning
        }
    }
}

private struct PlanFeatureRow: View {
    var title: String
    var icon: String
    var color: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption.weight(.black))
                .foregroundStyle(.white)
                .frame(width: 25, height: 25)
                .background(color.opacity(0.32), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                .accessibilityHidden(true)
            Text(title)
                .font(.caption.weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.78)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct PremiumPaywallCard: View {
    var action: () -> Void

    var body: some View {
        PremiumGlassPanel(cornerRadius: 28) {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                HStack {
                    ShiftStatusCapsule(title: "Premium", subtitle: "Analiz + ekip", color: DesignColors.accent, systemImage: "sparkles")
                    Spacer()
                    Image("BrandLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48, height: 48)
                        .accessibilityHidden(true)
                }
                Text("Gelişmiş analiz, gelir hesaplama, ekip yönetimi, widget ve premium temaları aç.")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                PremiumCTAButton(title: "Premium’u keşfet", systemImage: "sparkles", tint: DesignColors.accent, action: action)
            }
        }
    }
}
