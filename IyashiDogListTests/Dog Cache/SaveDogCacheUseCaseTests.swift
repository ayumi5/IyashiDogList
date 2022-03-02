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
    
    func save(_ dogs: [Dog], completion: @escaping (Error?) -> Void) {
        store.deleteCache { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                completion(error)
            } else {
                self.store.insert(dogs, timestamp: self.currentDate()) { [weak self] error in
                    guard self != nil else { return }
                    if let error = error {
                        completion(error)
                    } else {
                        completion(nil)
                    }
                }
            }
        }
    }
}

protocol DogStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func deleteCache(completion: @escaping DeletionCompletion)
    func insert(_ dogs: [Dog], timestamp: Date, completion: @escaping InsertionCompletion)
}

class SaveDogCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.messages, [])
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let dogs: [Dog] = [uniqueDog(), uniqueDog()]
        
        sut.save(dogs) { _ in }
        
        XCTAssertEqual(store.messages, [.deleteCache])
    }
    
    func test_save_doesNotRequestInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let dogs: [Dog] = [uniqueDog(), uniqueDog()]
        let deletionError = anyNSError()
        
        sut.save(dogs) { _ in }
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.messages, [.deleteCache])
    }
    
    func test_save_requestsCacheInsertionWithTimestmpOnSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        let dogs: [Dog] = [uniqueDog(), uniqueDog()]
        
        sut.save(dogs) { _ in }
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.messages, [.deleteCache, .insert(dogs, timestamp)])
    }
    
    func test_save_deliversFailureOnDeletionError() {
        let (sut, store) = makeSUT()
        
        let deletionError = anyNSError()
        expect(sut, toCompleteWithError: deletionError, when: {
            store.completeDeletion(with: deletionError)
        })
    }
    
    func test_save_deliversFailureOnInsertionError() {
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()
        
        expect(sut, toCompleteWithError: insertionError, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        })
    }
    
    func test_save_deliversSuccessOnSuccessfulInsertion() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWithError: nil, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        })
    }
    
    func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = DogStoreSpy()
        var sut: LocalDogLoader? = LocalDogLoader(store: store, currentDate: Date.init)
        
        var receivedErrors = [Error?]()
        sut?.save([uniqueDog()]) { receivedErrors.append($0) }
        sut = nil
        store.completeDeletion(with: anyNSError())
        
        XCTAssertTrue(receivedErrors.isEmpty)
        
    }
    
    func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = DogStoreSpy()
        var sut: LocalDogLoader? = LocalDogLoader(store: store, currentDate: Date.init)
        
        var receivedErrors = [Error?]()
        sut?.save([uniqueDog()]) { receivedErrors.append($0) }
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyNSError())
        
        XCTAssertTrue(receivedErrors.isEmpty)
        
    }
    
    
    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalDogLoader, store: DogStoreSpy) {
        let store = DogStoreSpy()
        let sut = LocalDogLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut: sut, store: store)
    }
    
    private func expect(_ sut: LocalDogLoader, toCompleteWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        var receivedError: Error?
        
        let exp = expectation(description: "Wait for save completion")
        sut.save([uniqueDog(), uniqueDog()]) { error in
            receivedError = error
            exp.fulfill()
        }
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
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
    
    class DogStoreSpy: DogStore {
        typealias DeletionCompletion = (Error?) -> Void
        typealias InsertionCompletion = (Error?) -> Void
        
        private var deleleCompletions = [DeletionCompletion]()
        private var insertionCompletions = [InsertionCompletion]()
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
        
        func insert(_ dogs: [Dog], timestamp: Date, completion: @escaping InsertionCompletion) {
            messages.append(.insert(dogs, timestamp))
            insertionCompletions.append(completion)
        }
        
        func completeInsertion(with error: Error, at index: Int = 0) {
            insertionCompletions[index](error)
        }
        
        func completeInsertionSuccessfully(at index: Int = 0) {
            insertionCompletions[index](nil)
        }
    }

}
