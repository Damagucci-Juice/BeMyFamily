//
//  FavoriteRoute.swift
//  BeMyFamily
//
//  Created by Gucci on 12/23/25.
//


import SwiftUI

enum FavoriteRoute: Hashable {
    case detail(entity: AnimalEntity)
}

@Observable
final class FavoriteRouter {
    var path = NavigationPath()
}

struct FavoriteRootView: View {
    @Bindable var router: FavoriteRouter
    @Environment(DIContainer.self) var diContainer

    var body: some View {
        NavigationStack(path: $router.path) {
            if let viewModel = diContainer.resolveFactory(FavoriteViewModel.self) {
                FavoriteView(viewModel: viewModel)
                    .navigationDestination(for: FavoriteRoute.self) { route in
                        switch route {
                        case .detail(let animal):
                            AnimalDetailView(animal)
                        }
                    }
            }
        }
    }
}
