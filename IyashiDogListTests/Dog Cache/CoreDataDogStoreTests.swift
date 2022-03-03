//
//  CoreDataDogStoreTests.swift
//  IyashiDogListTests
//
//  Created by 宇高あゆみ on 2022/03/03.
//

import XCTest
import IyashiDogList

final class CoreDataDogStore {
    
    typealias RetrievalCompletion = (RetrieveCacheResult) -> Void
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
    
    
}

class CoreDataDogStoreTests: XCTestCase {

    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CoreDataDogStore()
        
        let exp = expectation(description: "Wait for retrieval completion")
        sut.retrieve { result in
            switch result {
            case .empty: break
            default:
                XCTFail("Expected empty result, got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }

}
