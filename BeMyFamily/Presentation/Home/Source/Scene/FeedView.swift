//
//  FeedView.swift
//  BeMyFamily
//
//  Created by Gucci on 4/9/24.
//
import NukeUI
import SwiftUI

struct FeedView: View {
    @State private var viewModel: FeedViewModel
    @State private var isReachedToBottom = false

    init(viewModel: FeedViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                feedList
            }
            .scrollIndicators(.never)

            if viewModel.isLoading {
                ProgressView()
            }

            if !viewModel.hasMore {
                VStack {
                    Spacer()
                    toggleMessage
                }
            }
        }
        .onAppear {
            if viewModel.animals.isEmpty {
                Task {
                    await viewModel.fetchAnimalsIfCan()
                }
            }
        }
    }

    @ViewBuilder
    private var feedList: some View {
        LazyVStack(spacing: UIConstants.Spacing.interFeedItem) {
            ForEach(viewModel.animals) { animal in
                VStack {
                    NavigationLink(value: FeedRoute.detail(entity: animal)) {
                        FeedItemView(animal: animal)
                            .onAppear {
                                if let last = viewModel.animals.last, animal.id == last.id {
                                    isReachedToBottom = true
                                    Task {
                                        await viewModel.fetchAnimalsIfCan()
                                    }
                                }
                            }
                    }
                    .tint(.primary)

                    if animal.id != viewModel.animals.last?.id {
                        Divider()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var toggleMessage: some View {
        Capsule(style: .continuous)
            .fill(.gray)
            .frame(width: 250, height: 50)
            .overlay {
                Text("더 이상 공고가 없습니다.")
            }
    }
}

#Preview {
    @Previewable
    var diContainer = DIContainer.shared

    if let feedViewModel = diContainer.resolveFactory(FeedViewModel.self) {
        FeedView(viewModel: feedViewModel)
    }
}
