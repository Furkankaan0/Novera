import SwiftUI

enum Typography {
    static let hero = Font.system(.largeTitle, design: .rounded, weight: .bold)
    static let title = Font.system(.title2, design: .rounded, weight: .bold)
    static let headline = Font.system(.headline, design: .rounded, weight: .semibold)
    static let metric = Font.system(.title, design: .rounded, weight: .bold)
    static let body = Font.system(.body, design: .rounded)
    static let caption = Font.system(.caption, design: .rounded, weight: .medium)
}
