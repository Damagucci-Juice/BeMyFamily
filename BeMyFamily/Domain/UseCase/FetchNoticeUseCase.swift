//
//  FetchNoticeUseCase.swift
//  BeMyFamily
//
//  Created by Gucci on 12/28/25.
//

import Foundation

final class FetchAnAnimalUseCase {
    private let animalRepository: AnimalRepository
    private let favoriteRepository: FavoriteRepository

    init(
        animalRepository: AnimalRepository,
        favoriteRepository: FavoriteRepository
    ) {
        self.animalRepository = animalRepository
        self.favoriteRepository = favoriteRepository
    }

    func execute(
        id: String
    ) async -> Result<AnimalEntity, Error> {
        do {
            let animal = try await animalRepository.fetchAnAnimal(id: id)
            let favoriteIds = favoriteRepository.getIds()

            let animalHeartUpdated = {
                var result = animal
                result.updateFavoriteStatus(favoriteIds.contains(animal.id))
                return result
            }()

            return .success(animalHeartUpdated)
        } catch {
            return .failure(error)
        }
    }
}
