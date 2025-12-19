//
//  APIResponse.swift
//  BeMyFamily
//
//  Created by Gucci on 4/18/24.
//

import Foundation

struct APIResponse<T: Codable>: Decodable {
    let requestNumber: Int
    let resultCode: String
    let resultMessage: String
    let items: [T]

    enum CodingKeys: String, CodingKey {
        case response
    }

    enum ResponseCodingKeys: String, CodingKey {
        case header, body
    }

    enum HeaderCodingKeys: String, CodingKey {
        case requestNumber = "reqNo"
        case resultMessage = "resultMsg"
        case resultCode
    }

    enum BodyCodingKeys: String, CodingKey {
        case items
    }

    enum ItemsCodingKeys: String, CodingKey {
        case items = "item"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let responseContainer = try container.nestedContainer(keyedBy: ResponseCodingKeys.self, forKey: .response)

        let headerContainer = try responseContainer.nestedContainer(keyedBy: HeaderCodingKeys.self, forKey: .header)
        requestNumber = try headerContainer.decode(Int.self, forKey: .requestNumber)
        resultCode = try headerContainer.decode(String.self, forKey: .resultCode)
        resultMessage = try headerContainer.decode(String.self, forKey: .resultMessage)

        let bodyContainer = try responseContainer.nestedContainer(keyedBy: BodyCodingKeys.self, forKey: .body)
        let itemsContainer = try bodyContainer.nestedContainer(keyedBy: ItemsCodingKeys.self, forKey: .items)
        items = try itemsContainer.decode([T].self, forKey: .items)
    }
}
