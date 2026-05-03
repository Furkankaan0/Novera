// StoreKitService.swift
// Növera — StoreKit 2 In-App Purchase Service

import Foundation
import StoreKit

@MainActor
final class StoreKitService: ObservableObject {
    static let shared = StoreKitService()

    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isLoading: Bool = false
    @Published var error: String? = nil

    private var updates: Task<Void, Never>? = nil

    init() {
        updates = listenForTransactions()
        Task { await loadProducts() }
        Task { await updatePurchasedProducts() }
    }

    deinit {
        updates?.cancel()
    }

    // MARK: - Load Products
    func loadProducts() async {
        isLoading = true
        do {
            let ids: Set<String> = [
                NoveraConstants.Products.monthlyPro,
                NoveraConstants.Products.annualPro,
                NoveraConstants.Products.lifetimePro
            ]
            products = try await Product.products(for: ids)
                .sorted { $0.price < $1.price }
        } catch {
            self.error = "Ürünler yüklenemedi: \(error.localizedDescription)"
        }
        isLoading = false
    }

    // MARK: - Purchase
    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updatePurchasedProducts()
            await transaction.finish()
            return true

        case .userCancelled:
            return false

        case .pending:
            return false

        @unknown default:
            return false
        }
    }

    // MARK: - Restore
    func restore() async {
        try? await AppStore.sync()
        await updatePurchasedProducts()
    }

    // MARK: - Check Premium
    var isPremium: Bool {
        !purchasedProductIDs.isEmpty
    }

    // MARK: - Verification
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreKitError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    // MARK: - Update purchased products
    private func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            if transaction.revocationDate == nil {
                purchasedProductIDs.insert(transaction.productID)
            } else {
                purchasedProductIDs.remove(transaction.productID)
            }
        }
        // Persist premium status
        UserDefaults.standard.set(isPremium, forKey: NoveraConstants.Keys.isPremiumUser)
    }

    // MARK: - Listen for transactions
    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached {
            for await result in Transaction.updates {
                guard case .verified(let transaction) = result else { continue }
                await self.updatePurchasedProducts()
                await transaction.finish()
            }
        }
    }
}

enum StoreKitError: Error {
    case failedVerification
}
