//
//  Response.swift
//  BeMyFamily
//
//  Created by Gucci on 4/18/24.
//

import Foundation

struct Response<T: Codable>: Codable {
    let results: [T]
}
