//
//  AnimalDetailView.swift
//  BeMyFamily
//
//  Created by Gucci on 4/18/24.
//

import NukeUI
import SkeletonUI
import SwiftUI

struct AnimalDetailView: View {
    @Environment(\.displayScale) var displayScale
    @EnvironmentObject var diContainer: DIContainer
    @State private var loadedImage: Image?
    @State private var renderedImage: Image?
    let animal: Animal
    private var hasImage: Bool { loadedImage != nil ? false : true }

    var body: some View {
        ScrollView {
            VStack {
                imageSection
                Group {
                    actionButtons
                    detailSection
                }
                .padding(.horizontal)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("상세 정보")
        }
        .scrollIndicators(.hidden)
    }

    @MainActor
    @ViewBuilder
    private var imageSection: some View {
        LazyImage(url: URL(string: animal.photoURL)) { state in
            let roundedRectangle = RoundedRectangle(cornerRadius: UIConstants.Radius.mainImagePlaceholder)
            let hasError = state.error != nil

            if let image = state.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: UIConstants.Frame.screenWidth,
                           height: UIConstants.Frame.feedImageHeight)
                    .clipShape(Rectangle())
                    .onAppear { self.loadedImage = image }
            }
            if state.isLoading || hasError {
                roundedRectangle
                    .stroke(.windowBackground, lineWidth: UIConstants.Line.feedItem)
                    .skeleton(with: hasImage,
                              animation: .linear(),
                              appearance: .solid(color: .gray, background: .clear),
                              shape: .rounded(.radius(UIConstants.Radius.mainImagePlaceholder, style: .circular)))
                    .frame(width: UIConstants.Frame.screenWidth,
                           height: UIConstants.Frame.feedImageHeight)
                    .overlay {
                        if hasError {
                            Text(NetworkConstants.Error.responseHadError)
                                .font(.caption)
                        }
                    }
            }
        }
        .onChange(of: loadedImage) { _, newValue in
            guard let newValue else { return }
            Task {
                self.renderedImage = render(object: animal, img: newValue, displayScale: displayScale)
            }
        }
    }

    @ViewBuilder
    private var detailSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Group {
                detailRow(label: "특이사항:", value: animal.specialMark)
                detailRow(label: "접수일:", value: animal.happenDt)
                detailRow(label: "발견장소:", value: animal.happenPlace)
                detailRow(label: "품종:", value: animal.kindCD)
                detailRow(label: "색:", value: animal.colorCD)
                detailRow(label: "나이:", value: animal.age)
                detailRow(label: "무게:", value: animal.weight)
                detailRow(label: "처리 상태:", value: animal.processState)
                detailRow(label: "성별:", value: animal.sexCD.text)
                detailRow(label: "중성화 여부:", value: animal.neuterYn.text)
                detailRow(label: "보호소 이름:", value: animal.careNm)
                detailRow(label: "보호소 연락처:", value: animal.careTel)
            }
        }
    }

    // TODO: - CardNewsView와 중복되는데 해결
    @ViewBuilder
    private func detailRow(label: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .bold()
            Text(value)
            Spacer()
        }
    }

    @ViewBuilder
    private var actionButtons: some View {
        HStack {
            Spacer()

            FavoriteButtonView(viewModel: diContainer.makeFavoriteButtonViewModel(with: animal))

            ShareButton(renderedImage: $renderedImage, hasImage: hasImage)
        }
        .padding(.vertical)
    }
}

extension AnimalDetailView: Sharable { }

#Preview {
    @StateObject var reducer = DIContainer.makeFeedListViewModel(DIContainer.makeFilterViewModel())
    let animals = ModelData().animals.items

    return NavigationView {
        AnimalDetailView(animal: animals[0])
    }
}
