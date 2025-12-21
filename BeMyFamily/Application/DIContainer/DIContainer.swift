//
//  DIContainer.swift
//  BeMyFamily
//
//  Created by Gucci on 5/6/24.
//

import Foundation
import Observation

@Observable
final class DIContainer {
    static let shared = DIContainer(dependencies: .init(
        apiService: FamilyService.shared,
        favoriteStorage: UserDefaultsFavoriteStorage.shared
    ))

    struct Dependencies {
        let apiService: SearchService
        let favoriteStorage: FavoriteStorage
    }

    private let dependencies: Dependencies

    private init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    var currentTap: FriendMenu = .feed

    func makeFeedListViewModel() -> FeedViewModel {
        FeedViewModel(fetchAnimalsUseCase: makeFetchAnimalsUseCase())
    }

    func makeFilterViewModel() -> FilterViewModel {
        return FilterViewModel()
    }

    func makeFetchAnimalsUseCase() -> FetchAnimalsUseCase {
        FetchAnimalsUseCase(
            animalRepository: makeAnimalRepository(),
            favoriteRepository: makeFavoriteRepository()
        )
    }

    func makeAnimalRepository() -> AnimalRepository {
        AnimalRepositoryImpl(service: dependencies.apiService)
    }

    // MARK: - Favorites

    func makeFavoriteTabViewModel() -> FavoriteTabViewModel {
        FavoriteTabViewModel(getFavoriteAnimalsUseCase: makeLoadFavoriteUseCase())
    }

    func makeLoadFavoriteUseCase() -> GetFavoriteAnimalsUseCase {
        GetFavoriteAnimalsUseCase(favoriteRepository: makeFavoriteRepository())
    }

    func makeFavoriteButtonViewModel(with animal: AnimalEntity) -> FavoriteButtonViewModel {
        FavoriteButtonViewModel(
            animal: animal,
            toggleUseCase: makeToggleFavortieUseCase(makeFavoriteRepository())
        )
    }

    func makeFavoriteRepository() -> FavoriteRepository {
        FavoriteRepositoryImpl(
            storage: dependencies.favoriteStorage
        )
    }

    func makeToggleFavortieUseCase(_ repo: FavoriteRepository) -> ToggleFavoriteUseCase {
        ToggleFavoriteUseCase(favoriteRepository: repo)
    }

    func makeLoadPrerequisiteDataUseCase() -> LoadPrerequisiteDataUseCase {
        LoadPrerequisiteDataUseCase(metadataRepository: makeMetaDataRepository())
    }

    func makeMetaDataRepository() -> MetadataRepository {
        MetadataRepositoryImpl(service: dependencies.apiService)
    }
}
