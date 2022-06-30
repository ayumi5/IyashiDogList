//
//  LoadDogImageFromCacheUseCaseTests.swift
//  IyashiDogListTests
//
//  Created by 宇高あゆみ on 2022/06/30.
//

import XCTest
import IyashiDogList
import IyashiDogFeature

final class LocalDogImageDataLoader {
    typealias Result = Swift.Result<Data, Error>

    private let store: DogImageDataStoreSpy
    
    enum RetrievalError: Swift.Error {
        case notFound
    }
    
    init(store: DogImageDataStoreSpy) {
        self.store = store
    }
    
    private struct Task: DogImageDataLoaderTask {
        func cancel() {
        }
    }
    
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> DogImageDataLoaderTask {
        store.retrieve(from: url) { result in
            switch result {
            case let .success(data):
                if data.isEmpty {
                    completion(.failure(RetrievalError.notFound))
                } else {
                    completion(.success(data))
                }
            case let .failure(error):
                completion(.failure(error))
                
            }
        }
        return Task()
    }
}

class LoadDogImageFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStore() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.messages, [])
    }
    
    func test_loadImageData_requestsDogImageCacheRetrievalFromURL() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(store.messages, [.retrieve(from: url)])
    }
    
    func test_loadImageData_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        
        expect(sut: sut, toCompleteWith: .failure(retrievalError), when: {
            store.complete(with: retrievalError)
        })
    }
    
    func test_loadImageData_deliversNotFoundErrorOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        expect(sut: sut, toCompleteWith: failure(.notFound), when: {
            store.completeWithEmptyCache()
        })
    }
    
    func test_loadImageData_deliversDataForURLOnFoundData() {
        let (sut, store) = makeSUT()
        let imageData = anyData()
        
        expect(sut: sut, toCompleteWith: .success(imageData), when: {
            store.complete(with: imageData)
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
    
    private func expect(sut: LocalDogImageDataLoader, toCompleteWith expectedResult: LocalDogImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load image data completion")
        
        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
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
    
    private func failure(_ error: LocalDogImageDataLoader.RetrievalError) -> LocalDogImageDataLoader.Result {
        .failure(error)
    }

}

class DogImageDataStoreSpy {
    typealias RetrievalCompletion = (LocalDogImageDataLoader.Result) -> Void
    var messages = [Message]()
    private var completions = [RetrievalCompletion]()
    enum Message: Equatable {
        case retrieve(from: URL)
    }
    
    func retrieve(from url: URL, completion: @escaping RetrievalCompletion) {
        messages.append(.retrieve(from: url))
        completions.append(completion)
    }
    
    func complete(with error: Error, at index: Int = 0) {
        completions[index](.failure(error))
    }
    
    func completeWithEmptyCache(at index: Int = 0) {
        let emptyData = Data()
        completions[index](.success(emptyData))
    }
    
    func complete(with data: Data, at index: Int = 0) {
        completions[index](.success(data))
    }
}
