//
//  FavoriteTabViewModel.swift
//  BeMyFamily
//
//  Created by Gucci on 6/28/24.
//

import Foundation

class FavoriteTabViewModel: ObservableObject {
    let loadFavoriteListUseCase: LoadFavoriteListUseCase

    init(loadFavoriteListUseCase: LoadFavoriteListUseCase) {
        self.loadFavoriteListUseCase = loadFavoriteListUseCase
    }

    @Published var favorites: [Animal]?

    func load() {
        favorites = loadFavoriteListUseCase.excute()
    }
}
