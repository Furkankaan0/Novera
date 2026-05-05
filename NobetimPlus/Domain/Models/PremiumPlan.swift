import Foundation

enum PremiumPlanKind: String, Codable, CaseIterable, Identifiable, Hashable {
    case monthly
    case yearly
    case lifetime

    var id: String { rawValue }

    var productID: String {
        switch self {
        case .monthly: "nobetimplus_premium_monthly"
        case .yearly: "nobetimplus_premium_yearly"
        case .lifetime: "nobetimplus_premium_lifetime"
        }
    }
}

struct PremiumPlan: Identifiable, Codable, Hashable {
    var id: PremiumPlanKind
    var title: String
    var subtitle: String
    var priceText: String
    var badge: String?

    static let recommendedTurkeyPlans: [PremiumPlan] = [
        PremiumPlan(id: .monthly, title: "Aylık Premium", subtitle: "Esnek kullanım", priceText: "79,99 TL", badge: nil),
        PremiumPlan(id: .yearly, title: "Yıllık Premium", subtitle: "En Popüler", priceText: "499,99 TL", badge: "En Popüler"),
        PremiumPlan(id: .lifetime, title: "Ömür Boyu Premium", subtitle: "Tek Seferlik En İyi Değer", priceText: "1.499,99 TL", badge: "En İyi Değer")
    ]
}
