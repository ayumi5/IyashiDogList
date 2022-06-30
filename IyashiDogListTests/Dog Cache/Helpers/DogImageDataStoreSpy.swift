//
//  DogImageDataStoreSpy.swift
//  IyashiDogListTests
//
//  Created by 宇高あゆみ on 2022/06/30.
//

import Foundation
import IyashiDogList

class DogImageDataStoreSpy: DogImageStore {
    var messages = [Message]()
    private var retrievalCompletions = [RetrievalCompletion]()
    enum Message: Equatable {
        case retrieve(from: URL)
        case insert(to: URL)
    }
    
    func insert(to url: URL) {
        messages.append(.insert(to: url))
    }
    
    func retrieve(from url: URL, completion: @escaping RetrievalCompletion){
        messages.append(.retrieve(from: url))
        retrievalCompletions.append(completion)
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }
    
    func completeRetrievalWithEmptyCache(at index: Int = 0) {
        let emptyData = Data()
        retrievalCompletions[index](.success(emptyData))
    }
    
    func completeRetrieval(with data: Data, at index: Int = 0) {
        retrievalCompletions[index](.success(data))
    }
}
