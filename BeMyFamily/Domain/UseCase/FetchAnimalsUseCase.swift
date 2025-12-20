//
//  GetAnimalsUseCase.swift
//  BeMyFamily
//
//  Created by Gucci on 12/20/25.
//


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
    ) async -> Result<(animals: [AnimalDTO], pagingInfo: PagingInfo), Error> {
        do {
            let animals = try await animalRepository.getAnimals(
                filter: filter,
                pageNo: pageNo
            )
            let favoriteIds = favoriteRepository.getIds()
            
            let animalsWithFavorite = animals.map { animal in
                var updated = animal
                updated.isFavorite = favoriteIds.contains(animal.id)
                return updated
            }
            
            let hasMore = animals.count >= PagingInfo().pageSize
            let pagingInfo = PagingInfo(
                pageNo: pageNo,
                pageSize: PagingInfo().pageSize,
                hasMore: hasMore
            )
            
            return .success((animalsWithFavorite, pagingInfo))
        } catch {
            return .failure(error)
        }
    }
}
