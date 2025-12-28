//
//  BlackFavoriteButtonView.swift
//  BeMyFamily
//
//  Created by Gucci on 4/30/24.
//

import SwiftUI

struct BlackFavoriteButtonView: View {
    @State var viewModel: FavoriteButtonViewModel

    var body: some View {
        Button {
            viewModel.heartButtonTapped()
        } label: {
            ZStack {
                Image(systemName: viewModel.isFavorite ?
                      UIConstants.Image.heart :
                        UIConstants.Image.heartWithStroke)
                .resizable()
                .scaledToFill()
                .foregroundStyle(viewModel.isFavorite ?
                    .red.opacity(UIConstants.Opacity.border) :
                        .secondary)
                .frame(width: UIConstants.Frame.heartHeight,
                       height: UIConstants.Frame.heartHeight)
                .capsuleBorder()
            }
        }
    }
}

#Preview {
    let animal = ModelData().animals.items.first!
    let diContainer = DIContainer.shared

    if let viewModel = diContainer.resolveFactory(
        FavoriteButtonViewModel.self,
        parameter: animal) {

        BlackFavoriteButtonView(viewModel: viewModel)
    }
}
