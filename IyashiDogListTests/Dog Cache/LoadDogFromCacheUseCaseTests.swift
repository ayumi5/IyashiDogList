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
    
    func test_load_requestsCacheRetrieval() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(retrievalError), when: {
            store.completeRetrieval(with: retrievalError)
        })
    }
    
    func test_load_deliversNoDogOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetrievalWithEmptyCache()
        })
    }
    
    func test_load_deliversDogOnNonExpiredCache() {
        let currentDate = Date()
        let nonExpiredTimestamp = currentDate.minusCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { currentDate })
        let dogs = uniqueDogs()
        
        expect(sut, toCompleteWith: .success(dogs.models), when: {
            store.completeRetrieval(with: dogs.locals, timestamp: nonExpiredTimestamp)
        })
    }
    
    func test_load_doesNotDeliverDogOnCacheExpirarion() {
        let currentDate = Date()
        let expiredTimestamp = currentDate.minusCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { currentDate })
        let dogs = uniqueDogs()

        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetrieval(with: dogs.locals, timestamp: expiredTimestamp)
        })
    }
    
    func test_load_doesNotDeliverDogOnExpiredCache() {
        let currentDate = Date()
        let expiredTimestamp = currentDate.minusCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { currentDate })
        let dogs = uniqueDogs()

        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetrieval(with: dogs.locals, timestamp: expiredTimestamp)
        })
    }
    
    func test_load_hasNoSideEffectsOnRetrievalError() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnNonExpiredCache() {
        let currentDate = Date()
        let nonExpiredTimestamp = currentDate.minusCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { currentDate })
        let dogs = uniqueDogs()
        
        sut.load { _ in }
        store.completeRetrieval(with: dogs.locals, timestamp: nonExpiredTimestamp)
    
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnCacheExpiration() {
        let currentDate = Date()
        let expiredTimestamp = currentDate.minusCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { currentDate })
        let dogs = uniqueDogs()
        
        sut.load { _ in }
        store.completeRetrieval(with: dogs.locals, timestamp: expiredTimestamp)
    
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnExpiredCache() {
        let currentDate = Date()
        let expiredTimestamp = currentDate.minusCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { currentDate })
        let dogs = uniqueDogs()
        
        sut.load { _ in }
        store.completeRetrieval(with: dogs.locals, timestamp: expiredTimestamp)
    
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let store = DogStoreSpy()
        var sut: LocalDogLoader? = LocalDogLoader(store: store, currentDate: Date.init)
        var receivedResults = [LocalDogLoader.LoadResult]()
        
        sut?.load { receivedResults.append($0) }
        sut = nil
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalDogLoader, store: DogStoreSpy) {
        let store = DogStoreSpy()
        let sut = LocalDogLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut: sut, store: store)
    }
    
    private func expect(_ sut: LocalDogLoader, toCompleteWith expectedResult: LocalDogLoader.LoadResult, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for load completion")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedDogs), .success(expectedDogs)):
                XCTAssertEqual(receivedDogs, expectedDogs, file: file, line: line)
            case let (.failure(receivedError as NSError?), .failure(expectedError as NSError?)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
                
            }
            exp.fulfill()
        }
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}
