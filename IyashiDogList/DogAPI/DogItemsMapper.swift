//
//  DogItemsMapper.swift
//  IyashiDogList
//
//  Created by 宇高あゆみ on 2022/01/17.
//

import Foundation

final class DogItemsMapper {
    private init() {}
    
    private struct DogRoot: Decodable {
        var message: [URL]
        
        var dogs: [RemoteDog] {
            return message.map { RemoteDog(imageURL: $0) }
        }
    }
    
    static private let OK_200 = 200
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteDog] {
        guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(DogRoot.self, from: data) else {
            throw RemoteDogLoader.Error.invalidData
        }
        
        return root.dogs
    }
}

public struct RemoteDog: Equatable, Decodable {
    public var imageURL: URL
    
    public init(imageURL: URL) {
        self.imageURL = imageURL
    }
}

