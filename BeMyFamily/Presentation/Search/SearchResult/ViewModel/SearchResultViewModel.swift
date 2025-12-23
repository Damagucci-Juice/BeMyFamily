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
    // 필터별 상태를 관리하기 위한 내부 구조체
    class FilterTask {
        let filter: AnimalSearchFilter
        var currentPage: Int = 1
        var isCompleted: Bool = false

        init(filter: AnimalSearchFilter) {
            self.filter = filter
        }
    }

    private let useCase: FetchAnimalsUseCase
    private(set) var tasks: [FilterTask] = []

    var animals: [AnimalEntity] = []
    var isLoading: Bool = false
    var isNoResult: Bool {
        !isLoading && animals.isEmpty && tasks.allSatisfy { $0.isCompleted }
    }

    init(useCase: FetchAnimalsUseCase, filters: [AnimalSearchFilter]) {
        self.useCase = useCase
        self.setupFilters(filters)
    }

    private var fetchTask: Task<Void, Never>?

    deinit {
        cancelAllRequests()
    }

    func clearAll() {
        cancelAllRequests()
        self.tasks = []
        self.animals = []
        self.isLoading = false
    }

    private func cancelAllRequests() {
        fetchTask?.cancel()
        fetchTask = nil
    }

    func setupFilters(_ filters: [AnimalSearchFilter]) {
        print("📊 SearchResultViewModel - 받은 필터 개수: \(filters.count)")

        cancelAllRequests()
        self.animals = []
        self.tasks = filters.map { FilterTask(filter: $0) }

        print("📊 생성된 task 개수: \(tasks.count)")

        fetchTask = Task {
            await fetchAllNextPages()
        }
    }

    func fetchAllNextPages() async {
        guard !Task.isCancelled else { return }
        guard !isLoading else { return }

        let activeTasks = tasks.filter { !$0.isCompleted }
        guard !activeTasks.isEmpty else { return }

        isLoading = true

        await withTaskGroup(of: (Int, (animals: [AnimalEntity], pagingInfo: Paging)?).self) { group in
            for index in 0..<activeTasks.count {
                if Task.isCancelled { break }

                let task = activeTasks[index]
                group.addTask {
                    let result = await self.useCase.execute(
                        filter: task.filter,
                        pageNo: task.currentPage
                    )
                    if Task.isCancelled { return (index, nil) }

                    switch result {
                    case .success(let response): return (index, response)
                    case .failure: return (index, nil)
                    }
                }
            }

            for await (index, response) in group {
                if Task.isCancelled { break }

                let task = activeTasks[index]
                guard let response = response else { continue }

                if !response.animals.isEmpty {
                    self.animals.append(contentsOf: response.animals)
                }

                let paging = response.pagingInfo
                if !paging.hasMore || response.animals.isEmpty {
                    task.isCompleted = true
                } else {
                    task.currentPage += 1
                }
            }
        }

        isLoading = false
    }
}
