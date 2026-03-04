import SwiftUI
import RealityKit

struct ContentView: View {

    var body: some View {
        RealityView { content in
            let snowGlobe = VoxelBuilder.buildSnowGlobe()
            content.add(snowGlobe)
        }
    }
}

#Preview(windowStyle: .volumetric) {
    ContentView()
        .environment(AppModel())
}
