//
//  TabControlView.swift
//  BeMyFamily
//
//  Created by Gucci on 4/19/24.
//
import SwiftUI

struct TabControlView: View {
    @State private var diContainer = DIContainer.shared

    var body: some View {
        TabView(selection: $diContainer.currentTap) {
            // Feed 탭
            if let feedVM = diContainer.resolveFactory(FeedViewModel.self) {
                FeedView(viewModel: feedVM)
                    .tabItem {
                        Label(FriendMenu.feed.title, systemImage: FriendMenu.feed.image)
                    }
                    .tag(FriendMenu.feed)
            }

            // Filter 탭
            if let filterVM = diContainer.resolveFactory(FilterViewModel.self) {
                AnimalFilterForm(viewModel: filterVM)
                .tabItem {
                    Label(FriendMenu.filter.title, systemImage: FriendMenu.filter.image)
                }
                .tag(FriendMenu.filter)
            }

            // Favorite 탭
            if let favTabVM = diContainer.resolveFactory(FavoriteTabViewModel.self) {
                FavoriteTabView(viewModel: favTabVM)
                    .tabItem {
                        Label(FriendMenu.favorite.title, systemImage: FriendMenu.favorite.image)
                    }
                    .tag(FriendMenu.favorite)
            }
        }
        .environment(diContainer)
    }
}


#Preview {
    TabControlView()
        .environment(DIContainer.shared)
        .preferredColorScheme(.dark)
}
