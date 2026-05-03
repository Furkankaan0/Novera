// AddShiftView.swift
// Növera — Premium Add/Edit Shift Form

import SwiftUI

struct AddShiftView: View {
    @StateObject private var vm = ShiftFormViewModel()
    @Environment(\.dismiss) var dismiss
    var preselectedDate: Date? = nil
    var editingShift: Shift? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: NSpacing.lg) {
                    // Duration preview hero
                    durationBanner
                        .entrance(delay: 0)

                    // Type selector
                    shiftTypeSelector
                        .entrance(delay: 0.03)

                    // Main form fields
                    formFields
                        .entrance(delay: 0.06)

                    // Toggles
                    togglesSection
                        .entrance(delay: 0.09)

                    // Hourly rate
                    rateField
                        .entrance(delay: 0.12)

                    // Calendar sync
                    calendarToggle
                        .entrance(delay: 0.15)

                    // Error
                    if let error = vm.errorMessage {
                        HStack(spacing: NSpacing.sm) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(NColor.danger)
                            Text(error)
                                .font(NFont.subheadline())
                                .foregroundStyle(NColor.danger)
                        }
                        .premiumGlass(radius: NRadius.small, padding: NSpacing.md)
                        .transition(.opacity.combined(with: .scale))
                    }

                    // Save button
                    PremiumPrimaryButton(
                        title: editingShift != nil ? "Güncelle" : "Vardiya Ekle",
                        icon: "checkmark"
                    ) {
                        vm.save(preselectedDate: preselectedDate, editing: editingShift)
                    }
                    .disabled(!vm.isValid)
                    .opacity(vm.isValid ? 1 : 0.5)
                }
                .padding(NSpacing.base)
                .padding(.bottom, NSpacing.xxl)
            }
            .screenBackground()
            .navigationTitle(editingShift != nil ? "Vardiyayı Düzenle" : "Yeni Vardiya")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                        .foregroundStyle(NColor.textSecondary)
                }
            }
            .onAppear {
                if let date = preselectedDate {
                    vm.startDate = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: date) ?? date
                    vm.endDate = Calendar.current.date(bySettingHour: 16, minute: 0, second: 0, of: date) ?? date
                }
                if let shift = editingShift {
                    vm.loadShift(shift)
                }
            }
            .onChange(of: vm.didSave) { _, saved in
                if saved { dismiss() }
            }
        }
    }

    // MARK: - Duration Banner
    var durationBanner: some View {
        HStack {
            VStack(alignment: .leading, spacing: NSpacing.xs) {
                Text("Toplam Süre")
                    .font(NFont.caption(.medium))
                    .foregroundStyle(NColor.textSecondary)
                Text(vm.durationPreview)
                    .font(NFont.display(32))
                    .foregroundStyle(NColor.primaryFallback)
                    .contentTransition(.numericText())
            }
            Spacer()
            Soft3DIcon(
                icon: vm.shiftType.icon,
                size: .large,
                color: vm.shiftType.color
            )
        }
        .premiumGlass(radius: NRadius.large, padding: NSpacing.lg)
    }

    // MARK: - Shift Type Selector
    var shiftTypeSelector: some View {
        VStack(alignment: .leading, spacing: NSpacing.sm) {
            Text("Vardiya Türü")
                .font(NFont.footnote(.bold))
                .foregroundStyle(NColor.textSecondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: NSpacing.sm) {
                    ForEach(ShiftType.allCases, id: \.self) { type in
                        PremiumShiftTypeChip(type: type, isSelected: vm.shiftType == type) {
                            withAnimation(NMotion.snappy) {
                                vm.shiftType = type
                                vm.suggestTitle()
                            }
                            HapticManager.selection()
                        }
                    }
                }
            }
        }
    }

    // MARK: - Form Fields
    var formFields: some View {
        VStack(spacing: NSpacing.lg) {
            PremiumFormField(label: "Vardiya Adı", isRequired: true) {
                NoveraTextField(placeholder: "Örn: Acil Servis Nöbeti", text: $vm.title, icon: "pencil")
            }

            PremiumFormField(label: "Görev Yeri") {
                NoveraTextField(placeholder: "Örn: Yoğun Bakım - A Blok", text: $vm.location, icon: "mappin")
            }

            // Date pickers in glass card
            HStack(spacing: NSpacing.md) {
                VStack(alignment: .leading, spacing: NSpacing.sm) {
                    Text("Başlangıç")
                        .font(NFont.footnote(.bold))
                        .foregroundStyle(NColor.textSecondary)
                    DatePicker("", selection: $vm.startDate, displayedComponents: [.date, .hourAndMinute])
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .environment(\.locale, Locale(identifier: "tr_TR"))
                }
                VStack(alignment: .leading, spacing: NSpacing.sm) {
                    Text("Bitiş")
                        .font(NFont.footnote(.bold))
                        .foregroundStyle(NColor.textSecondary)
                    DatePicker("", selection: $vm.endDate, displayedComponents: [.date, .hourAndMinute])
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .environment(\.locale, Locale(identifier: "tr_TR"))
                }
            }

            PremiumFormField(label: "Not (İsteğe bağlı)") {
                NoveraTextField(placeholder: "Vardiya notları...", text: $vm.notes, icon: "note.text")
            }
        }
    }

    // MARK: - Toggles
    var togglesSection: some View {
        VStack(spacing: NSpacing.md) {
            NoveraToggleRow(
                title: "Resmi Tatil / UBGT",
                subtitle: "Bayram veya resmi tatil nöbeti",
                icon: "flag.fill",
                iconColor: NColor.shiftHoliday,
                isOn: $vm.isHoliday
            )
            NoveraToggleRow(
                title: "Fazla Mesai",
                subtitle: "Normal çalışma saati üstünde",
                icon: "clock.badge.plus",
                iconColor: NColor.shiftOvertime,
                isOn: $vm.isOvertime
            )
        }
    }

    // MARK: - Rate Field
    var rateField: some View {
        PremiumFormField(label: "Saatlik Ücret (₺)") {
            NoveraTextField(placeholder: "Örn: 150", text: $vm.hourlyRate, icon: "turkishlirasign", keyboardType: .decimalPad)
        }
    }

    // MARK: - Calendar Toggle
    var calendarToggle: some View {
        NoveraToggleRow(
            title: "Takvime Ekle",
            subtitle: "iOS takviminize otomatik ekle",
            icon: "calendar.badge.plus",
            iconColor: NColor.primaryFallback,
            isOn: $vm.addToCalendar
        )
    }
}

// MARK: - Premium Shift Type Chip
struct PremiumShiftTypeChip: View {
    let type: ShiftType
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button(action: action) {
            HStack(spacing: NSpacing.sm) {
                Image(systemName: type.icon)
                    .font(.system(size: 13, weight: .semibold))
                Text(type.displayName)
                    .font(NFont.subheadline(.medium))
            }
            .foregroundStyle(isSelected ? .white : type.color)
            .padding(.horizontal, NSpacing.base)
            .padding(.vertical, NSpacing.md)
            .background(
                Capsule()
                    .fill(isSelected ? type.color : type.color.opacity(colorScheme == .dark ? 0.18 : 0.10))
                    .overlay(
                        Capsule()
                            .strokeBorder(type.color.opacity(isSelected ? 0 : 0.3), lineWidth: 0.8)
                    )
            )
            .shadow(
                color: isSelected ? type.color.opacity(0.35) : .clear,
                radius: 8, x: 0, y: 4
            )
        }
        .pressEffect()
    }
}

// Legacy alias
typealias ShiftTypeChip = PremiumShiftTypeChip

// MARK: - Toggle Row
struct NoveraToggleRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let iconColor: Color
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: NSpacing.md) {
            Soft3DIcon(icon: icon, size: .small, color: iconColor)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(NFont.subheadline(.medium))
                    .foregroundStyle(NColor.textPrimary)
                Text(subtitle)
                    .font(NFont.caption())
                    .foregroundStyle(NColor.textSecondary)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(iconColor)
        }
        .premiumGlass(radius: NRadius.medium, padding: NSpacing.base)
        .onTapGesture {
            HapticManager.selection()
            isOn.toggle()
        }
        .accessibilityLabel(title)
        .accessibilityValue(isOn ? "Açık" : "Kapalı")
    }
}

#Preview {
    AddShiftView()
}
