//
//  FavoriteButtonViewModel.swift
//  BeMyFamily
//
//  Created by Gucci on 6/25/24.
//

import Foundation
import Observation

@Observable
final class FavoriteButtonViewModel {
    private var animal: AnimalEntity
    private let repository: FavoriteRepository
    var isFavorite: Bool

    init(animal: AnimalEntity, repository: FavoriteRepository) {
        self.animal = animal
        self.repository = repository
        self.isFavorite = animal.isFavorite
    }

    func heartButtonTapped() {
        if repository.exists(id: animal.id) {
            repository.delete(id: animal.id)
        } else {
            repository.save(animal)
        }
    }
}
