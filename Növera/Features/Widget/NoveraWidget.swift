// NoveraWidget.swift
// Növera — iOS Widget Extension
// WidgetKit target ayrıca oluşturulmalıdır. Bu dosya yapı iskeleti sağlar.

import WidgetKit
import SwiftUI

// MARK: - Widget Entry
struct NoveraWidgetEntry: TimelineEntry {
    let date: Date
    let nextShiftTitle: String
    let nextShiftTime: String
    let nextShiftType: String
    let weeklyHours: Double
    let todayShiftCount: Int
}

// MARK: - Widget Provider
struct NoveraWidgetProvider: TimelineProvider {
    typealias Entry = NoveraWidgetEntry

    func placeholder(in context: Context) -> NoveraWidgetEntry {
        NoveraWidgetEntry(
            date: Date(),
            nextShiftTitle: "Acil Servis Nöbeti",
            nextShiftTime: "08:00 - 16:00",
            nextShiftType: "day",
            weeklyHours: 24.5,
            todayShiftCount: 1
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (NoveraWidgetEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NoveraWidgetEntry>) -> Void) {
        let entry = loadEntry()
        // Refresh every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadEntry() -> NoveraWidgetEntry {
        // Load from shared UserDefaults (App Group needed in production)
        // TODO: Configure App Group: group.com.novera.app
        let shifts = LocalShiftDataSource.shared.loadShifts()
        let now = Date()

        let upcoming = shifts
            .filter { $0.startDate > now }
            .sorted { $0.startDate < $1.startDate }
            .first

        let today = shifts.filter { Calendar.current.isDate($0.startDate, inSameDayAs: now) }

        let weekStart = now.startOfWeek
        let weekEnd = Calendar.current.date(byAdding: .day, value: 7, to: weekStart) ?? now
        let weekHours = shifts
            .filter { $0.startDate >= weekStart && $0.startDate < weekEnd }
            .reduce(0.0) { $0 + $1.durationInHours }

        return NoveraWidgetEntry(
            date: now,
            nextShiftTitle: upcoming?.title ?? "Nöbet yok",
            nextShiftTime: upcoming?.timeRangeFormatted ?? "—",
            nextShiftType: upcoming?.shiftType.rawValue ?? "day",
            weeklyHours: weekHours,
            todayShiftCount: today.count
        )
    }
}

// MARK: - Small Widget
struct NoveraSmallWidget: View {
    let entry: NoveraWidgetEntry

    var shiftColor: Color {
        ShiftType(rawValue: entry.nextShiftType)?.color ?? NoveraColors.primary
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(NoveraColors.primary)
                Text("Növera")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(NoveraColors.primary)
            }

            Spacer()

            VStack(alignment: .leading, spacing: 2) {
                Text("Sıradaki Nöbet")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(entry.nextShiftTitle)
                    .font(.system(size: 13, weight: .bold))
                    .lineLimit(2)
                Text(entry.nextShiftTime)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 4) {
                Circle()
                    .fill(shiftColor)
                    .frame(width: 6, height: 6)
                Text("\(entry.todayShiftCount) bugün")
                    .font(.caption2)
                    .foregroundStyle(shiftColor)
            }
        }
        .padding(12)
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [
                    Color(hue: 0.55, saturation: 0.08, brightness: 0.98),
                    Color(hue: 0.57, saturation: 0.05, brightness: 0.96)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Medium Widget
struct NoveraMediumWidget: View {
    let entry: NoveraWidgetEntry

    var body: some View {
        HStack(spacing: 12) {
            // Next shift
            VStack(alignment: .leading, spacing: 6) {
                Label("Sıradaki", systemImage: "clock.fill")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(NoveraColors.primary)

                Text(entry.nextShiftTitle)
                    .font(.system(size: 14, weight: .bold))
                    .lineLimit(2)

                Text(entry.nextShiftTime)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            // Weekly summary
            VStack(alignment: .leading, spacing: 6) {
                Label("Bu Hafta", systemImage: "chart.bar.fill")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(NoveraColors.accentGreen)

                Text(entry.weeklyHours.hoursFormatted)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(NoveraColors.accentGreen)

                Text("\(entry.todayShiftCount) nöbet bugün")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [
                    Color(hue: 0.55, saturation: 0.08, brightness: 0.98),
                    Color(hue: 0.57, saturation: 0.05, brightness: 0.96)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Widget Configuration
// NOTE: Bu widget'ı ayrı bir Widget Extension target'ına taşıyın
// Target adı: NoveraWidget
// Bundle ID: com.novera.app.widget

/*
@main
struct NoveraWidget: Widget {
    let kind: String = "NoveraWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NoveraWidgetProvider()) { entry in
            Group {
                NoveraSmallWidget(entry: entry)
            }
        }
        .configurationDisplayName("Növera")
        .description("Sıradaki nöbetinizi ve haftalık saatlerinizi görün.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
*/
