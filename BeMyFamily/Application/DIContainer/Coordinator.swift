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
            // 1. 뷰를 반환하기 전에 클로저를 미리 주입합니다.
            // onAppear가 아닌 생성 시점에 주입해야 뒤로가기 후에도 안전합니다.
            let view = AnimalFilterForm(viewModel: viewModel)
                .environment(self)

            // 할당문 실행을 위해 클로저 정의
            let _ = {
                viewModel.onSearchCompleted = { [weak self] filters in
                    self?.push(.searchResult(filters))
                }
            }()

            view
        }
    }

    @ViewBuilder
    private func searchResultView(filters: [AnimalSearchFilter]) -> some View {
        if let viewModel = container.resolveFactory(SearchResultViewModel.self) {
            // 2. 검색 결과 뷰도 생성 시점에 필터를 설정합니다.
            let view = SearchResultView(viewModel: viewModel)
                .environment(self)
                .onDisappear {
                    // 뒤로가기 시 네트워킹만 취소하고 싶다면 여기서 수행
                    viewModel.clearAll()
                }

            let _ = {
                viewModel.setupFilters(filters)
            }()

            view
        }
    }
}
