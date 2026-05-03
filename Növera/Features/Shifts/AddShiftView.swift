// AddShiftView.swift
// Növera — Add/Edit Shift Form

import SwiftUI

struct AddShiftView: View {
    @StateObject private var vm = ShiftFormViewModel()
    @Environment(\.dismiss) var dismiss
    var preselectedDate: Date? = nil
    var editingShift: Shift? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: NoveraSpacing.md) {
                    // Duration preview banner
                    durationBanner

                    // Type selector
                    shiftTypeSelector

                    // Main form fields
                    formFields

                    // Toggles
                    togglesSection

                    // Hourly rate
                    rateField

                    // Calendar sync
                    calendarToggle

                    // Error
                    if let error = vm.errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(NoveraColors.error)
                            Text(error)
                                .font(NoveraFonts.subheadline())
                                .foregroundStyle(NoveraColors.error)
                        }
                        .padding(NoveraSpacing.md)
                        .glassBackground(cornerRadius: NoveraRadius.sm)
                        .transition(.opacity.combined(with: .scale))
                    }

                    // Save button
                    NoveraPrimaryButton(
                        editingShift != nil ? "Güncelle" : "Vardiya Ekle",
                        icon: "checkmark",
                        isLoading: vm.isSaving
                    ) {
                        vm.save(preselectedDate: preselectedDate, editing: editingShift)
                    }
                    .disabled(!vm.isValid)
                    .opacity(vm.isValid ? 1 : 0.5)
                }
                .padding(NoveraSpacing.md)
                .padding(.bottom, NoveraSpacing.xl)
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle(editingShift != nil ? "Vardiyayı Düzenle" : "Yeni Vardiya")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                        .foregroundStyle(NoveraColors.textSecondary)
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
            VStack(alignment: .leading, spacing: 2) {
                Text("Toplam Süre")
                    .font(NoveraFonts.caption())
                    .foregroundStyle(NoveraColors.textSecondary)
                Text(vm.durationPreview)
                    .font(NoveraFonts.display(32))
                    .foregroundStyle(NoveraColors.primary)
            }
            Spacer()
            Image(systemName: vm.shiftType.icon)
                .font(.system(size: 36))
                .foregroundStyle(
                    LinearGradient(
                        colors: [vm.shiftType.color, vm.shiftType.color.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .symbolRenderingMode(.hierarchical)
        }
        .padding(NoveraSpacing.md)
        .glassBackground(cornerRadius: NoveraRadius.lg)
    }

    // MARK: - Shift Type Selector
    var shiftTypeSelector: some View {
        VStack(alignment: .leading, spacing: NoveraSpacing.sm) {
            Text("Vardiya Türü")
                .font(NoveraFonts.footnote(.semibold))
                .foregroundStyle(NoveraColors.textSecondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: NoveraSpacing.sm) {
                    ForEach(ShiftType.allCases, id: \.self) { type in
                        ShiftTypeChip(type: type, isSelected: vm.shiftType == type) {
                            withAnimation(NoveraAnimation.springFast) {
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
        VStack(spacing: NoveraSpacing.md) {
            NoveraFormField(label: "Vardiya Adı", isRequired: true) {
                NoveraTextField(
                    placeholder: "Örn: Acil Servis Nöbeti",
                    text: $vm.title,
                    icon: "pencil"
                )
            }

            NoveraFormField(label: "Görev Yeri") {
                NoveraTextField(
                    placeholder: "Örn: Yoğun Bakım - A Blok",
                    text: $vm.location,
                    icon: "mappin"
                )
            }

            HStack(spacing: NoveraSpacing.sm) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Başlangıç")
                        .font(NoveraFonts.footnote(.semibold))
                        .foregroundStyle(NoveraColors.textSecondary)
                    DatePicker("", selection: $vm.startDate, displayedComponents: [.date, .hourAndMinute])
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .environment(\.locale, Locale(identifier: "tr_TR"))
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("Bitiş")
                        .font(NoveraFonts.footnote(.semibold))
                        .foregroundStyle(NoveraColors.textSecondary)
                    DatePicker("", selection: $vm.endDate, displayedComponents: [.date, .hourAndMinute])
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .environment(\.locale, Locale(identifier: "tr_TR"))
                }
            }

            NoveraFormField(label: "Not (İsteğe bağlı)") {
                NoveraTextField(
                    placeholder: "Vardiya notları...",
                    text: $vm.notes,
                    icon: "note.text"
                )
            }
        }
    }

    // MARK: - Toggles
    var togglesSection: some View {
        VStack(spacing: NoveraSpacing.sm) {
            NoveraToggleRow(
                title: "Resmi Tatil / UBGT",
                subtitle: "Bayram veya resmi tatil nöbeti",
                icon: "flag.fill",
                iconColor: NoveraColors.shiftHoliday,
                isOn: $vm.isHoliday
            )

            NoveraToggleRow(
                title: "Fazla Mesai",
                subtitle: "Normal çalışma saati üstünde",
                icon: "clock.badge.plus",
                iconColor: NoveraColors.shiftOvertime,
                isOn: $vm.isOvertime
            )
        }
    }

    // MARK: - Rate Field
    var rateField: some View {
        NoveraFormField(label: "Saatlik Ücret (₺)") {
            NoveraTextField(
                placeholder: "Örn: 150",
                text: $vm.hourlyRate,
                icon: "turkishlirasign",
                keyboardType: .decimalPad
            )
        }
    }

    // MARK: - Calendar Toggle
    var calendarToggle: some View {
        NoveraToggleRow(
            title: "Takvime Ekle",
            subtitle: "iOS takviminize otomatik ekle",
            icon: "calendar.badge.plus",
            iconColor: NoveraColors.primary,
            isOn: $vm.addToCalendar
        )
    }
}

// MARK: - Shift Type Chip
struct ShiftTypeChip: View {
    let type: ShiftType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: type.icon)
                    .font(.system(size: 13, weight: .semibold))
                Text(type.displayName)
                    .font(NoveraFonts.subheadline(.medium))
            }
            .foregroundStyle(isSelected ? .white : type.color)
            .padding(.horizontal, NoveraSpacing.md)
            .padding(.vertical, NoveraSpacing.sm)
            .background(
                Capsule()
                    .fill(isSelected ? type.color : type.color.opacity(0.12))
            )
        }
        .scaleOnPress()
    }
}

// MARK: - Toggle Row
struct NoveraToggleRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let iconColor: Color
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: NoveraSpacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(NoveraFonts.subheadline(.medium))
                Text(subtitle)
                    .font(NoveraFonts.caption())
                    .foregroundStyle(NoveraColors.textSecondary)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(iconColor)
        }
        .padding(NoveraSpacing.md)
        .glassBackground(cornerRadius: NoveraRadius.md)
        .noveraShadow(NoveraShadows.soft)
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
