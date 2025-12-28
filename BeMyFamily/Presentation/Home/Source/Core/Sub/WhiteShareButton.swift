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

    var body: some View {
        ShareLink(
            item: renderedImage ?? Image(.bemyfamilyIconTrans),
            preview: SharePreview(Text(UIConstants.App.shareMessage),
                                  image: Image(.bemyfamilyIconTrans))
        ) {
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

    return BlackShareButton(renderedImage: $image, hasImage: true)
}
