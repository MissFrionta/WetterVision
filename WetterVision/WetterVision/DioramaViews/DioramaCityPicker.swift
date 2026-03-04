import SwiftUI

struct DioramaCityPicker: View {
    @Environment(WeatherViewModel.self) var viewModel

    var body: some View {
        HStack(spacing: 10) {
            ForEach(Array(viewModel.cities.enumerated()), id: \.element.id) { index, city in
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.selectCity(at: index)
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: city.condition.sfSymbol)
                            .font(.title2)
                            .symbolRenderingMode(.multicolor)
                        Text(city.cityName)
                            .font(.caption)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(viewModel.selectedCityIndex == index
                              ? Color.accentColor.opacity(0.3)
                              : Color.clear)
                )
            }
        }
    }
}
