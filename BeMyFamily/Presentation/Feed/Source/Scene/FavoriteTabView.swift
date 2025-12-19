//
//  FavoriteTabView.swift
//  BeMyFamily
//
//  Created by Gucci on 6/27/24.
//

import SwiftUI

struct FavoriteTabView: View {
    @ObservedObject var viewModel: FavoriteTabViewModel

    private let columns = [
        GridItem(.adaptive(minimum: 100, maximum: .infinity)),
        GridItem(.adaptive(minimum: 100, maximum: .infinity)),
        GridItem(.adaptive(minimum: 100, maximum: .infinity))
        ]

    var body: some View {
        NavigationStack {
            VStack {
                if let favorites = viewModel.favorites {
                    if favorites.isEmpty {
                        EmptyView()
                    } else {
                        ScrollView(.vertical) {
                            LazyVGrid(columns: columns, spacing: 0.0) {
                                ForEach(favorites) { animal in
                                    NavigationLink {
                                        AnimalDetailView(animal: animal)
                                    } label: {
                                        AnimalThumbnailView(animal: animal)
                                    }
                                    .tint(.primary)
                                }
                            }
                        }
                    }
                }
            }
            .onAppear(perform: viewModel.load)
            .navigationTitle(UIConstants.App.favorite)
        }
    }
}

#Preview {
    let diContainer = DIContainer(dependencies: .init(apiService: FamilyService()))

    return FavoriteTabView(viewModel: diContainer.makeFavoriteTabViewModel())
}
