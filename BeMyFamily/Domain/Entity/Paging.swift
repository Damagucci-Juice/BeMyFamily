//
//  PagingInfo.swift
//  BeMyFamily
//
//  Created by Gucci on 12/20/25.
//
import Foundation

struct Paging {
    let currentPage: Int
    let itemsPerPage: Int
    let totalItems: Int

    init(pageNo: Int = 1, pageSize: Int = Int(NetworkConstants.Params.pageSize) ?? 10, totalItems: Int) {
        self.currentPage = pageNo
        self.itemsPerPage = pageSize
        self.totalItems = totalItems
    }

    init(_ apiResponse: APIResponse<AnimalDTO>) {
        self.init(pageNo: Int(apiResponse.pageNo) ?? 1,
                  pageSize: Int(apiResponse.numOfRows) ?? 20,
                  totalItems: Int(apiResponse.totalCount) ?? 0)
    }

    var hasMore : Bool {
        return (currentPage * itemsPerPage) < totalItems
    }
}
