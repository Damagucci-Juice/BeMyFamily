//
//  FeedViewModel.swift
//  BeMyFamily
//
//  Created by Gucci on 4/19/24.
//
import SwiftUI
import Observation

// TODO: - 이거를 UseCase 기준으로 개편
@Observable
final class FeedViewModel {
    private let fetchAnimalsUseCase: FetchAnimalsUseCase

    var animals: [AnimalEntity] = []
    var isLoading = false
    var hasMore = true
    var lastError: Error? = nil

    private var page = 1
    private var lastFetchTime: Date?
    private let throttleInterval: TimeInterval = 0.3

    init(fetchAnimalsUseCase: FetchAnimalsUseCase) {
        self.fetchAnimalsUseCase = fetchAnimalsUseCase
    }

    @MainActor
    func fetchAnimalsIfCan() async {
        guard canRequestMore() else { return }

        isLoading = true
        lastError = nil
        lastFetchTime = Date()

        let result = await fetchAnimalsUseCase.execute(filter: .example, pageNo: page)
        switch result {
        case .success((let newAnimals, let pageInfo)):
            onFetchSucceed(newAnimals, pageInfo)
        case .failure(let error):
            self.lastError = error
        }

        isLoading = false
    }

    private func canRequestMore() -> Bool {
        // 1. 상태 체크
        if isLoading || !hasMore { return false }

        // 2. 시간 체크 (스로틀링)
        if let lastFetchTime = lastFetchTime {
            let elapsed = Date().timeIntervalSince(lastFetchTime)
            if elapsed < throttleInterval { return false }
        }

        return true
    }

    private func onFetchSucceed(_ newAnimals: [AnimalEntity], _ pageInfo: Paging) {
        self.animals.append(contentsOf: newAnimals)
        self.page = pageInfo.currentPage + 1
        self.hasMore = pageInfo.hasMore
    }

    /**
     // 사용자가 재시도 버튼을 누른다면 수행. 근데 안 누를 가능성이 높아보임
     func retryFetch() async {
     self.lastError = nil
     await fetchAnimalsIfCan()
     }
     */

}
