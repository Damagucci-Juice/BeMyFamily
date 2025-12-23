//
//  Coordinator.swift
//  BeMyFamily
//
//  Created by Gucci on 12/23/25.
//
import Foundation
import Observation
import SwiftUI

@Observable
final class Coordinator {
    var path = NavigationPath()
    private let container: DIContainer
    private var filterViewModel: FilterViewModel?

    init(container: DIContainer) {
        self.container = container
    }

    // 화면 전환 함수
    func push(_ page: SearchFlow) {
        path.append(page)
    }

    func pop() {
        path.removeLast()
    }

    // DIContainer를 사용해 뷰 빌드
    @ViewBuilder
    func build(_ page: SearchFlow) -> some View {
        switch page {
        case .filter:
            filterView()
        case .searchResult(let filters):
            searchResultView(filters: filters)
        }
    }

    private func filterView() -> some View {
        let viewModel: FilterViewModel

        // 로직 수행 (할당 연산)
        if let existing = filterViewModel {
            viewModel = existing
        } else {
            let onSearch: ([AnimalSearchFilter]) -> Void = { [weak self] filters in
                self?.push(.searchResult(filters))
            }
            // DIContainer에서 생성
            viewModel = container.resolveFactory(FilterViewModel.self, parameter: onSearch)!
            self.filterViewModel = viewModel
        }

        return AnimalFilterForm(viewModel: viewModel)
    }

    @ViewBuilder
    private func searchResultView(filters: [AnimalSearchFilter]) -> some View {
        if let viewModel = container.resolveFactory(SearchResultViewModel.self, parameter: filters) {
            SearchResultView(viewModel: viewModel)
        }
    }
}
