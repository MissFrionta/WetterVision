import SwiftUI
import RealityKit

struct DioramaContentView: View {
    @Environment(WeatherViewModel.self) var viewModel

    var body: some View {
        DioramaDioramaView()
            .environment(viewModel)
            .ornament(attachmentAnchor: .scene(.bottom)) {
                VStack(spacing: 12) {
                    DioramaCityPicker()
                    DioramaWeatherPanel()
                }
                .padding(16)
                .glassBackgroundEffect()
                .environment(viewModel)
            }
    }
}
