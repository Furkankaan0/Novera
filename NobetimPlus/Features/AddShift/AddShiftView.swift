import SwiftUI

struct AddShiftView: View {
    @ObservedObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var title = ""
    @State private var date = Date()
    @State private var startTime = Date()
    @State private var endTime = Calendar.current.date(byAdding: .hour, value: 8, to: Date()) ?? Date()
    @State private var department = "Acil Servis"
    @State private var unit = "Acil Triaj"
    @State private var shiftType: ShiftType = .day
    @State private var workKind: WorkEntryKind = .normalShift
    @State private var entryMode: ShiftEntryMode = .timeRange
    @State private var duration: Double = 8
    @State private var isOfficialHoliday = false
    @State private var isNightShift = false
    @State private var reminderEnabled = true
    @State private var notes = ""
    @State private var errorMessage: String?

    private let createShift = CreateShiftUseCase()
    private let templates: [ShiftTemplate] = [
        .init(title: "08-16", subtitle: "Gündüz", startHour: 8, duration: 8, kind: .normalShift, type: .day),
        .init(title: "08-20", subtitle: "Uzun", startHour: 8, duration: 12, kind: .normalShift, type: .day),
        .init(title: "16-00", subtitle: "Akşam", startHour: 16, duration: 8, kind: .normalShift, type: .custom),
        .init(title: "20-08", subtitle: "Gece", startHour: 20, duration: 12, kind: .nightWork, type: .night),
        .init(title: "24s", subtitle: "Tam gün", startHour: 8, duration: 24, kind: .normalShift, type: .twentyFourHour),
        .init(title: "Özel", subtitle: "7.5s", startHour: 9, duration: 7.5, kind: .customDuration, type: .custom)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                CinematicBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: Spacing.large) {
                        header
                        templateCarousel
                        workKindPanel
                        timeComposer
                        detailPanel
                        flagsPanel
                        notePanel
                        errorView
                        saveButton
                    }
                    .padding(Spacing.large)
                    .padding(.bottom, Spacing.large)
                }
            }
            .navigationTitle("Yeni nöbet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") { dismiss() }
                }
            }
        }
    }

    private var header: some View {
        HStack(spacing: Spacing.medium) {
            Image("BrandLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
                .shadow(color: DesignColors.accent.opacity(0.42), radius: 16, y: 8)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 5) {
                Text("Mesai oluştur")
                    .font(.system(.title, design: .rounded, weight: .black))
                Text("Şablon seç, süreyi ayarla, vardiyanı kaydet.")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var templateCarousel: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            sectionHeader("Sık kullanılanlar", icon: "sparkles")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(templates) { item in
                        Button {
                            applyTemplate(item)
                        } label: {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(item.title)
                                    .font(.system(.title3, design: .rounded, weight: .black))
                                Text(item.subtitle)
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.secondary)
                                ShiftTypePill(title: String(format: "%.1fs", item.duration), color: item.kind.colorTag.color, systemImage: item.type == .night ? "moon.stars.fill" : "clock.fill")
                            }
                            .frame(width: 128, alignment: .leading)
                            .padding(Spacing.medium)
                            .glassCard(cornerRadius: 22)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private var workKindPanel: some View {
        PremiumGlassPanel {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                sectionHeader("Mesai türü", icon: "square.grid.2x2.fill")
                Picker("Mesai türü", selection: $workKind) {
                    ForEach(WorkEntryKind.allCases) { Text($0.localizedTitle).tag($0) }
                }
                .pickerStyle(.menu)

                Picker("Ekleme modu", selection: $entryMode) {
                    Text("Saat aralığı").tag(ShiftEntryMode.timeRange)
                    Text("Süreye göre").tag(ShiftEntryMode.duration)
                }
                .pickerStyle(.segmented)
            }
        }
    }

    private var timeComposer: some View {
        PremiumGlassPanel {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                sectionHeader("Zaman bestecisi", icon: "clock.fill")
                DatePicker("Tarih", selection: $date, displayedComponents: .date)
                DatePicker("Başlangıç", selection: $startTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.compact)

                if entryMode == .timeRange {
                    DatePicker("Bitiş", selection: $endTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.compact)
                } else {
                    Picker("Süre", selection: $duration) {
                        ForEach(PresetWorkDuration.allCases) { item in
                            Text(item.localizedTitle).tag(item.rawValue)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 126)

                    ShiftStatusCapsule(
                        title: "Bitiş \(computedEnd.formatted(date: .omitted, time: .shortened))",
                        subtitle: String(format: "%.1f saat", duration),
                        color: workKind.colorTag.color,
                        systemImage: "arrow.triangle.turn.up.right.circle.fill"
                    )
                }
            }
        }
    }

    private var detailPanel: some View {
        PremiumGlassPanel {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                sectionHeader("Birim ve detay", icon: "stethoscope")
                TextField("Başlık", text: $title)
                    .textInputAutocapitalization(.words)
                TextField("Departman", text: $department)
                    .textInputAutocapitalization(.words)
                TextField("Birim", text: $unit)
                    .textInputAutocapitalization(.words)
                Picker("Nöbet türü", selection: $shiftType) {
                    ForEach(ShiftType.allCases) { Text($0.localizedTitle).tag($0) }
                }
                .pickerStyle(.menu)
            }
        }
    }

    private var flagsPanel: some View {
        PremiumGlassPanel {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                sectionHeader("İşaretler", icon: "bell.badge.fill")
                Toggle("Resmi tatil mi?", isOn: $isOfficialHoliday)
                Toggle("Gece nöbeti mi?", isOn: $isNightShift)
                Toggle("Hatırlatma", isOn: $reminderEnabled)
            }
        }
    }

    private var notePanel: some View {
        PremiumGlassPanel {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                sectionHeader("Not", icon: "note.text")
                Text("Hasta adı, TC kimlik veya protokol numarası girmeyin.")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DesignColors.warning)
                TextField("Not", text: $notes, axis: .vertical)
                    .lineLimit(3...6)
            }
        }
    }

    @ViewBuilder
    private var errorView: some View {
        if let errorMessage {
            Text(errorMessage)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(DesignColors.danger)
                .padding(.horizontal, Spacing.medium)
        }
    }

    private var saveButton: some View {
        PremiumCTAButton(title: "Nöbeti kaydet", systemImage: "checkmark.circle.fill", tint: workKind.colorTag.color) {
            save()
        }
    }

    private func sectionHeader(_ title: String, icon: String) -> some View {
        Label(title, systemImage: icon)
            .font(Typography.headline)
            .foregroundStyle(
                LinearGradient(colors: [DesignColors.secondary, DesignColors.primary], startPoint: .leading, endPoint: .trailing)
            )
    }

    private func applyTemplate(_ item: ShiftTemplate) {
        HapticService.selection(enabled: appState.profile.hapticsEnabled)
        workKind = item.kind
        shiftType = item.type
        entryMode = .duration
        duration = item.duration
        startTime = Calendar.current.date(bySettingHour: item.startHour, minute: 0, second: 0, of: date) ?? startTime
        endTime = Calendar.current.date(byAdding: .minute, value: Int(item.duration * 60), to: startTime) ?? endTime
        isNightShift = item.kind == .nightWork || item.type == .night
        isOfficialHoliday = item.kind == .officialHoliday
    }

    private var computedEnd: Date {
        createShift.makeShift(
            title: title,
            date: date,
            startTime: startTime,
            endTime: nil,
            durationHours: duration,
            department: department,
            unit: unit,
            type: shiftType,
            workKind: workKind,
            isOfficialHoliday: isOfficialHoliday,
            isNightShift: isNightShift,
            reminderEnabled: reminderEnabled,
            notes: notes
        ).endDate
    }

    private func save() {
        guard !department.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !unit.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            errorMessage = "Departman ve birim boş bırakılamaz."
            HapticService.warning(enabled: appState.profile.hapticsEnabled)
            return
        }

        let shift = createShift.makeShift(
            title: title,
            date: date,
            startTime: startTime,
            endTime: entryMode == .timeRange ? endTime : nil,
            durationHours: entryMode == .duration ? duration : nil,
            department: department,
            unit: unit,
            type: shiftType,
            workKind: workKind,
            isOfficialHoliday: isOfficialHoliday,
            isNightShift: isNightShift,
            reminderEnabled: reminderEnabled,
            notes: notes
        )
        appState.addShift(shift)
        HapticService.success(enabled: appState.profile.hapticsEnabled)
        withAnimation(reduceMotion ? .default : .spring(response: 0.35, dampingFraction: 0.8)) {
            dismiss()
        }
    }
}

private struct ShiftTemplate: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let startHour: Int
    let duration: Double
    let kind: WorkEntryKind
    let type: ShiftType
}
