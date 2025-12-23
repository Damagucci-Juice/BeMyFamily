//
//  FilterView.swift
//  BeMyFamily
//
//  Created by Gucci on 4/13/24.
//
//

import SwiftUI

struct FilterView: View {
    @Environment(DIContainer.self) var diContainer
    @Bindable var viewModel: FilterViewModel

    init(viewModel: FilterViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                // 로딩 중 UI
                VStack(spacing: 16) {
                    ProgressView()
                    Text("필터 정보를 불러오는 중...")
                        .foregroundStyle(.secondary)
                }
            } else {
                filterFormContent
            }
        }
        .navigationTitle(UIConstants.FilterForm.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // 검색 버튼
            ToolbarItem(placement: .confirmationAction) {
                NavigationLink("Search",
                               value: SearchRoute.searchResult(filters: viewModel.makeFilters()))
            }

            // 초기화 버튼
            ToolbarItem(placement: .cancellationAction) {
                resetButton()
            }
        }
    }

    @ViewBuilder
    private var filterFormContent: some View {
        Form {
            kindSection

            Section(header: Text("검색 일자")) {
                DatePicker("시작일", selection: $viewModel.beginDate,
                           in: ...viewModel.endDate.addingTimeInterval(-86400),
                           displayedComponents: .date)
                DatePicker("종료일", selection: $viewModel.endDate,
                           in: ...Date(),
                           displayedComponents: .date)
            }

            Section("지역을 골라주세요") {
                Picker("시도", selection: $viewModel.sido) {
                    Text(UIConstants.FilterForm.showAll)
                        .tag(nil as SidoEntity?)
                    ForEach(viewModel.metadata.sido, id: \.self) { aSido in
                        Text(aSido.name)
                            .tag(aSido as SidoEntity?)
                    }
                }
                .onChange(of: viewModel.sido) { _, _ in
                    viewModel.sigungu = nil
                }

                if let sido = viewModel.sido {
                    Picker("시군구", selection: $viewModel.sigungu) {
                        let sigungus = viewModel.metadata.province[sido, default: []]
                        Text(UIConstants.FilterForm.showAll)
                            .tag(nil as SigunguEntity?)

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

            if viewModel.sigungu != nil {
                Section("보호소를 선택하세요.") {
                    if viewModel.isLoadingShelters {
                        HStack {
                            ProgressView()
                                .padding(.trailing, 8)
                            Text("보호소 목록 불러오는 중...")
                        }
                    } else {
                        Picker("보호소", selection: $viewModel.shelter) {
                            Text(UIConstants.FilterForm.showAll)
                                .tag(nil as ShelterEntity?)

                            let shelters = viewModel.getSheltersForCurrentSigungu()
                            ForEach(shelters, id: \.self) { eachShelter in
                                Text(eachShelter.name)
                                    .tag(eachShelter as ShelterEntity?)
                            }
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
    }

    @ViewBuilder
    private var kindSection: some View {
        Section(header: Text("어떤 종을 보고 싶으신가요?")) {
            Picker("축종", selection: $viewModel.upkind) {
                Text(UIConstants.FilterForm.showAll).tag(nil as Upkind?)
                ForEach(Upkind.allCases, id: \.self) { upkind in
                    Text(upkind.text).tag(upkind as Upkind?)
                }
            }
            .onChange(of: viewModel.upkind) { _, _ in
                viewModel.kinds.removeAll()
            }

            if let upkind = viewModel.upkind {
                ForEach(viewModel.kinds(upkind), id: \.id) { kind in
                    Button {
                        viewModel.toggleKind(kind)
                    } label: {
                        togglingCheckbox(kind, viewModel.isSelected(kind))
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
