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
    static let shared = DIContainer()

    private var singletons: [String: Any] = [:]
    private var factories: [String: Any] = [:]
    var currentTap: FriendMenu = .feed

    private init() {
        setupDependencies()
    }

    private func setupDependencies() {
        // MARK: - Singleton
        // enroll service
        registerSingleton(FamilyService.self, instance: FamilyService.shared)
        registerSingleton(UserDefaultsFavoriteStorage.self, instance: UserDefaultsFavoriteStorage.shared)

        let coordinator = Coordinator(container: self)
        registerSingleton(Coordinator.self, instance: coordinator)

        // enroll repository
        if let storage = resolveSingleton(UserDefaultsFavoriteStorage.self) {
            registerSingleton(FavoriteRepositoryImpl.self, instance: FavoriteRepositoryImpl(storage: storage))
        }

        if let service = resolveSingleton(FamilyService.self) {
            registerSingleton(AnimalRepositoryImpl.self, instance: AnimalRepositoryImpl(service: service))
            registerSingleton(MetadataRepositoryImpl.self, instance: MetadataRepositoryImpl(service: service))
        }

        // enroll usecage
        if let metaRepo = resolveSingleton(MetadataRepositoryImpl.self) {
            let loadInfoUsecase = LoadMetaDataUseCase(metadataRepository: metaRepo)
            registerSingleton(LoadMetaDataUseCase.self,
                              instance: loadInfoUsecase)

            Task.detached(priority: .userInitiated) {
                let result = await loadInfoUsecase.execute()
                if case .success(let data) = result {
                    await MainActor.run {
                        self.registerSingleton(ProvinceMetadata.self, instance: data)
                    }
                }
            }
        }

        if let favoriteRepo = resolveSingleton(FavoriteRepositoryImpl.self),
           let animalRepo = resolveSingleton(AnimalRepositoryImpl.self) {
            registerSingleton(FetchAnimalsUseCase.self,
                              instance: FetchAnimalsUseCase(
                                animalRepository: animalRepo,
                                favoriteRepository: favoriteRepo
                              ))
        }

        // MARK: - ViewModels(Factory)
        registerFactory(FeedViewModel.self) { [weak self] in
            guard let self = self,
                  let useCase = self.resolveSingleton(FetchAnimalsUseCase.self),
                  let repo = self.resolveSingleton(FavoriteRepositoryImpl.self)
            else {
                fatalError("Failed to resolve FetchAnimalsUseCase")
            }
            return FeedViewModel(fetchAnimalsUseCase: useCase, favorRepo: repo)
        }

        registerFactory(FavoriteButtonViewModel.self) { [weak self] animal in
            guard let self = self,
                  let repository = self.resolveSingleton(FavoriteRepositoryImpl.self) else {
                fatalError("Failed to resolve ToggleFavoriteUseCase")
            }
            return FavoriteButtonViewModel(animal: animal, repository: repository)
        }

        registerFactory(FavoriteTabViewModel.self) { [weak self] in
            guard let self = self,
                  let repo = self.resolveSingleton(FavoriteRepositoryImpl.self) else {
                fatalError("Failed to resolve GetFavoriteAnimalsUseCase")
            }
            return FavoriteTabViewModel(repository: repo)
        }

        // FilterViewModel 등록 (화면 전환 클로저를 파라미터로 받음)
        registerFactory(FilterViewModel.self) { [weak self] (onSearch: @escaping ([AnimalSearchFilter]) -> Void) in
            guard let self, let useCase = self.resolveSingleton(LoadMetaDataUseCase.self) else {
                fatalError("...")
            }
            return FilterViewModel(useCase: useCase, onSearchCompleted: onSearch)
        }

        // SearchResultViewModel 등록 (필터 배열을 파라미터로 받음)
        registerFactory(SearchResultViewModel.self) { [weak self] (filters: [AnimalSearchFilter]) in
            guard let self, let useCase = self.resolveSingleton(FetchAnimalsUseCase.self) else {
                fatalError("...")
            }
            let vm = SearchResultViewModel(useCase: useCase)
            vm.setupFilters(filters) // 생성 시점에 초기화 완료
            return vm
        }
    }

    // MARK: - Singleton 관리
    private func registerSingleton<T>(_ type: T.Type, instance: T) {
        let key = String(describing: type)
        singletons[key] = instance
    }

    func resolveSingleton<T>(_ type: T.Type) -> T? {
        let key = String(describing: type)
        return singletons[key] as? T
    }

    // MARK: - Factory (파라미터 없음)
    private func registerFactory<T>(_ type: T.Type, factory: @escaping () -> T) {
        let key = String(describing: type)
        factories[key] = factory
    }

    func resolveFactory<T>(_ type: T.Type) -> T? {
        let key = String(describing: type)
        guard let factory = factories[key] as? () -> T else {
            return nil
        }
        return factory()
    }

    // MARK: - Factory 관리 (파라미터 1개)
    private func registerFactory<T, P>(_ type: T.Type, factory: @escaping (P) -> T) {
        let key = String(describing: type)
        factories[key] = factory
    }

    func resolveFactory<T, P>(_ type: T.Type, parameter: P) -> T? {
        let key = String(describing: type)
        guard let factory = factories[key] as? (P) -> T else {
            return nil
        }
        return factory(parameter)
    }
}
