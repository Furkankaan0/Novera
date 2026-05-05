import SwiftData
import SwiftUI

enum PreviewRoot {
    @MainActor
    static func makeState() -> AppState {
        let schema = Schema([LocalShiftEntity.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [configuration])
        let state = AppState(
            shiftRepository: LocalShiftRepository(modelContext: container.mainContext),
            teamRepository: LocalTeamRepository(),
            settingsRepository: LocalSettingsRepository(defaults: .standard)
        )
        state.shifts = MockData.shifts
        state.teams = MockData.teams
        state.hasCompletedOnboarding = true
        return state
    }

    @MainActor
    static func makeRoot() -> some View {
        RootTabView(appState: makeState())
    }
}
