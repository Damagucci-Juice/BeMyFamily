//
//  FavoriteButtonView.swift
//  BeMyFamily
//
//  Created by Gucci on 4/30/24.
//

import SwiftUI

struct FavoriteButtonView: View {
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
                .padding(.horizontal, 12)
                .padding(.vertical, 6)   
                .background {
                    // 캡슐 배경 추가
                    Capsule()
                        .fill(.clear)
                }
                .overlay {
                    // 캡슐 테두리
                    Capsule()
                        .stroke(Color.secondary.opacity(0.4), lineWidth: 0.8)
                }
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

        FavoriteButtonView(viewModel: viewModel)
    }
}
