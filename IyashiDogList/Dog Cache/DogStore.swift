//
//  DogStore.swift
//  IyashiDogList
//
//  Created by 宇高あゆみ on 2022/03/02.
//

import Foundation

public enum RetrieveCacheResult {
    case empty
    case found([LocalDog], Date)
    case failure(Error)
}

public protocol DogStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (RetrieveCacheResult) -> Void
    
    func deleteCache(completion: @escaping DeletionCompletion)
    func insert(_ dogs: [LocalDog], timestamp: Date, completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}
