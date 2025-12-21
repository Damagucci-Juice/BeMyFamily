//
//  FavoriteButtonViewModel.swift
//  BeMyFamily
//
//  Created by Gucci on 6/25/24.
//

import Foundation

final class FavoriteButtonViewModel: ObservableObject {
    private var animal: AnimalEntity
    private let toggleUseCase: ToggleFavoriteUseCase
    @Published var isFavorite: Bool

    init(animal: AnimalEntity, toggleUseCase: ToggleFavoriteUseCase) {
        self.animal = animal
        self.toggleUseCase = toggleUseCase
        self.isFavorite = animal.isFavorite
    }

    func heartButtonTapped() {
        switch toggleUseCase.execute(animal: animal) {
        case .success(let result):
            isFavorite = result
            animal.updateFavoriteStatus(result)
        case .failure:
            print("Heart Enroll Error")
            break
        }
    }
}
