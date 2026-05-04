// NoveraTextField.swift
// Növera — Premium Text Field Components

import SwiftUI

struct NoveraTextField: View {
    let placeholder: String
    @Binding var text: String
    var icon: String? = nil
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false
    var errorMessage: String? = nil

    @FocusState private var isFocused: Bool
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: NSpacing.sm) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(isFocused ? NColor.primaryFallback : NColor.textSecondary)
                        .frame(width: 20)
                        .animation(NMotion.snappy, value: isFocused)
                }

                if isSecure {
                    SecureField(placeholder, text: $text)
                        .font(NFont.body())
                        .focused($isFocused)
                } else {
                    TextField(placeholder, text: $text)
                        .font(NFont.body())
                        .keyboardType(keyboardType)
                        .focused($isFocused)
                }
            }
            .padding(.horizontal, NSpacing.md)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: NRadius.small, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: NRadius.small, style: .continuous)
                            .fill(NColor.glassSurface)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: NRadius.small, style: .continuous)
                            .strokeBorder(
                                isFocused
                                    ? NColor.primaryFallback.opacity(0.7)
                                    : (errorMessage != nil
                                        ? NColor.danger.opacity(0.6)
                                        : Color.clear),
                                lineWidth: 1.5
                            )
                    )
            )
            .animation(NMotion.snappy, value: isFocused)

            if let errorMessage {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 12))
                    Text(errorMessage)
                        .font(NFont.caption())
                }
                .foregroundStyle(NColor.danger)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .accessibilityLabel(placeholder)
        .accessibilityValue(text)
    }
}

// Note: NoveraFormField is now defined in PremiumButtons.swift as PremiumFormField
// The typealias NoveraFormField = PremiumFormField is in DesignTokens.swift

#Preview {
    VStack(spacing: 20) {
        PremiumFormField(label: "Ad Soyad", isRequired: true) {
            NoveraTextField(
                placeholder: "Ad ve soyadınızı girin",
                text: .constant(""),
                icon: "person"
            )
        }
        PremiumFormField(label: "Şifre") {
            NoveraTextField(
                placeholder: "Şifrenizi girin",
                text: .constant(""),
                icon: "lock",
                isSecure: true
            )
        }
    }
    .padding()
}
