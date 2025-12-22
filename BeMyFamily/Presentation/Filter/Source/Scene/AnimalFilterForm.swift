//
//  AnimalFilterForm.swift
//  BeMyFamily
//
//  Created by Gucci on 4/13/24.
//
//

import SwiftUI

struct AnimalFilterForm: View {
    @Environment(\.dismiss) var dismiss
    @Environment(DIContainer.self) var diContainer
    @State var viewModel: FilterViewModel
    private let metaData: ProvinceMetadata

    init(viewModel: FilterViewModel, metaData: ProvinceMetadata) {
        self._viewModel = State(wrappedValue: viewModel)
        self.metaData = metaData
    }

    var body: some View {
        NavigationStack {
            Form {
                kindSection

                Section(header: Text("검색 일자")) {
                    DatePicker("시작일", selection: $viewModel.beginDate,
                               in: ...viewModel.endDate.addingTimeInterval(UIConstants.Date.aDayBefore),
                               displayedComponents: .date)
                    DatePicker("종료일", selection: $viewModel.endDate,
                               in: ...Date(),
                               displayedComponents: .date)
                }

                Section("지역을 골라주세요") {
                    Picker("시도", selection: $viewModel.sido) {
                        Text(UIConstants.FilterForm.showAll)
                            .tag(nil as SidoDTO?)

                        ForEach(metaData.sido, id: \.self) { eachSido in
                            Text(eachSido.name)
                                .tag(eachSido as SidoEntity?)
                        }
                    }
                    .onChange(of: viewModel.sido) { _, _ in
                        viewModel.sigungu = nil
                    }

                    if let sido = viewModel.sido {
                        Picker("시군구", selection: $viewModel.sigungu) {
                            let sigungus = metaData.province[sido, default: []]
                            Text(UIConstants.FilterForm.showAll)
                                .tag(nil as SigunguDTO?)

                            ForEach(sigungus, id: \.self) { eachSigungu in
                                if let sigunguName = eachSigungu.name {
                                    Text(sigunguName)
                                        .tag(eachSigungu as SigunguEntity?)
                                }
                            }
                        }
                        .onChange(of: viewModel.sigungu) { _, _ in
                            viewModel.shelter = nil
                        }
                    }
                }

                if let sido = viewModel.sido, let sigungu = viewModel.sigungu {
                    Section("보호소를 선택하세요.") {
                        Picker("보호소", selection: $viewModel.shelter) {
                            Text(UIConstants.FilterForm.showAll)
                                .tag(nil as ShelterEntity?)

                            let shelter = metaData.shelter[sigungu, default: []]
                            ForEach(shelter, id: \.self) { eachShelter in
                                Text(eachShelter.name)
                                    .tag(eachShelter as ShelterEntity?)
                            }
                        }
                    }
                }

                Section("현재 어떤 상태인가요?") {
                    Picker("처리 상태", selection: $viewModel.state) {
                        ForEach(ProcessState.allCases, id: \.self) { process in
                            Text(process.text)
                        }
                    }
                }

                Section("중성화 여부") {
                    Picker("중성화 여부", selection: $viewModel.neutral) {
                        Text(UIConstants.FilterForm.showAll)
                            .tag(nil as Neutralization?)

                        ForEach(Neutralization.allCases, id: \.self) { neutralization in
                            Text(neutralization.text)
                                .tag(neutralization as Neutralization?)
                        }
                    }
                }
            }
            .navigationTitle(UIConstants.FilterForm.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        // TODO: - 여기서 동물 공고 요청
                        dismiss()
                    } label: {
                        Text("Done")
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    resetButton()
                }
            }
        }
    }
}

extension AnimalFilterForm {

    @ViewBuilder
    private var kindSection: some View {
        Section(header: Text("어떤 종을 보고 싶으신가요?")) {
            // 상위 카테고리 (강아지, 고양이 등)
            Picker("축종", selection: $viewModel.upkind) {
                Text(UIConstants.FilterForm.showAll).tag(nil as Upkind?)
                ForEach(Upkind.allCases, id: \.self) { upkind in
                    Text(upkind.text).tag(upkind as Upkind?)
                }
            }
            .onChange(of: viewModel.upkind) { _, _ in
                viewModel.kinds.removeAll()
            }

            // 품종 리스트 - List 대신 ForEach를 사용하여 Section에 직접 배치
            if let upkind = viewModel.upkind, let kinds = metaData.kind[upkind] {
                // 품종이 너무 많을 경우를 대비해 검색 버튼이나 내비게이션 링크로 빼는 것이 좋지만,
                // 일단 화면에 바로 노출하려면 ForEach를 씁니다.
                ForEach(kinds, id: \.id) { kind in
                    let isSelected = viewModel.kinds.contains(kind)

                    Button {
                        if isSelected {
                            viewModel.kinds.remove(kind)
                        } else {
                            viewModel.kinds.insert(kind)
                        }
                    } label: {
                        togglingCheckbox(kind, isSelected)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    @ViewBuilder
    private func togglingCheckbox(_ kind: KindEntity, _ isSelected: Bool) -> some View {
        let image = isSelected ? "checkmark.circle.fill" : "circle"
        HStack {
            Image(systemName: image)
                .foregroundStyle(isSelected ? .blue : .gray)
            Text(kind.name)
        }
    }

    @ViewBuilder
    private func resetButton() -> some View {
        Button {
            viewModel.reset()
        } label: {
            Label {
                Text("필터 초기화")
            } icon: {
                Image(systemName: UIConstants.Image.reset)
            }
        }
    }
}

extension AnimalFilterForm {
//    func fetchAnimalsWithFilter() async {
//        let filters = viewModel.makeFilter()
//    }
}

#Preview {
    NavigationStack {
        if let viewModel = DIContainer.shared.resolveFactory(FilterViewModel.self),
           let data = DIContainer.shared.resolveSingleton(ProvinceMetadata.self) {

            AnimalFilterForm(viewModel: viewModel, metaData: data)
                .environment(DIContainer.shared)
        } else {
            EmptyView()
        }
    }
}
