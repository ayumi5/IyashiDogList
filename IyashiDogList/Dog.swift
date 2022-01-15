//
//  Dog.swift
//  IyashiDogList
//
//  Created by 宇高あゆみ on 2022/01/15.
//

import Foundation

public struct Dog: Equatable, Decodable {
    public var imageURL: URL
    
    public init(imageURL: URL) {
        self.imageURL = imageURL
    }
}
