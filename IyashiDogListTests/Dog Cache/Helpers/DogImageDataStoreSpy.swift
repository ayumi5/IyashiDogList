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
    private var completions = [RetrievalCompletion]()
    enum Message: Equatable {
        case retrieve(from: URL)
    }
    
    func retrieve(from url: URL, completion: @escaping RetrievalCompletion){
        messages.append(.retrieve(from: url))
        completions.append(completion)
    }
    
    func complete(with error: Error, at index: Int = 0) {
        completions[index](.failure(error))
    }
    
    func completeWithEmptyCache(at index: Int = 0) {
        let emptyData = Data()
        completions[index](.success(emptyData))
    }
    
    func complete(with data: Data, at index: Int = 0) {
        completions[index](.success(data))
    }
}
