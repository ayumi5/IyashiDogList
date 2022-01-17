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
