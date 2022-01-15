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
    
    public enum Result: Equatable {
        case success([Dog])
        case failure(Error)
    }
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(client: HTTPClient, url: URL = URL(string: "http://url.com")!) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success(response, data):
                completion(DogItemsMapper.map(data, response))
            case .failure:
                completion(.failure(.connectivity))
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
            return .failure(.invalidData)
        }
    }
}
