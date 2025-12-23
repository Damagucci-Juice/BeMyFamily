//
//  SearchRootView.swift
//  BeMyFamily
//
//  Created by Gucci on 12/23/25.
//

import SwiftUI

enum SearchRoute: Hashable {
    case searchResult(filters: [AnimalSearchFilter])
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
                AnimalFilterForm(viewModel: viewModel)
                    .navigationDestination(for: SearchRoute.self) { route in
                        switch route {
                        case .searchResult(let filters):
//                            SearchResultView(filters: filters))
                            Text("Search TEMP VIEW \(filters.count)개")
                        }
                    }
            }
        }
    }
}
