//
//  WhiteShareButton.swift
//  BeMyFamily
//
//  Created by Gucci on 12/28/25.
//



import SwiftUI

struct WhiteShareButton: View {
    @Binding var renderedImage: Image?
    var hasImage: Bool
    let desertionNo: String

    var body: some View {
        Button {
            DIContainer.shared.shareAnimal(desertionNo)
        } label: {
            Image(systemName: "paperplane")
                .resizable()
                .foregroundColor(.white)
                .frame(width: UIConstants.Frame.heartHeight,
                       height: UIConstants.Frame.heartHeight)
                .capsuleBorder(color: .white)
        }
    }
}

#Preview {
    @State var image: Image? = Image(.bemyfamilyIconTrans)

    return WhiteShareButton(renderedImage: $image, hasImage: true, desertionNo: "447502202502153")
}
