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
        if viewModel.animals.isEmpty && !viewModel.isLoading {
            ContentUnavailableView(
                "검색 결과가 없어요",
                systemImage: "magnifyingglass"
            )
            .padding(.top, 100)
        } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.animals) { animal in
                        VStack {
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
                                if viewModel.isLoading {
                                    viewModel.clearAll()
                                }
                            })

                            if animal != viewModel.animals.last {
                                Divider()
                                    .padding(.bottom, 24)
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
}
