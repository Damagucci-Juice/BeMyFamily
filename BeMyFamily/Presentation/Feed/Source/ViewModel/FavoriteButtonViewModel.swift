//
//  FavoriteButtonViewModel.swift
//  BeMyFamily
//
//  Created by Gucci on 6/25/24.
//

import Foundation

class FavoriteButtonViewModel: ObservableObject {
    private let animal: Animal
    private let repository: FavoriteRepository

    init(animal: Animal, repository: FavoriteRepository) {
        self.animal = animal
        self.repository = repository
        isFavorite = repository.contains(animal: animal)
    }

    @Published var isFavorite: Bool

    func toggle() {
        if isFavorite {
            repository.removeFavoriteAnimal(animal: animal)
        } else {
            repository.saveFavoriteAnimal(animal: animal)
        }

        isFavorite = repository.contains(animal: animal)
    }
}
