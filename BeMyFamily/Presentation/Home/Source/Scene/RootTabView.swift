//
//  TabControlView.swift
//  BeMyFamily
//
//  Created by Gucci on 4/19/24.
//
import SwiftUI

struct RootTabView: View {
    @State private var diContainer = DIContainer.shared
    @State private var feedRouter = FeedRouter()
    @State private var searchRouter = SearchRouter()
    @State private var favoriteRouter = FavoriteRouter()

    var body: some View {

        TabView {
            FeedRootView(router: feedRouter)
                .tabItem { Label("Home", systemImage: "house") }

            SearchRootView(router: searchRouter)
                .tabItem { Label("Search", systemImage: "magnifyingglass") }

            FavoriteRootView(router: favoriteRouter)
                .tabItem { Label("Heart", systemImage: "heart") }
        }
        .environment(diContainer)
    }
}

#Preview {
    RootTabView()
        .environment(DIContainer.shared)
        .preferredColorScheme(.dark)
}
