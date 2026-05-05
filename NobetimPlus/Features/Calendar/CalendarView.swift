import SwiftUI

enum CalendarMode: String, CaseIterable, Identifiable {
    case month = "Aylık"
    case week = "Haftalık"
    case list = "Liste"
    case timeline = "Timeline"

    var id: String { rawValue }
}

struct CalendarView: View {
    @ObservedObject var appState: AppState
    @State private var selectedDate = Date()
    @State private var mode: CalendarMode = .month
    @State private var detailDate: Date?

    private let calendar = Calendar.current

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.large) {
                    Picker("Takvim görünümü", selection: $mode) {
                        ForEach(CalendarMode.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .padding(.top, Spacing.medium)

                    if mode == .month || mode == .week {
                        calendarGrid
                    } else {
                        listView
                    }
                }
                .padding(Spacing.large)
            }
            .navigationTitle("Takvim")
            .sheet(item: Binding(
                get: { detailDate.map(DateSelection.init(date:)) },
                set: { detailDate = $0?.date }
            )) { selection in
                DayDetailSheet(date: selection.date, shifts: appState.shifts.shifts(on: selection.date), appState: appState)
                    .presentationDetents([.medium, .large])
            }
        }
    }

    private var calendarGrid: some View {
        let days = visibleDays
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 10) {
            ForEach(days, id: \.self) { day in
                CalendarDayCell(date: day, shifts: appState.shifts.shifts(on: day), isSelected: calendar.isDate(day, inSameDayAs: selectedDate)) {
                    selectedDate = day
                    detailDate = day
                }
            }
        }
        .padding(Spacing.medium)
        .glassCard()
    }

    private var listView: some View {
        LazyVStack(spacing: Spacing.medium) {
            if appState.shifts.isEmpty {
                EmptyStateView(title: "Henüz nöbet yok", message: "Yeni nöbet ekleyerek takvimi oluşturmaya başlayabilirsin.", systemImage: "calendar.badge.plus")
            }
            ForEach(appState.shifts.sorted { $0.startDate < $1.startDate }) { shift in
                ShiftTimelineCard(shift: shift, duration: appState.calculator.calculateShiftDuration(shift), estimatedIncome: estimatedIncome(for: shift))
            }
        }
    }

    private var visibleDays: [Date] {
        if mode == .week {
            let start = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
            return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
        }

        let interval = calendar.dateInterval(of: .month, for: selectedDate) ?? DateInterval(start: selectedDate, duration: 30 * 24 * 3600)
        let startWeek = calendar.dateInterval(of: .weekOfYear, for: interval.start)?.start ?? interval.start
        return (0..<42).compactMap { calendar.date(byAdding: .day, value: $0, to: startWeek) }
    }

    private func estimatedIncome(for shift: Shift) -> Double? {
        let hours = appState.calculator.calculateShiftDuration(shift)
        switch shift.workKind {
        case .overtime, .shortExtra:
            return hours * appState.profile.overtimeHourlyRate
        case .officialHoliday:
            return hours * appState.profile.holidayHourlyRate
        default:
            return nil
        }
    }
}

struct DateSelection: Identifiable {
    var id: Date { date }
    var date: Date
}

struct CalendarDayCell: View {
    var date: Date
    var shifts: [Shift]
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 7) {
                Text(date.formatted(.dateTime.day()))
                    .font(.subheadline.weight(isSelected ? .bold : .semibold))
                    .foregroundStyle(isSelected ? .white : .primary)
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(shifts.prefix(3)) { shift in
                        HStack(spacing: 4) {
                            Circle().fill(shift.colorTag.color).frame(width: 6, height: 6)
                            Text(shortLabel(for: shift))
                                .font(.caption2.weight(.semibold))
                                .lineLimit(1)
                        }
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(8)
            .frame(minHeight: 86, alignment: .topLeading)
            .frame(maxWidth: .infinity)
            .background(isSelected ? DesignColors.primary : .white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(date.formatted(date: .abbreviated, time: .omitted)), \(shifts.count) mesai")
    }

    private func shortLabel(for shift: Shift) -> String {
        if [.overtime, .officialHoliday, .shortExtra, .customDuration].contains(shift.workKind) {
            return "\(String(format: "%.1fs", WorkCalculationEngine().calculateShiftDuration(shift))) \(shift.workKind.localizedTitle)"
        }
        return "\(shift.startDate.formatted(date: .omitted, time: .shortened)) \(shift.title)"
    }
}

struct DayDetailSheet: View {
    var date: Date
    var shifts: [Shift]
    @ObservedObject var appState: AppState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.medium) {
                    if shifts.isEmpty {
                        EmptyStateView(title: "Bu gün boş", message: "Aynı güne birden fazla mesai ekleyebilirsin.", systemImage: "calendar")
                    }
                    ForEach(shifts) { shift in
                        ShiftTimelineCard(shift: shift, duration: appState.calculator.calculateShiftDuration(shift), estimatedIncome: nil)
                    }
                    PremiumMetricCard(title: "Günlük toplam çalışma", value: String(format: "%.1fs", totalHours), footnote: "Aynı gündeki tüm mesailer", color: DesignColors.primary, systemImage: "sum")
                }
                .padding(Spacing.large)
            }
            .navigationTitle(date.formatted(date: .abbreviated, time: .omitted))
            .toolbar {
                Button("Ekle") { appState.activeSheet = .addShift }
            }
        }
    }

    private var totalHours: Double {
        shifts.reduce(0) { $0 + appState.calculator.calculateShiftDuration($1) }
    }
}
