//
//  FavoriteButtonViewModel.swift
//  BeMyFamily
//
//  Created by Gucci on 6/25/24.
//

import Foundation
import Observation
import Combine

@Observable
final class FavoriteButtonViewModel {
    private var animal: AnimalEntity
    private let repository: FavoriteRepository
    var isFavorite: Bool

    private var cancellables = Set<AnyCancellable>()

    init(animal: AnimalEntity, repository: FavoriteRepository) {
        self.animal = animal
        self.repository = repository
        self.isFavorite = animal.isFavorite

        self.setupBind()
    }

    func heartButtonTapped() {
        repository.toggle(animal)
    }

    private func setupBind() {
        repository.favoriteIdsPublisher
            .sink { [weak self] favoriteIds in
                self?.updateFavorites(favoriteIds)
            }
            .store(in: &cancellables)
    }

    private func updateFavorites(_ favoriteIds: Set<String>) {
        let isContain = favoriteIds.contains(animal.id)
        animal.updateFavoriteStatus(isContain)
        isFavorite = isContain
    }
}
