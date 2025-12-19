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
    @EnvironmentObject var diContainer: DIContainer
    @State private var loadedImage: Image?
    @State private var renderedImage: Image?
    let animal: Animal
    private var hasImage: Bool { loadedImage != nil ? false : true }

    var body: some View {
        VStack {
            HStack(alignment: .lastTextBaseline) {
                Text(animal.specialMark)
                    .font(.animalName)
                    .lineLimit(1)
                Spacer()
                Text(animal.processState)
                    .font(.processState)
            }

            LazyImage(url: URL(string: animal.photoURL)) { state in
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

            HStack {
                Spacer()

                FavoriteButtonView(viewModel: diContainer.makeFavoriteButtonViewModel(with: animal))

                ShareButton(renderedImage: $renderedImage, hasImage: hasImage)
            }
        }
        .padding(.horizontal, UIConstants.Padding.feedImemViewHorizontal)
    }
}

extension FeedItemView: Sharable { }

#Preview {
    @StateObject var reducer = DIContainer.makeFeedListViewModel(DIContainer.makeFilterViewModel())
    let animals = ModelData().animals.items

    return ScrollView {
        VStack(spacing: UIConstants.Spacing.interFeedItem) {
            FeedItemView(animal: animals[0])
            FeedItemView(animal: animals[1])
        }
        .environmentObject(reducer)
    }
    .preferredColorScheme(.dark)
}
