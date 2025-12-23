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

    @ViewBuilder
    private func filterView() -> some View {
        if let viewModel = container.resolveFactory(FilterViewModel.self) {
            AnimalFilterForm(viewModel: viewModel)
                .onAppear {
                    viewModel.onSearchCompleted = { [weak self] filters in
                        self?.push(.searchResult(filters))
                    }
                }
                .environment(self)
        }
    }

    @ViewBuilder
    private func searchResultView(filters: [AnimalSearchFilter]) -> some View {
        if let viewModel = container.resolveFactory(SearchResultViewModel.self) {
            SearchResultView(viewModel: viewModel)
                .onAppear {
                    viewModel.setupFilters(filters)
                }
                .onDisappear {
                    viewModel.clearAll()
                }
                .environment(self)
        }
    }
}
