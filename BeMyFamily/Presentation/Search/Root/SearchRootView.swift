//
//  SearchRootView.swift
//  BeMyFamily
//
//  Created by Gucci on 12/23/25.
//

import SwiftUI

enum SearchRoute: Hashable {
    case searchResult(filters: [AnimalSearchFilter])
    case detail(entity: AnimalEntity)
}

@Observable
final class SearchRouter {
    var path = NavigationPath()
}

struct SearchRootView: View {
    @Bindable var router: SearchRouter
    @Environment(DIContainer.self) var diContainer


    var body: some View {
        NavigationStack(path: $router.path) {
            if let viewModel = diContainer.resolveFactory(FilterViewModel.self) {
                FilterView(viewModel: viewModel)
                    .navigationDestination(for: SearchRoute.self) { route in
                        switch route {
                        case .searchResult(let filters):
                            if let searchViewModel = diContainer.resolveFactory(SearchResultViewModel.self) {
                                let _ = { searchViewModel.setupFilters(filters) }()

                                SearchResultView(viewModel: searchViewModel)
                            }
                        case .detail(let entity):
                            AnimalDetailView(animal: entity)
                        }
                    }
            }
        }
    }
}
