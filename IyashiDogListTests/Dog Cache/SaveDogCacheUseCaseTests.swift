//
//  SaveDogCacheUseCaseTests.swift
//  IyashiDogListTests
//
//  Created by 宇高あゆみ on 2022/02/26.
//

import XCTest

class LocalDogLoader {
    init(store: DogStore) {
        
    }
}

class DogStore {
    var deleteCachedDogCallCount = 0
}

class SaveDogCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let store = DogStore()
        let _ = LocalDogLoader(store: store)
        
        XCTAssertEqual(store.deleteCachedDogCallCount, 0)
    }
    
}
