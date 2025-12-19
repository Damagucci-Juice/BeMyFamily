//
//  LoadFavoriteListUseCase.swift
//  BeMyFamily
//
//  Created by Gucci on 6/28/24.
//

import Foundation

class LoadFavoriteListUseCase {
    let favoriteRepository: FavoriteRepository

    init(favoriteRepository: FavoriteRepository) {
        self.favoriteRepository = favoriteRepository
    }

    func excute() -> [Animal] {
        favoriteRepository.fetchAll()
    }
}
