import SwiftUI

struct TemperatureGaugeView: View {
    let temperature: Double

    private var normalizedTemp: Double {
        // Map from -10...40 range to 0...1
        min(max((temperature + 10) / 50.0, 0), 1)
    }

    private var temperatureColor: Color {
        if temperature < 0 { return .blue }
        if temperature < 15 { return .cyan }
        if temperature < 25 { return .orange }
        return .red
    }

    var body: some View {
        VStack(spacing: 4) {
            Text(String(format: "%.0f°", temperature))
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(temperatureColor)

            Gauge(value: normalizedTemp) {
                EmptyView()
            }
            .gaugeStyle(.accessoryLinear)
            .tint(temperatureColor)
            .frame(width: 60)
        }
        .padding(8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}
