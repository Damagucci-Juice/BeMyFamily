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
        isFavorite = repository.exists(id: animal.id)
    }

    @Published var isFavorite: Bool

    func toggle() {
        if isFavorite {
            repository.delete(id: animal.id)
        } else {
            repository.save(animal)
        }

        isFavorite = repository.exists(id: animal.id)
    }
}
