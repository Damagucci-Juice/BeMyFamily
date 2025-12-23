//
//  SearchResultView.swift
//  BeMyFamily
//
//  Created by Gucci on 12/23/25.
//

import SwiftUI

struct SearchResultView: View {
    @Bindable var viewModel: SearchResultViewModel

    init(viewModel: SearchResultViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            if viewModel.isNoResult {
                // 결과가 아예 없을 때 (isNoResult 활용)
                ContentUnavailableView("검색 결과가 없어요", systemImage: "magnifyingglass")
            } else {
                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.animals) { animal in
                            NavigationLink(value: SearchRoute.detail(entity: animal)) {
                                FeedItemView(animal: animal)
                            }
                        }

                        // 데이터가 더 남았을 때만 하단 로딩바 노출 (allSatisfy 활용)
                        if !viewModel.tasks.allSatisfy({ $0.isCompleted }) {
                            ProgressView()
                                .onAppear {
                                    Task { await viewModel.fetchAllNextPages() }
                                }
                        }
                    }
                }
            }

            // 처음 진입 시 전체 로딩 (선택 사항)
            if viewModel.isLoading && viewModel.animals.isEmpty {
                ProgressView("데이터를 불러오는 중...")
            }
        }
    }
}
