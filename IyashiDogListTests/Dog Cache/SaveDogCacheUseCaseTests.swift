//
//  SaveDogCacheUseCaseTests.swift
//  IyashiDogListTests
//
//  Created by 宇高あゆみ on 2022/02/26.
//

import XCTest
import IyashiDogList

class LocalDogLoader {
    private let store: DogStore
    init(store: DogStore) {
        self.store = store
    }
    
    func save(_ items: [Dog]) {
        store.deleteCache()
    }
}

class DogStore {
    var deleteCachedDogCallCount = 0
    
    func deleteCache() {
        deleteCachedDogCallCount += 1
    }
}

class SaveDogCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.deleteCachedDogCallCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let dogs: [Dog] = [uniqueDog(), uniqueDog()]
        
        sut.save(dogs)
        
        XCTAssertEqual(store.deleteCachedDogCallCount, 1)
    }
    
    
    // MARK: - Helpers
    private func makeSUT() -> (sut: LocalDogLoader, store: DogStore) {
        let store = DogStore()
        let sut = LocalDogLoader(store: store)
        
        return (sut: sut, store: store)
    }
    
    private func uniqueDog() -> Dog {
        Dog(imageURL: uniqueURL())
    }
    
    private func uniqueURL() -> URL {
        URL(string: "http://unique-url-\(UUID()).com")!
    }
    
}
