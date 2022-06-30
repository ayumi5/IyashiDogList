//
//  DogImageStore.swift
//  IyashiDogList
//
//  Created by 宇高あゆみ on 2022/06/30.
//

import IyashiDogFeature
import Foundation

public protocol DogImageStore {
    typealias Result = Swift.Result<Data, Error>
    
    typealias RetrievalCompletion = (Result) -> Void
    
    func retrieve(from url: URL, completion: @escaping RetrievalCompletion)
    func insert(to url: URL)
}
