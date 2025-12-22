//
//  FilterViewModel.swift
//  BeMyFamily
//
//  Created by Gucci on 4/26/24.
//

import Foundation

@Observable
final class FilterViewModel {
    private(set) var onProcessing = false
    private(set) var emptyResultFilters = [AnimalSearchFilter]()
    private let useCase: LoadMetaDataUseCase
    var metadata: ProvinceMetadata?
    var isLoading = false
    var error: Error?

    var beginDate = Date.now.addingTimeInterval(UIConstants.Date.aDayBefore*10) // 10일 전
    var endDate = Date()
    var upkind: Upkind?
    var kinds = Set<KindEntity>()
    var sido: SidoEntity?
    var sigungu: SigunguEntity?
    var shelter: ShelterEntity?
    var state = ProcessState.all
    var neutral: Neutralization?


    init(useCase: LoadMetaDataUseCase) {
        self.useCase = useCase
    }

    func makeFilter() -> [AnimalSearchFilter] {
        onProcessing = true
        emptyResultFilters.removeAll()

        let baseFilter = AnimalSearchFilter(
            beginDate: beginDate,
            endDate: endDate,
            upkind: upkind?.id,
            kind: nil,
            sido: sido?.id,
            sigungu: sigungu?.id,
            shelterNumber: shelter?.id,
            processState: state.id,
            neutralizationState: neutral?.id
        )

        if kinds.isEmpty {
            return [baseFilter]
        } else {
            return kinds.map { kind in
                var filter = baseFilter
                filter.kind = kind.id
                return filter
            }
        }
    }

    func reset() {
        onProcessing = false
        emptyResultFilters.removeAll()

        beginDate = Date.now.addingTimeInterval(UIConstants.Date.aDayBefore*10)
        endDate = Date()
        upkind = .none
        kinds.removeAll()
        sido = .none
        sigungu = .none
        shelter = .none
        state = .all
        neutral = .none
    }

    func updateEmptyReulst(with filter: AnimalSearchFilter) {
        self.emptyResultFilters.append(filter)
    }

    func loadMetadataIfNeeded() async {
        // 이미 로드되었으면 스킵
        guard metadata == nil, !isLoading else { return }

        isLoading = true
        let result = await useCase.execute()
        isLoading = false

        switch result {
        case .success(let data):
            self.metadata = data
        case .failure(let error):
            self.error = error
        }
    }
}
