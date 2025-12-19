//
//  FavoriteAnimalRepositoryImpl.swift
//  BeMyFamily
//
//  Created by Gucci on 6/25/24.
//

import Foundation

class FavoriteAnimalRepositoryImpl: FavoriteAnimalRepository {
    private let storage: FavoriteStorage

    init(storage: FavoriteStorage) {
        self.storage = storage
    }

    func saveFavoriteAnimal(animal: Animal) {
        storage.add(animal: animal)
    }

    func removeFavoriteAnimal(animal: Animal) {
        storage.remove(animal: animal)
    }

    func loadFavoriteAnimlaList() -> [Animal] {
        storage.list()
    }

    func contains(animal: Animal) -> Bool {
        storage.contains(animal: animal)
    }
}
