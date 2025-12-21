//
//  FavoriteTabView.swift
//  BeMyFamily
//
//  Created by Gucci on 6/27/24.
//

import SwiftUI

struct FavoriteTabView: View {
    @State var viewModel: FavoriteTabViewModel

    private let columns = [
        GridItem(.adaptive(minimum: 100, maximum: .infinity)),
        GridItem(.adaptive(minimum: 100, maximum: .infinity)),
        GridItem(.adaptive(minimum: 100, maximum: .infinity))
        ]

    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                LazyVGrid(columns: columns, spacing: 0.0) {
                    ForEach(viewModel.favorites) { animal in
                        NavigationLink {
                            AnimalDetailView(animal: animal)
                        } label: {
                            AnimalThumbnailView(animal: animal)
                        }
                        .tint(.primary)
                    }
                }
            }
            .onAppear(perform: viewModel.didOnAppear)
            .navigationTitle(UIConstants.App.favorite)
        }
    }
}

#Preview {
    let diContainer = DIContainer(dependencies: .init(apiService: MockFamilyService(),
                                                      favoriteStorage: UserDefaultsFavoriteStorage.shared))

    FavoriteTabView(viewModel: diContainer.makeFavoriteTabViewModel())
}
