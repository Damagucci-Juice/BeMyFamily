//
//  TabControlView.swift
//  BeMyFamily
//
//  Created by Gucci on 4/19/24.
//

import SwiftUI

struct TabControlView: View {
    @Environment(DIContainer.self) private var diContainer
    @State private var coordinator: Coordinator

    init(coordinator: Coordinator) {
        self._coordinator = State(wrappedValue: coordinator)
    }

    var body: some View {
        @Bindable var container = diContainer

        TabView(selection: $container.currentTap) {
            ForEach(FriendMenu.allCases, id: \.self) { menu in
                Group {
                    switch menu {
                    case .feed:
                        if let feedVM = diContainer.resolveFactory(FeedViewModel.self) {
                            FeedView(viewModel: feedVM)
                        }
                    case .filter:
                        NavigationStack(path: $coordinator.path) {
                            coordinator.build(.filter)
                                .navigationDestination(for: SearchFlow.self) { flow in
                                    coordinator.build(flow)
                                }
                        }

                    case .favorite:
                        if let favTabVM = diContainer.resolveFactory(FavoriteTabViewModel.self) {
                            FavoriteTabView(viewModel: favTabVM)
                        }
                    }
                }
                .tabItem {
                    Label(menu.title, systemImage: menu.image)
                }
                .tag(menu)
            }
        }
    }
}

#Preview {
    @Previewable var diContainer = DIContainer.shared

    TabControlView(coordinator: diContainer.resolveSingleton(Coordinator.self)!)
        .environment(diContainer)
        .preferredColorScheme(.dark)
}
