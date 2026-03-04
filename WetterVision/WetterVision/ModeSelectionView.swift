import SwiftUI

struct ModeSelectionView: View {
    @Environment(WeatherViewModel.self) var viewModel

    var body: some View {
        if let mode = viewModel.appMode {
            switch mode {
            case .classic:
                ContentView()
                    .environment(viewModel)
            case .diorama:
                DioramaContentView()
                    .environment(viewModel)
            }
        } else {
            modeSelection
        }
    }

    private var modeSelection: some View {
        VStack(spacing: 24) {
            Text("WetterVision")
                .font(.largeTitle.bold())

            Text("Darstellungsmodus wählen")
                .font(.title3)
                .foregroundStyle(.secondary)

            HStack(spacing: 20) {
                modeCard(
                    mode: .classic,
                    icon: "cube.fill",
                    title: "Klassisch",
                    description: "Programmatische 3D-Formen"
                )

                modeCard(
                    mode: .diorama,
                    icon: "mountain.2.fill",
                    title: "Diorama",
                    description: "Hochwertige 3D-Assets"
                )
            }
        }
        .padding(32)
    }

    private func modeCard(mode: AppMode, icon: String, title: String, description: String) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                viewModel.appMode = mode
            }
        } label: {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundStyle(.tint)

                Text(title)
                    .font(.title2.bold())

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 160, height: 160)
            .padding(16)
        }
        .buttonStyle(.plain)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .hoverEffect()
    }
}
