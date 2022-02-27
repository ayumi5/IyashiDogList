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
    
    private var deleleCompletions = [DeletionCompletion]()
    enum ReceivedMessage: Equatable {
        case deleteCache
        case insert([Dog], Date)
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
    
    func insert(_ dogs: [Dog], timestamp: Date) {
        messages.append(.insert(dogs, timestamp))
    }
}

class SaveDogCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.messages, [])
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let dogs: [Dog] = [uniqueDog(), uniqueDog()]
        
        sut.save(dogs)
        
        XCTAssertEqual(store.messages, [.deleteCache])
    }
    
    func test_save_doesNotRequestInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let dogs: [Dog] = [uniqueDog(), uniqueDog()]
        let deletionError = anyNSError()
        
        sut.save(dogs)
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.messages, [.deleteCache])
    }
    
    func test_save_requestsCacheInsertionWithTimestmpOnSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        let dogs: [Dog] = [uniqueDog(), uniqueDog()]
        
        sut.save(dogs)
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.messages, [.deleteCache, .insert(dogs, timestamp)])
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
    
    private func anyNSError() -> NSError {
        NSError.init(domain: "any error", code: 0)
    }
    
}
