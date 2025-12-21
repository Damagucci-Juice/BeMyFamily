//
//  GetAnimalsUseCase.swift
//  BeMyFamily
//
//  Created by Gucci on 12/20/25.
//
import Foundation

final class FetchAnimalsUseCase {
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
        filter: AnimalSearchFilter,
        pageNo: Int
    ) async -> Result<(animals: [AnimalEntity], pagingInfo: Paging), Error> {
        do {
            let (newAnimals, fetchedPageInfo) = try await animalRepository.getAnimals(
                filter: filter,
                pageNo: pageNo
            )
            let favoriteIds = favoriteRepository.getIds()

            let animalsWithFavorite = newAnimals.map { animal in
                var result = animal
                result.updateFavoriteStatus(favoriteIds.contains(animal.id))
                return result
            }

            return .success((animalsWithFavorite, fetchedPageInfo))
        } catch {
            return .failure(error)
        }
    }
}
