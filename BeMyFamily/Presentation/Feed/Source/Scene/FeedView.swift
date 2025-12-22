//
//  FeedView.swift
//  BeMyFamily
//
//  Created by Gucci on 4/9/24.
//
import NukeUI
import SwiftUI

// MARK: - 일반 Feed와 Filter Tab을 보여줌
struct FeedView: View {
    @State private var viewModel: FeedViewModel
    @State private var showfilter = false
    @State private var isReachedToBottom = false

    init(viewModel: FeedViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    feedList
                }

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
        }
    }

    @ViewBuilder
    private var feedList: some View {
        LazyVStack(spacing: UIConstants.Spacing.interFeedItem) {
            ForEach(viewModel.animals) { animal in
                NavigationLink {
                    AnimalDetailView(animal: animal)
                } label: {
                    FeedItemView(animal: animal)
                }
                .tint(.primary)
            }
        }
        // MARK: - 스크롤의 밑 부분에 도달하면 새로운 동물 데이터를 팻치해오는 로직
        .background {
            GeometryReader { proxy -> Color in
                let maxY = proxy.frame(in: .global).maxY
                let throttle = 150.0
                let reachedToBottom = maxY < UIConstants.Frame.screenHeight + throttle
                self.isReachedToBottom = reachedToBottom
                if reachedToBottom {
                    Task {
                        await viewModel.fetchAnimalsIfCan()
                    }
                }
                return Color.clear
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showfilter.toggle()
                } label: {
                    Image(systemName: UIConstants.Image.filter)
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
