//
//  RemoteDogLoader.swift
//  IyashiDogList
//
//  Created by 宇高あゆみ on 2022/01/12.
//

import Foundation

public final class RemoteDogLoader {
    private let client: HTTPClient
    private let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(client: HTTPClient, url: URL = URL(string: "http://url.com")!) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Error) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success(response, data):
                if response.statusCode != 200 {
                    completion(.invalidData)
                } else {      
                    do {
                        try JSONSerialization.jsonObject(with: data)
                    } catch {
                        completion(.invalidData)
                    }
                }
            case .failure:
                completion(.connectivity)
            default:
                break
            }
        }
    }
}

public enum HTTPClientResult {
    case success(HTTPURLResponse, Data)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult?) -> Void)
}
