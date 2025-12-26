//
//  KindEntity.swift
//  BeMyFamily
//
//  Created by Gucci on 12/21/25.
//

import Foundation

struct KindEntity: Hashable, Identifiable {
    let id: String
    let name: String

    var image: String {
        "\(id)"
    }
}
