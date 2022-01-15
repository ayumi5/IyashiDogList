//
//  DogLoader.swift
//  IyashiDogList
//
//  Created by 宇高あゆみ on 2022/01/15.
//

import Foundation

public protocol DogLoader {
    typealias Result = Swift.Result<[Dog], Error>
    
    func load(completion: @escaping (Result) -> Void)
}
