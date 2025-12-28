//
//  FavoriteTabView.swift
//  BeMyFamily
//
//  Created by Gucci on 6/27/24.
//

import SwiftUI

struct FavoriteView: View {
    @State var viewModel: FavoriteViewModel

    private let columns = [
        GridItem(.adaptive(minimum: 100, maximum: .infinity)),
        GridItem(.adaptive(minimum: 100, maximum: .infinity)),
        GridItem(.adaptive(minimum: 100, maximum: .infinity))
        ]

    var body: some View {
        ScrollView(.vertical) {
            if viewModel.favorites.isEmpty {
                ContentUnavailableView(
                    "하트 버튼을 눌러 \n좋아하는 동물을 찾아볼까요?",
                    systemImage: "heart.gauge.open"
                )
                .padding(.top, 100)
            } else {
                LazyVGrid(columns: columns, spacing: 0.0) {
                    ForEach(viewModel.favorites) { animal in
                        NavigationLink(value: FavoriteRoute.detail(entity: animal)) {
                            AnimalThumbnailView(animal: animal)
                        }
                    }
                }
            }
        }
        .onAppear(perform: viewModel.didOnAppear)
        .navigationTitle(UIConstants.App.favorite)
    }
}

#Preview {
    let diContainer = DIContainer.shared
    if let favoriteVM = diContainer.resolveFactory(FavoriteViewModel.self) {
        FavoriteView(viewModel: favoriteVM)
    }
}
