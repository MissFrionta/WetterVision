import SwiftUI
import RealityKit

struct ContentView: View {
    @EnvironmentObject var viewModel: WeatherViewModel

    var body: some View {
        DioramaRealityView()
            .environmentObject(viewModel)
            .ornament(attachmentAnchor: .scene(.bottom)) {
                VStack(spacing: 12) {
                    CityPickerView()
                    WeatherInfoPanel()
                }
                .padding(16)
                .glassBackgroundEffect()
                .environmentObject(viewModel)
            }
    }
}
