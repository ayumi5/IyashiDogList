//
//  ValidateDogCacheUseCaseTests.swift
//  IyashiDogListTests
//
//  Created by 宇高あゆみ on 2022/03/03.
//

import XCTest
import IyashiDogList

class ValidateDogCacheUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.messages, [])
    }
    
    func test_validateCache_deletesCacheOnRetrievalError() {
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.messages, [.retrieve, .deleteCache])
    }
    
    func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    func test_validateCache_doesNotDeleteCacheOnNonExpiredCache() {
        let currentDate = Date()
        let nonExpiredTimestamp = currentDate.minusCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { currentDate })
        let dogs = uniqueDogs()
        
        sut.validateCache()
        store.completeRetrieval(with: dogs.locals, timestamp: nonExpiredTimestamp)
    
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    func test_validateCache_deletesCacheOnCacheExpiration() {
        let currentDate = Date()
        let expiredTimestamp = currentDate.minusCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { currentDate })
        let dogs = uniqueDogs()
        
        sut.validateCache()
        store.completeRetrieval(with: dogs.locals, timestamp: expiredTimestamp)
    
        XCTAssertEqual(store.messages, [.retrieve, .deleteCache])
    }
    
    func test_validateCache_deletesCacheOnExpiredCache() {
        let currentDate = Date()
        let expiredTimestamp = currentDate.minusCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { currentDate })
        let dogs = uniqueDogs()

        sut.validateCache()
        store.completeRetrieval(with: dogs.locals, timestamp: expiredTimestamp)

        XCTAssertEqual(store.messages, [.retrieve, .deleteCache])
    }
    
    func test_validateCache_doesNotDeleteCacheAfterSUTInstanceHasBeenDeallocated() {
        let store = DogStoreSpy()
        var sut: LocalDogLoader? = LocalDogLoader(store: store, currentDate: Date.init)
        
        sut?.validateCache()
        sut = nil
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalDogLoader, store: DogStoreSpy) {
        let store = DogStoreSpy()
        let sut = LocalDogLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut: sut, store: store)
    }
}
