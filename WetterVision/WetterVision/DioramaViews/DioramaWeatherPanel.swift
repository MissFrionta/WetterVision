import SwiftUI

struct DioramaWeatherPanel: View {
    @EnvironmentObject var viewModel: WeatherViewModel

    var body: some View {
        let weather = viewModel.currentWeather

        HStack(spacing: 20) {
            Label {
                Text(String(format: "%.0f°C", weather.temperature))
                    .font(.title2.bold())
            } icon: {
                Image(systemName: "thermometer.medium")
                    .foregroundStyle(.red)
            }

            Label {
                Text(weather.condition.rawValue)
                    .font(.subheadline)
            } icon: {
                Image(systemName: weather.condition.sfSymbol)
                    .symbolRenderingMode(.multicolor)
            }

            Label {
                Text("\(weather.humidity)%")
                    .font(.subheadline)
            } icon: {
                Image(systemName: "humidity.fill")
                    .foregroundStyle(.cyan)
            }

            Label {
                Text(String(format: "%.0f km/h", weather.windSpeed))
                    .font(.subheadline)
            } icon: {
                Image(systemName: "wind")
                    .foregroundStyle(.teal)
            }
        }
    }
}
