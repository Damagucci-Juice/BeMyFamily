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
    @EnvironmentObject var reducer: FeedViewModel
    @EnvironmentObject var filterReducer: FilterViewModel
    @State private var showfilter = false
    @State private var alertKind = "해당"
    @State private var isReachedToBottom = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    feedList
                }

                if isReachedToBottom && reducer.menu != .favorite {
                    toggleMessage
                }
            }
            .navigationTitle(reducer.menu.title)
        }
    }

    @ViewBuilder
    private var feedList: some View {
        LazyVStack(spacing: UIConstants.Spacing.interFeedItem) {
            ForEach(reducer.currentAnimals) { animal in
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
                if reachedToBottom && !reducer.isLoading && !reducer.isLast {
                    //  피드라면 example을 호출하고, Filter라면 최근 Filter를 호출
                    Task {
                        switch reducer.menu {
                        case .feed:
                            await reducer.fetchAnimalsIfCan()
                        case .filter:
                            // TODO: - 캡슐화 위반.. 뭔지 어떻게 알아야하는 것인가? 차라리 현재 선택된 메뉴를 넘기는게 맞아보인다.
                            await reducer.fetchAnimalsIfCan(reducer.selectedFilter)
                        case .favorite:
                            // TODO: Favorite List에서는 어쨋든 이 흐름을 Background 에서 불러오는 것을 하고 있겠구나.
                            break
                        }
                    }
                }
                return Color.clear
            }        
        }
        .fullScreenCover(isPresented: $showfilter) {
            AnimalFilterForm()
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

    // MARK: - 로딩이나 빈 공고를 알려주는 토글 메시지
    // TODO: - 빈화면일 때, 계속해서 이미지를 요청하고 하는건 에러임
    @ViewBuilder
    private var toggleMessage: some View {
        if reducer.currentAnimals.isEmpty || reducer.isLoading {
            ProgressView()
        } else if !filterReducer.emptyResultFilters.isEmpty {
            VStack {
                ForEach(filterReducer.emptyResultFilters, id: \.self) { emptyFilter in
                    Capsule(style: .continuous)
                        .fill(.gray)
                        .frame(width: 250, height: 50)
                        .overlay {
                            Text("\(String(describing: emptyFilter.kind?.name ?? "더 이상")) 공고가 없습니다.")
                        }
                }
            }
        }
    }
}

#Preview {
    @StateObject var reducer = DIContainer.makeFeedListViewModel(DIContainer.makeFilterViewModel())

    return FeedView()
        .environmentObject(reducer)
        .preferredColorScheme(.dark)
}
