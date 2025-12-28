//
//  WhiteFavoriteButtonView.swift
//  BeMyFamily
//
//  Created by Gucci on 12/28/25.
//


import SwiftUI

struct WhiteFavoriteButtonView: View {
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
                        .white)
                .frame(width: UIConstants.Frame.heartHeight,
                       height: UIConstants.Frame.heartHeight)
                .capsuleBorder(color: .white)
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

        WhiteFavoriteButtonView(viewModel: viewModel)
    }
}
