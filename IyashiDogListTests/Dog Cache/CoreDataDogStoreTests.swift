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
        
        let exp = expectation(description: "Wait for retrieval completion")
        sut.retrieve { result in
            switch result {
            case .empty: break
            default:
                XCTFail("Expected empty result, got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for retrieval completion")
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty): break
                default:
                    XCTFail("Expected two empty results, got \(firstResult) and \(secondResult) instead")
                }
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieveAfterInserting_deliversInsertedValues() {
        let sut = makeSUT()
        let timestamp = Date()
        let dogs = uniqueDogs()
        
        let exp = expectation(description: "Wait for retrieval completion")
        insert((dogs.locals, timestamp), to: sut)
        sut.retrieve { result in
            switch result {
            case let .found(foundDogs, foundTimestamp):
                XCTAssertEqual(dogs.locals, foundDogs)
                XCTAssertEqual(timestamp, foundTimestamp)
            default:
                XCTFail("Expected to find the previously inserted values, got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let timestamp = Date()
        let dogs = uniqueDogs()
        
        let exp = expectation(description: "Wait for retrieval completion")
        insert((dogs.locals, timestamp), to: sut)
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case let (.found(firstDogs, firstTimestamp), .found(secondDogs, secondTimestamp)):
                    XCTAssertEqual(firstDogs, secondDogs)
                    XCTAssertEqual(firstTimestamp, secondTimestamp)
                default:
                    XCTFail("Expected to find the same inserted values, got \(firstResult) and \(secondResult) instead")
                }
                exp.fulfill()
            }
        }
        
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_insert_overridesPreviouslyInsertedCachedValues() {
        let sut = makeSUT()
        let firstDogs = uniqueDogs()
        let firstTimestamp = Date()
        let secondDogs = uniqueDogs()
        let secondTimestamp = Date()
        
        insert((firstDogs.locals, firstTimestamp), to: sut)
        insert((secondDogs.locals, secondTimestamp), to: sut)
        
        sut.retrieve { result in
            switch result {
            case let .found(foundDogs, foundTimestamp):
                XCTAssertEqual(foundDogs, secondDogs.locals)
                XCTAssertEqual(foundTimestamp, secondTimestamp)
            default:
                XCTFail("Expected to find overrided cached values, got \(result) instead")
            }
        }
    }

    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CoreDataDogStore {
        let storeBundle = Bundle(for: CoreDataDogStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataDogStore(storeURL: storeURL, bundle: storeBundle)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
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
