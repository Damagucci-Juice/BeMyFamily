//
//  DIContainer.swift
//  BeMyFamily
//
//  Created by Gucci on 5/6/24.
//

import Foundation
import Observation
import UIKit

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
        registerSingleton(NetworkMonitor.self, instance: NetworkMonitor.shared)

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

            registerSingleton(FetchAnAnimalUseCase.self, instance: FetchAnAnimalUseCase(
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

        registerFactory(AnimalDetailViewModel.self) { [weak self] in
            guard let self = self else { fatalError("Failed to resolve AnimalDetailViewModel") }
            return AnimalDetailViewModel()
        }

        registerFactory(FavoriteButtonViewModel.self) { [weak self] animal in
            guard let self = self,
                  let repository = self.resolveSingleton(FavoriteRepositoryImpl.self) else {
                fatalError("Failed to resolve ToggleFavoriteUseCase")
            }
            return FavoriteButtonViewModel(animal: animal, repository: repository)
        }

        registerFactory(FavoriteViewModel.self) { [weak self] in
            guard let self = self,
                  let repo = self.resolveSingleton(FavoriteRepositoryImpl.self) else {
                fatalError("Failed to resolve GetFavoriteAnimalsUseCase")
            }
            return FavoriteViewModel(repository: repo)
        }

        // FilterViewModel 등록 (화면 전환 클로저를 파라미터로 받음)
        registerFactory(FilterViewModel.self) { [weak self] in
            guard let useCase = self?.resolveSingleton(LoadMetaDataUseCase.self)
            else {
                fatalError("너무 빨리 탭이 전환되면 발생함")
            }
            return FilterViewModel(useCase: useCase)
        }

        // SearchResultViewModel 등록 (필터 배열을 파라미터로 받음)
        Task { @MainActor in
            registerFactory(SearchResultViewModel.self) { [weak self]  in
                guard let self, let useCase = self.resolveSingleton(FetchAnimalsUseCase.self) else {
                    fatalError("...")
                }
                return SearchResultViewModel(useCase: useCase)
            }
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

    func shareAnimal(_ desertionNo: String) {
        let baseURL = "https://damagucci-juice.github.io/BeMyFamily"
        let universalLink = "\(baseURL)/detail?id=\(desertionNo)"
        guard let url = URL(string: universalLink) else { return }

        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else { return }

        var topVC = rootVC
        while let presentedVC = topVC.presentedViewController {
            topVC = presentedVC
        }

        // iPad 크래시 방지
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = topVC.view
            popover.sourceRect = CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }

        topVC.present(activityVC, animated: true)
    }
}
