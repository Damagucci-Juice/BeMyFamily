//
//  CacheEntryObject.swift
//  BeMyFamily
//
//  Created by Gucci on 4/17/24.
//

import Foundation

enum CacheEntry {
    case inprogress(Task<Data, Error>)
    case ready(Data)
}

final class CacheEntryObject {
    let entry: CacheEntry
    init(entry: CacheEntry) { self.entry = entry }
}
