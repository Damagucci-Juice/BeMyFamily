//
//  SearchResultView.swift
//  BeMyFamily
//
//  Created by Gucci on 12/23/25.
//

import SwiftUI

struct SearchResultView: View {
    @Bindable var viewModel: SearchResultViewModel

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if viewModel.animals.isEmpty && !viewModel.isLoading {
                    ContentUnavailableView(
                        "검색 결과가 없어요",
                        systemImage: "magnifyingglass"
                    )
                    .padding(.top, 100)
                } else {
                    ForEach(viewModel.animals) { animal in
                        NavigationLink(destination: {
                            AnimalDetailView(animal: animal)
                        }, label: {
                            FeedItemView(animal: animal)
                        })
                        .buttonStyle(.plain)
                        .onAppear {
                            if animal == viewModel.animals.last {
                                Task { await viewModel.fetchAllNextPages() }
                            }
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                            // 화면 전환 전에 요청 제거
                            viewModel.clearAll()
                        })

                    }

                    if viewModel.isNoResult {
                        ProgressView()
                            .padding()
                            .onAppear {
                                Task { await viewModel.fetchAllNextPages() }
                            }
                    }
                }
            }
        }
        .overlay {
            if viewModel.isLoading && viewModel.animals.isEmpty {
                ProgressView("데이터를 불러오는 중...")
                    .background(Color(.systemBackground))
            }
        }
    }
}
