//
//  Sharable.swift
//  BeMyFamily
//
//  Created by Gucci on 4/26/24.
//

import SwiftUI

protocol Sharable: View {
    func render(object: Animal, img image: Image, displayScale: CGFloat) -> Image?
}

extension Sharable {
    @MainActor
    func render(object: Animal, img image: Image, displayScale: CGFloat) -> Image? {
        let renderer = ImageRenderer(content: CardNewsView(image: image, animal: object))

        // make sure and use the correct display scale for this device
        renderer.scale = displayScale

        if let uiImage = renderer.uiImage {
            return Image(uiImage: uiImage)
        }
        return nil
    }
}
