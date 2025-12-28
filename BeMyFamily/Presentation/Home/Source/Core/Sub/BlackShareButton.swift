//
//  BlackShareButton.swift
//  BeMyFamily
//
//  Created by Gucci on 4/30/24.
//

import SwiftUI

struct BlackShareButton: View {
    @Binding var renderedImage: Image?
    var hasImage: Bool
    let desertionNo: String

    var body: some View {
        Button {
            DIContainer.shared.shareAnimal(desertionNo)
        } label: {
            Image(systemName: "paperplane")
                .resizable()
                .foregroundColor(.gray)
                .frame(width: UIConstants.Frame.heartHeight,
                       height: UIConstants.Frame.heartHeight)
                .capsuleBorder()
        }
    }
}

#Preview {
    @State var image: Image? = Image(.bemyfamilyIconTrans)

    return BlackShareButton(renderedImage: $image, hasImage: true, desertionNo: "447502202502153")
}
