import SwiftUI
import ComposableArchitecture

@main
struct TCASampleApp: App {
    var body: some Scene {
        WindowGroup {
            PaletteView(
                store: Store(
                    initialState: Palette.State(),
                    reducer: Palette()
                )
            )
        }
    }
}
