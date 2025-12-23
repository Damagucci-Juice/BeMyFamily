//
//  SearchResultViewModel.swift
//  BeMyFamily
//
//  Created by Gucci on 12/23/25.
//
import Foundation
import Observation

@Observable
final class SearchResultViewModel {
    private let useCase: FetchAnimalsUseCase
    private let animals: [AnimalEntity] = []
    private var filters: [AnimalSearchFilter] = []

    init(useCase: FetchAnimalsUseCase) {
        self.useCase = useCase
    }

    func setupFilters(_ filters: [AnimalSearchFilter]) {
        self.filters = filters
    }
}
