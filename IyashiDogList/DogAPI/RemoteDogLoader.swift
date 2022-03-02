//
//  RemoteDogLoader.swift
//  IyashiDogList
//
//  Created by 宇高あゆみ on 2022/01/12.
//

import Foundation

public final class RemoteDogLoader: DogLoader {
    private let client: HTTPClient
    private let url: URL
    
    public typealias Result = DogLoader.Result
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(client: HTTPClient, url: URL = URL(string: "http://url.com")!) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success(data, response):
                completion(DogItemsMapper.map(data, response))
            case .failure:
                completion(.failure(Error.connectivity))
            default:
                break
            }
        }
    }
}
