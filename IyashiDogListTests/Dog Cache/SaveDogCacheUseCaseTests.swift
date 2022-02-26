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
    
    func save(_ dogs: [Dog]) {
        store.deleteCache { [unowned self] error in
            if error == nil {
                self.store.insert(dogs)
            }
        }
    }
}

class DogStore {
    typealias DeletionCompletion = (Error?) -> Void
    
    var deleteCachedDogCallCount = 0
    var insertCacheCallCount = 0
    private var deleleCompletions = [DeletionCompletion]()
    
    func deleteCache(completion: @escaping DeletionCompletion) {
        deleteCachedDogCallCount += 1
        deleleCompletions.append(completion)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deleleCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deleleCompletions[index](nil)
    }
    
    func insert(_ dogs: [Dog]) {
        insertCacheCallCount += 1
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
    
    func test_save_doesNotRequestInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let dogs: [Dog] = [uniqueDog(), uniqueDog()]
        let deletionError = anyNSError()
        
        sut.save(dogs)
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.insertCacheCallCount, 0)
    }
    
    func test_save_requestsNewCacheInsertionOnSuccessfulDeletion() {
        let (sut, store) = makeSUT()
        let dogs: [Dog] = [uniqueDog(), uniqueDog()]
        
        sut.save(dogs)
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.insertCacheCallCount, 1)
    }
    
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalDogLoader, store: DogStore) {
        let store = DogStore()
        let sut = LocalDogLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut: sut, store: store)
    }
    
    private func uniqueDog() -> Dog {
        Dog(imageURL: uniqueURL())
    }
    
    private func uniqueURL() -> URL {
        URL(string: "http://unique-url-\(UUID()).com")!
    }
    
    private func anyNSError() -> Error {
        NSError.init(domain: "any error", code: 0)
    }
    
}
