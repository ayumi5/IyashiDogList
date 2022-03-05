//
//  CoreDataDogStoreTests.swift
//  IyashiDogListTests
//
//  Created by 宇高あゆみ on 2022/03/03.
//

import XCTest
import IyashiDogList

class CoreDataDogStoreTests: XCTestCase {

    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrieveTwice: .empty)
    }
    
    func test_retrieveAfterInserting_deliversInsertedValues() {
        let sut = makeSUT()
        let timestamp = Date()
        let dogs = uniqueDogs()
        
        insert((dogs.locals, timestamp), to: sut)
        expect(sut, toRetrieve: .found(dogs.locals, timestamp))
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let timestamp = Date()
        let dogs = uniqueDogs()
        
        insert((dogs.locals, timestamp), to: sut)
        expect(sut, toRetrieveTwice: .found(dogs.locals, timestamp))
    }
    
    func test_insert_overridesPreviouslyInsertedCachedValues() {
        let sut = makeSUT()
        let firstDogs = uniqueDogs()
        let firstTimestamp = Date()
        let secondDogs = uniqueDogs()
        let secondTimestamp = Date()
        
        insert((firstDogs.locals, firstTimestamp), to: sut)
        insert((secondDogs.locals, secondTimestamp), to: sut)
        
        expect(sut, toRetrieve: .found(secondDogs.locals, secondTimestamp))
    }

    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CoreDataDogStore {
        let storeBundle = Bundle(for: CoreDataDogStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataDogStore(storeURL: storeURL, bundle: storeBundle)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: CoreDataDogStore, toRetrieve expectedResult: RetrieveCacheResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retrieval")
        sut.retrieve { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.empty, .empty):
                break
            case let (.found(receivedDogs, receivedTimestamp), .found(expectedDogs, expectedTimestamp)):
                XCTAssertEqual(receivedDogs, expectedDogs, file: file, line: line)
                XCTAssertEqual(receivedTimestamp, expectedTimestamp, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(_ sut: CoreDataDogStore, toRetrieveTwice expectedResult: RetrieveCacheResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    private func insert(_ cache: (dogs: [LocalDog], timestamp: Date), to sut: CoreDataDogStore) {
        let insertionExp = expectation(description: "Wait for insert completion")
        sut.insert(cache.dogs, timestamp: cache.timestamp) { error in
            XCTAssertNil(error, "Expected to insert cache successfully")
            insertionExp.fulfill()
        }
        
        wait(for: [insertionExp], timeout: 1.0)
    }
    

}
