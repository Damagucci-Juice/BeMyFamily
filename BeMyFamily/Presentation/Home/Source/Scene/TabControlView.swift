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

        // 1. TabView에 selection 바인딩을 반드시 연결해야 합니다.
        TabView(selection: $container.currentTap) {

            // 2. ForEach에는 바인딩($)이 아닌 일반 배열을 넣으세요.
            ForEach(FriendMenu.allCases, id: \.self) { menu in
                Group {
                    switch menu {
                    case .feed:
                        FeedView(viewModel: diContainer.makeFeedListViewModel())
                    case .filter:
                        Text("Filter View Content")
                    case .favorite:
                        FavoriteTabView(viewModel: diContainer.makeFavoriteTabViewModel())
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
    @Previewable var diContainer = DIContainer(dependencies: .init(apiService: MockFamilyService(),
                                                             favoriteStorage: UserDefaultsFavoriteStorage.shared))
    TabControlView()
        .environment(diContainer)
        .preferredColorScheme(.dark)
}
