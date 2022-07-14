//
//  SaveDogImageCacheUseCaseTests.swift
//  IyashiDogListTests
//
//  Created by 宇高あゆみ on 2022/06/30.
//

import XCTest
import IyashiDogList


class SaveDogImageCacheUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStore() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.messages, [])
    }
    
    func test_saveImageData_requestsInsertion() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        
        sut.saveImageData(to: url) { _ in }
        
        XCTAssertEqual(store.messages, [.insert(to: url)])
    }
    
    func test_saveImageData_deliversSavingErrorOnInsertionError() {
        let (sut, store) = makeSUT()
        
        expect(sut: sut, toCompleteWith: failure(.failed), when: {
            store.completeInsertion(with: anyNSError())
        })
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalDogImageDataLoader, store: DogImageDataStoreSpy) {
        let store = DogImageDataStoreSpy()
        let sut = LocalDogImageDataLoader(store: store)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        
        return (sut, store)
    }
    
    private func expect(sut: LocalDogImageDataLoader, toCompleteWith expectedResult: DogImageStore.InsertionResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for saving")
        sut.saveImageData(to: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success, .success): break
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult), got \(String(describing: receivedResult)) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func failure(_ error: LocalDogImageDataLoader.SaveError) -> LocalDogImageDataLoader.SaveResult {
        return .failure(error)
    }
}
