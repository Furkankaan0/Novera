import SwiftData
import SwiftUI

@main
@MainActor
struct NobetimPlusApp: App {
    private let modelContainer: ModelContainer
    @StateObject private var appState: AppState

    init() {
        do {
            let schema = Schema([LocalShiftEntity.self])
            let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            let container = try ModelContainer(for: schema, configurations: [configuration])
            self.modelContainer = container
            _appState = StateObject(
                wrappedValue: AppState(
                    shiftRepository: LocalShiftRepository(modelContext: container.mainContext),
                    teamRepository: LocalTeamRepository(),
                    settingsRepository: LocalSettingsRepository()
                )
            )
        } catch {
            fatalError("SwiftData container oluşturulamadı: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootTabView(appState: appState)
                .modelContainer(modelContainer)
        }
    }
}
