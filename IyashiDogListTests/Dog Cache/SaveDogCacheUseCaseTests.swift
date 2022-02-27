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
    private let currentDate: () -> Date
    
    init(store: DogStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ dogs: [Dog]) {
        store.deleteCache { [unowned self] error in
            if error == nil {
                self.store.insert(dogs, timestamp: currentDate())
            }
        }
    }
}

class DogStore {
    typealias DeletionCompletion = (Error?) -> Void
    
    var insertions = [(dogs: [Dog], timestamp: Date)]()
    var deleleCompletions = [DeletionCompletion]()
    
    func deleteCache(completion: @escaping DeletionCompletion) {
        deleleCompletions.append(completion)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deleleCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deleleCompletions[index](nil)
    }
    
    func insert(_ dogs: [Dog], timestamp: Date) {
        insertions.append((dogs, timestamp))
    }
}

class SaveDogCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.deleleCompletions.count, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let dogs: [Dog] = [uniqueDog(), uniqueDog()]
        
        sut.save(dogs)
        
        XCTAssertEqual(store.deleleCompletions.count, 1)
    }
    
    func test_save_doesNotRequestInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let dogs: [Dog] = [uniqueDog(), uniqueDog()]
        let deletionError = anyNSError()
        
        sut.save(dogs)
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.insertions.count, 0)
    }
    
    func test_save_requestsNewCacheInsertionOnSuccessfulDeletion() {
        let (sut, store) = makeSUT()
        let dogs: [Dog] = [uniqueDog(), uniqueDog()]
        
        sut.save(dogs)
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.insertions.count, 1)
    }
    
    func test_save_requestsCacheInsertionWithTimestmpOnSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        let dogs: [Dog] = [uniqueDog(), uniqueDog()]
        
        
        sut.save(dogs)
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.insertions.count, 1)
        XCTAssertEqual(store.insertions.first?.dogs, dogs)
        XCTAssertEqual(store.insertions.first?.timestamp, timestamp)
    }
    
    
    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalDogLoader, store: DogStore) {
        let store = DogStore()
        let sut = LocalDogLoader(store: store, currentDate: currentDate)
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
