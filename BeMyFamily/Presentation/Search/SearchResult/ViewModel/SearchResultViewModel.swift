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
        cancelAllRequests()
        self.animals = []
        self.tasks = filters.map { FilterTask(filter: $0) }

        fetchTask = Task {
            await fetchAllNextPages()
        }
    }
    func fetchAllNextPages() async {
        guard !isLoading else { return }
        let activeTasks = tasks.filter { !$0.isCompleted }
        guard !activeTasks.isEmpty else { return }

        isLoading = true

        await withTaskGroup(of: (FilterTask, (animals: [AnimalEntity], pagingInfo: Paging)?).self) { group in
            for task in activeTasks {
                group.addTask {
                    let result = await self.useCase.execute(filter: task.filter, pageNo: task.currentPage)
                    return (task, try? result.get()) // 인덱스 대신 객체를 직접 넘기면 더 안전합니다.
                }
            }

            for await (task, response) in group {
                if let response = response {
                    self.animals.append(contentsOf: response.animals)

                    // 데이터가 비었거나 다음 페이지가 없으면 완료 처리
                    if !response.pagingInfo.hasMore || response.animals.isEmpty {
                        task.isCompleted = true
                    } else {
                        task.currentPage += 1
                    }
                } else {
                    // 에러 발생 시 일단 완료 처리하거나 재시도 로직 필요
                    task.isCompleted = true
                }
            }
        }

        // 강제로 로딩 상태 해제
        isLoading = false
    }
}

