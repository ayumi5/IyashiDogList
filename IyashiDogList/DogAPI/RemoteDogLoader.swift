//
//  RemoteDogLoader.swift
//  IyashiDogList
//
//  Created by 宇高あゆみ on 2022/01/12.
//

import Foundation
import IyashiDogFeature

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
                completion(RemoteDogLoader.map(data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            default:
                break
            }
        }
    }
    
    public static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let dogs = try DogItemsMapper.map(data, response)
            return .success(dogs.toModels())
        } catch {
            return .failure(error)
        }
        
    }
}

extension Array where Element == RemoteDog {
    func toModels() -> [Dog] {
        self.map { Dog(imageURL: $0.imageURL) }
    }
}
