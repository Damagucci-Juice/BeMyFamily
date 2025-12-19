//
//  DIContainer.swift
//  BeMyFamily
//
//  Created by Gucci on 5/6/24.
//

import Foundation

class DIContainer: ObservableObject {
    struct Dependencies {
        // TODO: - 이미지 서비스 여기에 둬야함
        let apiService: SearchService
    }

    private let dependencies: Dependencies

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    // TODO: - Cache 여기에 둬야함
    lazy var favoriteAnimalStorage: FavoriteStorage = UserDefaultsFavoriteStorage()

    // TODO: - static 걷어내기
    static func makeFeedListViewModel(_ viewModel: FilterViewModel, service: SearchService = FamilyService()) -> FeedViewModel {
        return FeedViewModel(service: service, viewModel: viewModel)
    }

    static func makeFilterViewModel() -> FilterViewModel {
        return FilterViewModel()
    }

    static func makeProvinceViewModel(service: SearchService = FamilyService()) -> ProvinceViewModel {
        return ProvinceViewModel(service: service)
    }

    // MARK: - Favorites

    func makeFavoriteTabViewModel() -> FavoriteTabViewModel {
        FavoriteTabViewModel(loadFavoriteListUseCase: makeLoadFavoriteUseCase())
    }

    func makeLoadFavoriteUseCase() -> LoadFavoriteListUseCase {
        LoadFavoriteListUseCase(favoriteRepository: makeFavoriteRepository())
    }

    func makeFavoriteButtonViewModel(with animal: Animal) -> FavoriteButtonViewModel {
        FavoriteButtonViewModel(
            animal: animal,
            repository: makeFavoriteRepository()
        )
    }

    func makeFavoriteRepository() -> FavoriteAnimalRepository {
        FavoriteAnimalRepositoryImpl(
            storage: favoriteAnimalStorage
        )
    }
}
