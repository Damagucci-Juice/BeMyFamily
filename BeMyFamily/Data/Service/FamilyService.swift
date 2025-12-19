//
//  FriendSearchService.swift
//  BeMyFamily
//
//  Created by Gucci on 4/11/24.
//

import Foundation
import Combine

public enum HTTPError: Error {
    case notFoundResponse
    case dataEmtpy(_ errorMessage: String)
    case invalidResponse(_ errorCode: Int)
}

public struct HttpStatusCode {
    public struct Informational {
        static let range = 100..<200
    }

    public struct Success {
        static let range = 200..<300
    }

    public struct Redirection {
        static let range = 300..<400
    }

    public struct ClientError {
        static let range = 400..<500
        static let badRequest = 400
        static let notFoundError = 401
    }

    public struct ServerError {
        static let range = 500..<600
    }
}

protocol SearchService: AnyObject {
    func search(_ endpoint: FamilyEndpoint) async throws -> Data
    func performRequest(urlRequest: URLRequest) async throws -> Data
}

final class FamilyService: SearchService {
    private let session: URLSession
    private let friendCache: NSCache<NSString, CacheEntryObject> = NSCache()

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func search(_ endpoint: FamilyEndpoint) async throws -> Data {
        do {
            return try await performRequest(urlRequest: endpoint.makeURLRequest())
        } catch {
            throw error
        }
    }

    public func performRequest(urlRequest: URLRequest) async throws -> Data {
        guard let url = urlRequest.url else {
            throw HTTPError.invalidResponse(HttpStatusCode.ClientError.notFoundError)
        }
        if let cached = friendCache[url] {
            switch cached {
            case .ready(let result):
                return result
            case .inprogress(let task):
                return try await task.value
            }
        }
        let task = Task<Data, Error> {
            let (data, _) = try await session.data(for: urlRequest, delegate: nil)
            return data
        }

        friendCache[url] = .inprogress(task)
        do {
            let fetchedData = try await task.value
            friendCache[url] = .ready(fetchedData)
            return fetchedData
        } catch {
            friendCache[url] = nil
            throw HTTPError.invalidResponse(HttpStatusCode.ClientError.notFoundError)
        }
    }
}
