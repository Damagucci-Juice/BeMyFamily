//
//  ShareButton.swift
//  BeMyFamily
//
//  Created by Gucci on 4/30/24.
//

import SwiftUI

struct ShareButton: View {
    @Binding var renderedImage: Image?
    var hasImage: Bool

    var body: some View {
        ShareLink(item: renderedImage ?? Image(.bemyfamilyIconTrans),
                  preview: SharePreview(Text(UIConstants.App.shareMessage),
                                        image: Image(.bemyfamilyIconTrans)))
        .labelStyle(.iconOnly)
        .imageScale(.large)
        .symbolVariant(.fill)
        .tint(.secondary)
        .disabled(hasImage)
    }
}

#Preview {
    @State var image: Image? = Image(.bemyfamilyIconTrans)

    return ShareButton(renderedImage: $image, hasImage: true)
}
