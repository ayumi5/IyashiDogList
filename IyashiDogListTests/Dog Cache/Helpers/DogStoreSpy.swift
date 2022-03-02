//
//  DogStoreSpy.swift
//  IyashiDogListTests
//
//  Created by 宇高あゆみ on 2022/03/02.
//

import Foundation
import IyashiDogList

class DogStoreSpy: DogStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (RetrieveCacheResult) -> Void
    
    private var deleleCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()
    private var retrievalCompletions = [RetrievalCompletion]()
    
    enum ReceivedMessage: Equatable {
        case deleteCache
        case insert([LocalDog], Date)
        case retrieve
    }
    var messages = [ReceivedMessage]()
    
    func deleteCache(completion: @escaping DeletionCompletion) {
        deleleCompletions.append(completion)
        messages.append(.deleteCache)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deleleCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deleleCompletions[index](nil)
    }
    
    func insert(_ dogs: [LocalDog], timestamp: Date, completion: @escaping InsertionCompletion) {
        messages.append(.insert(dogs, timestamp))
        insertionCompletions.append(completion)
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](error)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](nil)
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        messages.append(.retrieve)
        retrievalCompletions.append(completion)
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }
    
    func completeRetrievalWithEmptyCache(at index: Int = 0) {
        retrievalCompletions[index](.empty)
    }
    
    func completeRetrievalOnLessThanSevenDaysOldCache(with dogs: [LocalDog], timestamp: Date, at index: Int = 0) {
        retrievalCompletions[index](.found(dogs, timestamp))
    }
}
