import SwiftUI
import RealityKit
import Spatial

struct DioramaGestures: ViewModifier {
    @Environment(WeatherViewModel.self) var viewModel

    func body(content: Content) -> some View {
        content
            .gesture(rotateGesture)
            .gesture(scaleGesture)
    }

    private var rotateGesture: some Gesture {
        RotateGesture3D()
            .targetedToAnyEntity()
            .onChanged { value in
                let rotation = value.rotation
                viewModel.updateRotation(by: rotation)
            }
            .onEnded { _ in
                viewModel.commitRotation()
            }
    }

    private var scaleGesture: some Gesture {
        MagnifyGesture()
            .targetedToAnyEntity()
            .onChanged { value in
                viewModel.updateScale(by: Double(value.magnification))
            }
            .onEnded { _ in
                viewModel.commitScale()
            }
    }
}

extension View {
    func dioramaGestures() -> some View {
        modifier(DioramaGestures())
    }
}
