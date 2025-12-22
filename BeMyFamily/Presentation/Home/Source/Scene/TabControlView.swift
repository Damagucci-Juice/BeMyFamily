//
//  TabControlView.swift
//  BeMyFamily
//
//  Created by Gucci on 4/19/24.
//

import SwiftUI

struct TabControlView: View {
    @Environment(DIContainer.self) private var diContainer

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
                        if let viewModel = diContainer.resolveFactory(FilterViewModel.self) {
                            AnimalFilterForm(viewModel: viewModel)
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

    TabControlView()
        .environment(diContainer)
        .preferredColorScheme(.dark)
}
