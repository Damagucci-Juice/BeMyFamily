//
//  ToggleFavoriteUseCase.swift
//  BeMyFamily
//
//  Created by Gucci on 12/20/25.
//

import Foundation

final class ToggleFavoriteUseCase {
    private let favoriteRepository: FavoriteRepository
    
    init(favoriteRepository: FavoriteRepository) {
        self.favoriteRepository = favoriteRepository
    }
    
    func execute(animal: Animal) -> Result<Bool, Error> {
        if animal.isFavorite {
            favoriteRepository.delete(id: animal.id)
            return .success(false)
        } else {
            favoriteRepository.save(animal)
            return .success(true)
        }
    }
}
