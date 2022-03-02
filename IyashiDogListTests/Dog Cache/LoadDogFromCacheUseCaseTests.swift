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
        var receivedError: Error?
        
        let exp = expectation(description: "Wait for load completion")
        sut.load { result in
            switch result {
            case let .failure(error):
                receivedError = error
            default:
                XCTFail("Expected failure , got \(result) instead")
            }
            exp.fulfill()
        }
        store.completeRetrieval(with: retrievalError)
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as NSError?, retrievalError)
    }
    
    func test_load_deliversNoDogOnEmptyCache() {
        let (sut, store) = makeSUT()
        var receivedDogs: [Dog]?
        
        let exp = expectation(description: "Wait for load completion")
        sut.load { result in
            switch result {
            case let .success(dogs):
                receivedDogs = dogs
           default:
                XCTFail("Expected success, got \(result) instead")
            }
            exp.fulfill()
        }
        store.completeRetrievalWithEmptyCache()
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedDogs, [])
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
}
