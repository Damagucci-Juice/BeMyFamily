//
//  TabControlView.swift
//  BeMyFamily
//
//  Created by Gucci on 4/19/24.
//

import SwiftUI

struct TabControlView: View {
    @EnvironmentObject var reducer: FeedViewModel
    @EnvironmentObject var filterReducer: FilterViewModel
    @EnvironmentObject var diContainer: DIContainer

    var body: some View {
        TabView(selection: $reducer.menu) {
            ForEach(FriendMenu.allCases, id: \.self) { menu in
                switch menu {
                // MARK: - FeedView == Normal + Filter
                case .feed, .filter:
                    if menu == .feed {
                        FeedView()
                            .tabItem { Label(menu.title, systemImage: menu.image) }
                            .tag(
                                currentMenu(menu)
                            )
                    }
                // MARK: - FavoriteView
                case .favorite:
                    FavoriteTabView(viewModel: diContainer.makeFavoriteTabViewModel())
                        .tabItem { Label(menu.title, systemImage: menu.image) }
                        .tag(
                            currentMenu(menu)
                        )
                }
            }
        }
    }
}

extension TabControlView {
    // filtering list가 진행 중일 때는 현재 menu가 .feed 더라도 .filter를 반환하도록 설정
    private func currentMenu(_ menu: FriendMenu) -> FriendMenu {
        if menu == .feed {
            if filterReducer.onProcessing {
                return .filter
            } else {
                return .feed
            }
        }
        return menu
    }
}

#Preview {
    @StateObject var reducer = DIContainer.makeFeedListViewModel(DIContainer.makeFilterViewModel())
    @StateObject var diContainer = DIContainer(dependencies: .init(apiService: FamilyService()))

    return TabControlView()
        .environmentObject(reducer)
        .environmentObject(diContainer)
        .preferredColorScheme(.dark)
}
