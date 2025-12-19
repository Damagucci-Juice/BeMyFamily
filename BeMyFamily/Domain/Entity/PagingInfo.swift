//
//  PagingInfo.swift
//  BeMyFamily
//
//  Created by Gucci on 12/20/25.
//
import Foundation

struct PagingInfo {
    let pageNo: Int
    let pageSize: Int
    let hasMore: Bool
    
    init(pageNo: Int = 1, pageSize: Int = 20, hasMore: Bool = false) {
        self.pageNo = pageNo
        self.pageSize = pageSize
        self.hasMore = hasMore
    }
}
