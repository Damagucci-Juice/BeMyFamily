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
    let diContainer = DIContainer.shared
    if let favoriteVM = diContainer.resolveFactory(FavoriteViewModel.self) {
        FavoriteView(viewModel: favoriteVM)
    }
}
