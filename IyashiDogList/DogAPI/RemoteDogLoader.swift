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
                completion(.failure(RemoteDogLoader.Error.connectivity))
            default:
                break
            }
        }
    }
}

final class DogItemsMapper {
    private init() {}
    
    private struct DogRoot: Decodable {
        var message: [URL]
        
        var dogs: [Dog] {
            return message.map { Dog(imageURL: $0) }
        }
    }
    
    static private let OK_200 = 200
    
    static func map(_ data: Data, _ response: HTTPURLResponse) -> RemoteDogLoader.Result {
        if response.statusCode == OK_200, let json = try? JSONDecoder().decode(DogRoot.self, from: data) {
            return .success(json.dogs)
        } else {
            return .failure(RemoteDogLoader.Error.invalidData)
        }
    }
}
