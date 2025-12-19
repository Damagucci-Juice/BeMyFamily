//
//  FavoriteButtonView.swift
//  BeMyFamily
//
//  Created by Gucci on 4/30/24.
//

import SwiftUI

struct FavoriteButtonView: View {
    @ObservedObject var viewModel: FavoriteButtonViewModel

    var body: some View {
        Button {
            viewModel.toggle()
        } label: {
            Image(systemName: UIConstants.Image.heart)
                .resizable()
                .scaledToFill()
                .foregroundStyle(viewModel.isFavorite ? .red.opacity(UIConstants.Opacity.border) : .secondary)
                .frame(width: UIConstants.Frame.heartHeight,
                       height: UIConstants.Frame.heartHeight)
                .overlay {
                    Image(systemName: UIConstants.Image.heartWithStroke)
                        .resizable()
                        .scaledToFill()
                        .foregroundStyle(viewModel.isFavorite ? .pink : .white.opacity(UIConstants.Opacity.border))
                        .frame(width: UIConstants.Frame.heartBorderHeight,
                               height: UIConstants.Frame.heartBorderHeight)
                }
        }
    }
}

#Preview {
    let animal = ModelData().animals.items.first!
    let diContainer = DIContainer(dependencies: .init(apiService: MockFamilyService()))

    return FavoriteButtonView(
        viewModel: diContainer.makeFavoriteButtonViewModel(with: animal)
    )
}
