//
//  AnimalThumbnailView.swift
//  BeMyFamily
//
//  Created by Gucci on 6/28/24.
//

import NukeUI
import SwiftUI

struct AnimalThumbnailView: View {
    let animal: AnimalEntity
    private let width = UIConstants.Frame.screenWidth / 3 + 2

    var body: some View {
        ZStack(alignment: .topTrailing) {
            LazyImage(url: URL(string: animal.image1)) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .scaledToFill()
                } else if state.isLoading {
                    ProgressView()
                }
            }
            .frame(width: width,
                   height: width)
            .clipShape(.rect)
        }
    }
}

#Preview {
    let model = ModelData().animals.items.first!

    return AnimalThumbnailView(animal: Mapper.animalDto2Entity(model))
}
