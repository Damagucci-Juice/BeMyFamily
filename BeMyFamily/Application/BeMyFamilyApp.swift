//
//  BeMyFamilyApp.swift
//  BeMyFamily
//
//  Created by Gucci on 4/9/24.
//

import SwiftUI

@main
struct BeMyFamilyApp: App {
    @State private var diContainer: DIContainer

    init() {
        _diContainer = State(wrappedValue: .shared)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(diContainer)
                .preferredColorScheme(.dark)
        }
    }
}
