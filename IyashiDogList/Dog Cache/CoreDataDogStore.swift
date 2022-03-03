//
//  CoreDataDogStore.swift
//  IyashiDogList
//
//  Created by 宇高あゆみ on 2022/03/03.
//

import Foundation

public final class CoreDataDogStore {
    public init() {}
    
    public typealias RetrievalCompletion = (RetrieveCacheResult) -> Void
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
}

