//
//  LoadFavoriteListUseCase.swift
//  BeMyFamily
//
//  Created by Gucci on 6/28/24.
//

import Foundation

class LoadFavoriteListUseCase {
    let favoriteRepository: FavoriteAnimalRepository

    init(favoriteRepository: FavoriteAnimalRepository) {
        self.favoriteRepository = favoriteRepository
    }

    func excute() -> [Animal] {
        favoriteRepository.loadFavoriteAnimlaList()
    }
}
