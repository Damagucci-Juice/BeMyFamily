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
        // ✅ 단순하게! return 없이, AnyView 없이
        if let coordinator = diContainer.resolveSingleton(Coordinator.self) {
            ContentView(coordinator: coordinator, diContainer: diContainer)
        } else {
            Text("Coordinator를 찾을 수 없습니다")
        }
    }
}

// ✅ 별도 View로 분리
private struct ContentView: View {
    @Bindable var coordinator: Coordinator
    @Bindable var diContainer: DIContainer

    var body: some View {
        NavigationStack(path: $coordinator.path) {
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
                VStack(spacing: 20) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)

                    Text("동물 검색")
                        .font(.title)
                        .fontWeight(.semibold)

                    Text("원하는 조건으로 동물을 검색해보세요")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Button {
                        coordinator.push(.filter)
                    } label: {
                        Label("필터 설정하기", systemImage: "slider.horizontal.3")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal)
                }
                .tabItem {
                    Label(FriendMenu.filter.title, systemImage: FriendMenu.filter.image)
                }
                .tag(FriendMenu.filter)

                // Favorite 탭
                if let favTabVM = diContainer.resolveFactory(FavoriteTabViewModel.self) {
                    FavoriteTabView(viewModel: favTabVM)
                        .tabItem {
                            Label(FriendMenu.favorite.title, systemImage: FriendMenu.favorite.image)
                        }
                        .tag(FriendMenu.favorite)
                }
            }
            .navigationDestination(for: SearchFlow.self) { flow in
                coordinator.build(flow)
            }
        }
        .environment(coordinator)
    }
}

#Preview {
    TabControlView()
        .environment(DIContainer.shared)
        .preferredColorScheme(.dark)
}
