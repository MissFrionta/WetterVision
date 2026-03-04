import SwiftUI
import RealityKit

struct ContentView: View {
    @Environment(WeatherViewModel.self) var viewModel

    var body: some View {
        DioramaRealityView()
            .environment(viewModel)
            .ornament(attachmentAnchor: .scene(.bottom)) {
                VStack(spacing: 12) {
                    CityPickerView()
                    WeatherInfoPanel()
                }
                .padding(16)
                .glassBackgroundEffect()
                .environment(viewModel)
            }
    }
}
