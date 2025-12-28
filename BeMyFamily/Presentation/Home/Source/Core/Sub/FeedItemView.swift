//
//  FeedItemView.swift
//  BeMyFamily
//
//  Created by Gucci on 4/9/24.
//
import NukeUI
import SkeletonUI
import SwiftUI

struct FeedItemView: View {
    @Environment(\.displayScale) var displayScale
    @Environment(DIContainer.self) private var diContainer

    @State private var loadedImage: Image?
    @State private var renderedImage: Image?
    let animal: AnimalEntity
    private var hasImage: Bool { loadedImage != nil ? false : true }

    var body: some View {
        VStack {

            LazyImage(url: URL(string: animal.image1)) { state in
                let roundedRectangle = RoundedRectangle(cornerRadius: UIConstants.Radius.mainImagePlaceholder)
                let hasError = state.error != nil

                if let image = state.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIConstants.Frame.screenWidthWithPadding,
                               height: UIConstants.Frame.feedImageHeight)
                        .clipShape(roundedRectangle)
                        .onAppear { self.loadedImage = image }
                }
                if state.isLoading || hasError {
                    roundedRectangle
                        .stroke(.windowBackground, lineWidth: UIConstants.Line.feedItem)
                        .skeleton(with: hasImage,
                                  animation: .linear(),
                                  appearance: .solid(color: .gray, background: .clear),
                                  shape: .rounded(.radius(UIConstants.Radius.mainImagePlaceholder, style: .circular)))
                        .frame(width: UIConstants.Frame.screenWidthWithPadding,
                               height: UIConstants.Frame.feedImageHeight)
                        .overlay {
                            if hasError {
                                Text(NetworkConstants.Error.responseHadError)
                                    .font(.processState)
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

            // 사진 밑에 뷰
            HStack {
                Text(animal.specialMark.limitText(to: 30))
                    .font(.animalName)
                    .lineLimit(1)

                Spacer()

                if let favoriteViweModel = diContainer.resolveFactory(
                    FavoriteButtonViewModel.self, parameter: animal
                ) {
                    BlackFavoriteButtonView(viewModel: favoriteViweModel)
                }

                BlackShareButton(renderedImage: $renderedImage,
                                 hasImage: hasImage,
                                 desertionNo: animal.desertionNo)
            }
        }
        .padding(.horizontal, UIConstants.Padding.feedImemViewHorizontal)
        .padding(.bottom, 2)
    }
}

extension FeedItemView: Sharable { }

#Preview {
    @Previewable var dIContainer = DIContainer.shared
    let animals = ModelData().animals.items

    ScrollView {
        VStack(spacing: UIConstants.Spacing.interFeedItem) {
            FeedItemView(animal: Mapper.animalDto2Entity(animals[0]))
            FeedItemView(animal: Mapper.animalDto2Entity(animals[1]))
        }
        .environment(dIContainer)
    }
    .preferredColorScheme(.dark)
}
