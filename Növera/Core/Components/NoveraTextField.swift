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
            HStack(spacing: NoveraSpacing.sm) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(isFocused ? NoveraColors.primary : NoveraColors.textSecondary)
                        .frame(width: 20)
                        .animation(NoveraAnimation.springFast, value: isFocused)
                }

                if isSecure {
                    SecureField(placeholder, text: $text)
                        .font(NoveraFonts.body())
                        .focused($isFocused)
                } else {
                    TextField(placeholder, text: $text)
                        .font(NoveraFonts.body())
                        .keyboardType(keyboardType)
                        .focused($isFocused)
                }
            }
            .padding(.horizontal, NoveraSpacing.md)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: NoveraRadius.sm, style: .continuous)
                    .fill(colorScheme == .dark
                        ? NoveraColors.backgroundSecondaryDark
                        : NoveraColors.backgroundSecondaryLight
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: NoveraRadius.sm, style: .continuous)
                            .strokeBorder(
                                isFocused
                                    ? NoveraColors.primary.opacity(0.7)
                                    : (errorMessage != nil
                                        ? NoveraColors.error.opacity(0.6)
                                        : Color.clear),
                                lineWidth: 1.5
                            )
                    )
            )
            .animation(NoveraAnimation.springFast, value: isFocused)

            if let errorMessage {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 12))
                    Text(errorMessage)
                        .font(NoveraFonts.caption())
                }
                .foregroundStyle(NoveraColors.error)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .accessibilityLabel(placeholder)
        .accessibilityValue(text)
    }
}

// MARK: - Labeled Field Wrapper
struct NoveraFormField<Content: View>: View {
    let label: String
    var isRequired: Bool = false
    let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: NoveraSpacing.xs) {
            HStack(spacing: 3) {
                Text(label)
                    .font(NoveraFonts.footnote(.semibold))
                    .foregroundStyle(NoveraColors.textSecondary)
                if isRequired {
                    Text("*")
                        .font(NoveraFonts.footnote(.semibold))
                        .foregroundStyle(NoveraColors.error)
                }
            }
            content()
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        NoveraFormField(label: "Ad Soyad", isRequired: true) {
            NoveraTextField(
                placeholder: "Ad ve soyadınızı girin",
                text: .constant(""),
                icon: "person"
            )
        }
        NoveraFormField(label: "Şifre") {
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
