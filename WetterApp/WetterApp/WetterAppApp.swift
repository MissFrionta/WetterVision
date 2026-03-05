//
//  WetterAppApp.swift
//  WetterApp
//
//  Created by MPC-Lab-3 on 04.03.26.
//

import SwiftUI

@main
struct WetterAppApp: App {

    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 0.9, height: 0.6, depth: 0.6, in: .meters)

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.full), in: .full)
    }
}
