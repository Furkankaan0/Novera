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
            ScrollView {
                VStack(spacing: Spacing.large) {
                    premiumOrb
                    Text("Nöbetim+ Premium")
                        .font(Typography.hero)
                    Text("Nöbetim+ Premium ile sınırsız nöbet, gelişmiş mesai analizi, resmi tatil hesaplama, widget’lar, ekip yönetimi, akıllı içgörüler ve premium temalar açılır.")
                        .font(Typography.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

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
                    .frame(minHeight: 44)

                    Text("7 gün deneme ve yasal metinler App Store Connect ürünleriyle etkinleştirilecektir.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(Spacing.large)
            }
            .background(AppBackground())
            .navigationTitle("Premium")
            .task { await subscriptionManager.loadProducts() }
        }
    }

    private var premiumOrb: some View {
        ZStack {
            Circle().fill(DesignColors.primary.opacity(0.55)).frame(width: 150, height: 150).blur(radius: 2)
            Circle().fill(DesignColors.secondary.opacity(0.45)).frame(width: 104, height: 104).offset(x: 38, y: -24)
            Circle().fill(DesignColors.accent.opacity(0.55)).frame(width: 92, height: 92).offset(x: -34, y: 34)
            Image(systemName: "sparkles").font(.system(size: 58, weight: .bold)).foregroundStyle(.white)
        }
        .accessibilityHidden(true)
    }

    private func planCard(_ plan: PremiumPlan) -> some View {
        Button {
            Task {
                let status = await subscriptionManager.purchase(plan.id)
                var profile = appState.profile
                profile.premiumStatus = status
                appState.updateProfile(profile)
                appState.showToast("Premium etkinleştirildi")
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(plan.title).font(Typography.headline)
                    Text(plan.subtitle).font(.subheadline).foregroundStyle(.secondary)
                    if let badge = plan.badge {
                        ShiftTypePill(title: badge, color: DesignColors.accent, systemImage: "star.fill")
                    }
                }
                Spacer()
                Text(plan.priceText).font(.title3.weight(.bold))
            }
            .padding(Spacing.large)
            .glassCard(cornerRadius: 22)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(plan.title), \(plan.priceText)")
    }
}

struct PremiumPaywallCard: View {
    var action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Label("Premium Alanı", systemImage: "sparkles")
                .font(Typography.title)
                .foregroundStyle(DesignColors.accent)
            Text("Gelişmiş analiz, gelir hesaplama, ekip yönetimi, widget ve premium temaları aç.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("Premium’u keşfet", action: action)
                .buttonStyle(.borderedProminent)
                .tint(DesignColors.accent)
                .frame(minHeight: 44)
        }
        .padding(Spacing.large)
        .glassCard()
    }
}
