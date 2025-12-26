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
    let upKind: Upkind

    var image: String {
        if id == "216" && upKind == .cat {
            return id + "_cat"
        }

        return "\(id)"
    }

    var limittedName: String {
        name.limitText(to: 12)
    }
}
