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
        _diContainer = State(
            wrappedValue: .init(
                dependencies: .init(apiService: FamilyService.shared,
                                    favoriteStorage: UserDefaultsFavoriteStorage.shared)
            )
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(diContainer)
                .preferredColorScheme(.dark)
        }
    }
}
