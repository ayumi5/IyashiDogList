//
//  DogImageStore.swift
//  IyashiDogList
//
//  Created by 宇高あゆみ on 2022/06/30.
//

import IyashiDogFeature
import Foundation

public protocol DogImageStore {
    typealias RetrievalResult = Swift.Result<Data, Error>
    typealias InsertionResult = Swift.Result<Void, Error>
    
    typealias RetrievalCompletion = (RetrievalResult) -> Void
    typealias InsertionCompletion = (InsertionResult) -> Void
    
    func retrieve(from url: URL, completion: @escaping RetrievalCompletion)
    func insert(_ data: Data, to url: URL, completion: @escaping InsertionCompletion)
}
