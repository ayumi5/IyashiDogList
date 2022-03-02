//
//  DogStore.swift
//  IyashiDogList
//
//  Created by 宇高あゆみ on 2022/03/02.
//

import Foundation

public protocol DogStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func deleteCache(completion: @escaping DeletionCompletion)
    func insert(_ dogs: [Dog], timestamp: Date, completion: @escaping InsertionCompletion)
}
