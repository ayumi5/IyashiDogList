//
//  LocalDog.swift
//  IyashiDogList
//
//  Created by 宇高あゆみ on 2022/03/02.
//

import Foundation

public struct LocalDog: Equatable, Decodable {
    public var imageURL: URL
    
    public init(imageURL: URL) {
        self.imageURL = imageURL
    }
}
