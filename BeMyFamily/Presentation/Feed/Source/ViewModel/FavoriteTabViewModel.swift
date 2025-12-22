//
//  FavoriteTabViewModel.swift
//  BeMyFamily
//
//  Created by Gucci on 6/28/24.
//

import Foundation
import Observation

@Observable
final class FavoriteTabViewModel {
    private let useCase: GetFavoriteAnimalsUseCase

    init(useCase: GetFavoriteAnimalsUseCase) {
        self.useCase = useCase
        didOnAppear()
    }

    var favorites: [AnimalEntity] = []

    func didOnAppear() {
        favorites = useCase.excute()
    }
}
