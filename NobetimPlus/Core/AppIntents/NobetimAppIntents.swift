import AppIntents
import Foundation

struct ShowTodayShiftIntent: AppIntent {
    static var title: LocalizedStringResource = "Bugünkü nöbetimi göster"
    static var description = IntentDescription("Nöbetim+ içinde bugün planlı nöbet bilgisini açar.")

    func perform() async throws -> some IntentResult & ProvidesDialog {
        .result(dialog: "Bugünkü nöbet bilgilerin Nöbetim+ içinde hazır.")
    }
}

struct AddShiftIntent: AppIntent {
    static var title: LocalizedStringResource = "Yeni nöbet ekle"
    static var description = IntentDescription("Nöbetim+ içinde yeni nöbet ekleme ekranını açmak için genişletilebilir intent.")

    func perform() async throws -> some IntentResult & ProvidesDialog {
        .result(dialog: "Yeni nöbet ekleme akışı açılmaya hazır.")
    }
}

struct MonthlyHoursIntent: AppIntent {
    static var title: LocalizedStringResource = "Bu ay kaç saat çalıştım?"
    static var description = IntentDescription("MVP’de lokal hesaplama altyapısına bağlanmak üzere placeholder intent.")

    func perform() async throws -> some IntentResult & ProvidesDialog {
        .result(dialog: "Bu ay çalışma saatlerin Nöbetim+ analiz ekranında görünebilir.")
    }
}

struct NobetimShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ShowTodayShiftIntent(),
            phrases: ["\(.applicationName) bugünkü nöbetimi göster"],
            shortTitle: "Bugünkü Nöbet",
            systemImageName: "calendar"
        )
        AppShortcut(
            intent: AddShiftIntent(),
            phrases: ["\(.applicationName) yeni nöbet ekle"],
            shortTitle: "Nöbet Ekle",
            systemImageName: "calendar.badge.plus"
        )
        AppShortcut(
            intent: MonthlyHoursIntent(),
            phrases: ["\(.applicationName) bu ay kaç saat çalıştım"],
            shortTitle: "Aylık Saat",
            systemImageName: "clock"
        )
    }
}
