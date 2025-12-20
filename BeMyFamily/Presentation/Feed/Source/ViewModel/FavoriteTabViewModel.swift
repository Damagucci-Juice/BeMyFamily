//
//  FavoriteTabViewModel.swift
//  BeMyFamily
//
//  Created by Gucci on 6/28/24.
//

import Foundation

class FavoriteTabViewModel: ObservableObject {
    private let loadFavoriteListUseCase: GetFavoriteAnimalsUseCase

    init(loadFavoriteListUseCase: GetFavoriteAnimalsUseCase) {
        self.loadFavoriteListUseCase = loadFavoriteListUseCase
    }

    @Published var favorites: [AnimalDTO]?

    func load() {
        favorites = loadFavoriteListUseCase.excute()
    }
}
