import SwiftUI
import RealityKit

struct DioramaContentView: View {
    @EnvironmentObject var viewModel: WeatherViewModel

    var body: some View {
        DioramaDioramaView()
            .environmentObject(viewModel)
            .ornament(attachmentAnchor: .scene(.bottom)) {
                VStack(spacing: 12) {
                    DioramaCityPicker()
                    DioramaWeatherPanel()
                }
                .padding(16)
                .glassBackgroundEffect()
                .environmentObject(viewModel)
            }
    }
}
