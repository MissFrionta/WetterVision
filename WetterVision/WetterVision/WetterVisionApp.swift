// Test-Kommentar
import SwiftUI

@main
struct WetterVisionApp: App {
    @State private var viewModel = WeatherViewModel()

    var body: some Scene {
        WindowGroup(id: "main-volume") {
            ModeSelectionView()
                .environment(viewModel)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 0.8, height: 0.6, depth: 0.8, in: .meters)
    }
}
