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

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.large) {
                    templateStrip
                    sectionCard("Mesai Türü", systemImage: "square.grid.2x2.fill") {
                        Picker("Mesai türü", selection: $workKind) {
                            ForEach(WorkEntryKind.allCases) { Text($0.localizedTitle).tag($0) }
                        }
                        .pickerStyle(.menu)

                        Picker("Ekleme modu", selection: $entryMode) {
                            Text("Saat aralığına göre ekle").tag(ShiftEntryMode.timeRange)
                            Text("Süreye göre ekle").tag(ShiftEntryMode.duration)
                        }
                        .pickerStyle(.segmented)
                    }

                    sectionCard("Zaman", systemImage: "clock.fill") {
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
                            .frame(height: 120)
                            Text("Bitiş: \(computedEnd.formatted(date: .omitted, time: .shortened))")
                                .font(Typography.headline)
                                .foregroundStyle(DesignColors.primary)
                        }
                    }

                    sectionCard("Birim ve detay", systemImage: "stethoscope") {
                        TextField("Başlık", text: $title)
                        TextField("Departman", text: $department)
                        TextField("Birim", text: $unit)
                        Picker("Nöbet türü", selection: $shiftType) {
                            ForEach(ShiftType.allCases) { Text($0.localizedTitle).tag($0) }
                        }
                        .pickerStyle(.menu)
                    }

                    sectionCard("İşaretler", systemImage: "bell.badge.fill") {
                        Toggle("Resmi tatil mi?", isOn: $isOfficialHoliday)
                        Toggle("Gece nöbeti mi?", isOn: $isNightShift)
                        Toggle("Hatırlatma", isOn: $reminderEnabled)
                    }

                    sectionCard("Not", systemImage: "note.text") {
                        Text("Hasta adı, TC kimlik veya protokol numarası girmeyin.")
                            .font(.caption)
                            .foregroundStyle(DesignColors.warning)
                        TextField("Not", text: $notes, axis: .vertical)
                            .lineLimit(3...6)
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(DesignColors.danger)
                    }

                    Button {
                        save()
                    } label: {
                        Label("Nöbeti Kaydet", systemImage: "checkmark.circle.fill")
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 52)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(DesignColors.primary)
                    .controlSize(.large)
                }
                .padding(Spacing.large)
            }
            .background(AppBackground())
            .navigationTitle("Yeni Nöbet")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") { dismiss() }
                }
            }
        }
    }

    private var templateStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                template("08:00 - 16:00", startHour: 8, duration: 8, kind: .normalShift)
                template("08:00 - 20:00", startHour: 8, duration: 12, kind: .normalShift)
                template("16:00 - 00:00", startHour: 16, duration: 8, kind: .normalShift)
                template("20:00 - 08:00", startHour: 20, duration: 12, kind: .nightWork)
                template("24 saat", startHour: 8, duration: 24, kind: .normalShift)
                template("Özel", startHour: 9, duration: 7.5, kind: .customDuration)
            }
            .padding(.vertical, 2)
        }
    }

    private func template(_ text: String, startHour: Int, duration: Double, kind: WorkEntryKind) -> some View {
        Button(text) {
            HapticService.selection(enabled: appState.profile.hapticsEnabled)
            workKind = kind
            entryMode = .duration
            self.duration = duration
            startTime = Calendar.current.date(bySettingHour: startHour, minute: 0, second: 0, of: date) ?? startTime
            shiftType = duration == 24 ? .twentyFourHour : (kind == .nightWork ? .night : .day)
            isNightShift = kind == .nightWork
        }
        .font(.subheadline.weight(.semibold))
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(minHeight: 44)
        .background(.ultraThinMaterial, in: Capsule())
    }

    private func sectionCard<Content: View>(_ title: String, systemImage: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Label(title, systemImage: systemImage)
                .font(Typography.headline)
                .foregroundStyle(DesignColors.primary)
            content()
        }
        .padding(Spacing.large)
        .glassCard()
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
