//
//  TabControlView.swift
//  BeMyFamily
//
//  Created by Gucci on 4/19/24.
//
import SwiftUI

struct RootTabView: View {
    @State private var diContainer: DIContainer

    @State private var feedRouter = FeedRouter()
    @State private var searchRouter = SearchRouter()
    @State private var favoriteRouter = FavoriteRouter()
    @StateObject private var networkMonitor: NetworkMonitor

    init(diContainer: DIContainer = .shared) {
        self._diContainer = State(wrappedValue: diContainer)
        self._networkMonitor = StateObject(wrappedValue: diContainer
                                            .resolveSingleton(NetworkMonitor.self) ?? .shared)
    }

    var body: some View {

        TabView {
            if networkMonitor.isConnected == true {
                FeedRootView(router: feedRouter)
                    .tabItem { Label("Home", systemImage: "house") }

                SearchRootView(router: searchRouter)
                    .tabItem { Label("Search", systemImage: "magnifyingglass") }

                FavoriteRootView(router: favoriteRouter)
                    .tabItem { Label("Heart", systemImage: "heart") }
            } else {
                NetworkDisconnectView()
                    .tabItem { Label("connect", systemImage: "network.slash") }
            }
        }
        .environment(diContainer)
        .animation(.easeInOut, value: networkMonitor.isConnected)
    }
}

#Preview {
    RootTabView()
        .environment(DIContainer.shared)
        .preferredColorScheme(.dark)
}
