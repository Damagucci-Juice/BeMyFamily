//
//  FeedRouterView.swift
//  BeMyFamily
//
//  Created by Gucci on 12/23/25.
//

import SwiftUI

enum FeedRoute: Hashable {
    case detail(entity: AnimalEntity)
}

@Observable
final class FeedRouter {
    var path = NavigationPath()
}

struct FeedRootView: View {
    @Bindable var router: FeedRouter
    @Environment(DIContainer.self) var diContainer

    var body: some View {
        NavigationStack(path: $router.path) {
            if let viewModel = diContainer.resolveFactory(FeedViewModel.self) {
                FeedView(viewModel: viewModel)
                    .navigationDestination(for: FeedRoute.self) { route in
                        switch route {
                        case .detail(let animal):
                            AnimalDetailView(animal)
                        }
                    }
            }
        }
    }
}
