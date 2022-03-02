//
//  LoadDogFromCacheUseCaseTests.swift
//  IyashiDogListTests
//
//  Created by 宇高あゆみ on 2022/03/02.
//

import XCTest
import IyashiDogList

class LoadDogFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.messages, [])
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
            case insert([LocalDog], Date)
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
    }

}
