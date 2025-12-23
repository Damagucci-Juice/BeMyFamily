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
    final class FilterTask {
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
    
    // SearchResultViewModel 내부의 로직 체크
    func fetchAllNextPages() async {
        // 1. 이미 로딩 중이거나 모든 태스크가 완료되었다면 중단
        guard !isLoading else { return }
        let activeTasks = tasks.filter { !$0.isCompleted }
        guard !activeTasks.isEmpty else { return }
        
        isLoading = true
        
        // TaskGroup을 사용하여 현재 활성화된 필터들의 '다음 페이지'를 각각 요청
        await withTaskGroup(of: (FilterTask, (animals: [AnimalEntity], pagingInfo: Paging)?).self) { group in
            for task in activeTasks {
                group.addTask {
                    let result = await self.useCase.execute(filter: task.filter, pageNo: task.currentPage)
                    return (task, try? result.get())
                }
            }
            
            for await (task, response) in group {
                if let response = response {
                    // 새로운 데이터 추가
                    self.animals.append(contentsOf: response.animals)
                    
                    // 2. Paging 정보에 따른 완료 처리
                    // totalCount와 현재까지 불러온 양을 비교하여 다음 페이지 존재 여부 판단
                    if !response.pagingInfo.hasMore || response.animals.isEmpty {
                        task.isCompleted = true
                    } else {
                        task.currentPage += 1
                    }
                } else {
                    // 에러 시 중단 (필요에 따라 재시도 로직 추가)
                    task.isCompleted = true
                }
            }
        }
        
        isLoading = false
    }
}
