import SwiftUI
import WidgetKit

struct NobetimWidgetEntry: TimelineEntry {
    let date: Date
    let title: String
    let subtitle: String
    let weeklyHours: Double
}

struct NobetimWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> NobetimWidgetEntry {
        NobetimWidgetEntry(date: .now, title: "Sıradaki nöbet", subtitle: "08:00 - 20:00", weeklyHours: 36)
    }

    func getSnapshot(in context: Context, completion: @escaping (NobetimWidgetEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NobetimWidgetEntry>) -> Void) {
        completion(Timeline(entries: [placeholder(in: context)], policy: .after(.now.addingTimeInterval(3600))))
    }
}

struct NobetimPlusWidgetView: View {
    var entry: NobetimWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(entry.title)
                .font(.headline)
            Text(entry.subtitle)
                .font(.title3.bold())
            Spacer()
            Text("Bu hafta \(entry.weeklyHours, specifier: "%.0f") saat")
                .font(.caption.weight(.semibold))
        }
        .containerBackground(for: .widget) {
            LinearGradient(colors: [Color.blue.opacity(0.85), Color.mint.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

struct NobetimPlusWidget: Widget {
    let kind = "NobetimPlusWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NobetimWidgetProvider()) { entry in
            NobetimPlusWidgetView(entry: entry)
        }
        .configurationDisplayName("Nöbetim+")
        .description("Sıradaki nöbet, haftalık saat ve mini takvim bilgilerini gösterir.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
