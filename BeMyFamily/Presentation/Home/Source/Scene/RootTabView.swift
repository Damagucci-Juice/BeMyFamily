//
//  TabControlView.swift
//  BeMyFamily
//
//  Created by Gucci on 4/19/24.
//
import SwiftUI
import Observation

@Observable
final class DeepLinkManager {
    var selectedDesertionNo: String?
}

struct RootTabView: View {
    @State private var diContainer: DIContainer
    @State private var networkMonitor: NetworkMonitor

    @Environment(DeepLinkManager.self) var deepLinkManager
    @State private var animalToDisplay: AnimalEntity?

    @State private var feedRouter = FeedRouter()
    @State private var searchRouter = SearchRouter()
    @State private var favoriteRouter = FavoriteRouter()

    private var fetchAnAnimalUseCase: FetchAnAnimalUseCase? {
        diContainer.resolveSingleton(FetchAnAnimalUseCase.self)
    }

    init(diContainer: DIContainer = .shared) {
        self._diContainer = State(wrappedValue: diContainer)
        self._networkMonitor = State(wrappedValue: diContainer.resolveSingleton(NetworkMonitor.self) ?? .shared)
    }

    var body: some View {
        TabView {
            tabContentView
        }
        .tabViewStyle(.sidebarAdaptable)
        .environment(diContainer)
        .animation(.easeInOut, value: networkMonitor.isConnected)
        // 2. onChange 로직을 명확하게 분리
        .onChange(of: deepLinkManager.selectedDesertionNo) { _, newID in
            handleDeepLink(newID)
        }
        .fullScreenCover(item: $animalToDisplay) { animal in
            AnimalDetailView(animal)
                .environment(diContainer)
        }
    }

    // TabView 내부의 복잡한 조건문을 ViewBuilder로 추출
    @ViewBuilder
    private var tabContentView: some View {
        if networkMonitor.isConnected {
            FeedRootView(router: feedRouter)
                .tabItem { Label("Home", systemImage: "house") }

            FavoriteRootView(router: favoriteRouter)
                .tabItem { Label("Heart", systemImage: "heart") }

            SearchRootView(router: searchRouter)
                .tabItem { Label("Search", systemImage: "magnifyingglass") }
        } else {
            NetworkDisconnectView()
                .tabItem { Label("Offline", systemImage: "network.slash") }
        }
    }

    private func handleDeepLink(_ id: String?) {
        guard let id = id else { return }
        Task {
            let fetchedAnimal = await fetchAnAnimalUseCase?.execute(id: id)
            await MainActor.run {
                if let animal = try? fetchedAnimal?.get() {
                    self.animalToDisplay = animal
                }
            }
        }
    }
}

#Preview {
    RootTabView()
        .environment(DIContainer.shared)
        .environment(DeepLinkManager()) // 반드시 추가 필요
        .preferredColorScheme(.dark)
}
