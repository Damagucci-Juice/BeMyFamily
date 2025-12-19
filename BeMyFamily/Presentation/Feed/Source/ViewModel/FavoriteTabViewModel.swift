//
//  FavoriteTabViewModel.swift
//  BeMyFamily
//
//  Created by Gucci on 6/28/24.
//

import Foundation

class FavoriteTabViewModel: ObservableObject {
    let loadFavoriteListUseCase: GetFavoriteAnimalsUseCase

    init(loadFavoriteListUseCase: GetFavoriteAnimalsUseCase) {
        self.loadFavoriteListUseCase = loadFavoriteListUseCase
    }

    @Published var favorites: [Animal]?

    func load() {
        Task { [weak self] in
            if let favorites = try? await self?.loadFavoriteListUseCase.excute() {
                self?.favorites = favorites
            }
        }
    }
}
