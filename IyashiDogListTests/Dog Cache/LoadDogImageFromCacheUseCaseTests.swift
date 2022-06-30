//
//  LoadDogImageFromCacheUseCaseTests.swift
//  IyashiDogListTests
//
//  Created by 宇高あゆみ on 2022/06/30.
//

import XCTest
import IyashiDogList
import IyashiDogFeature

protocol DogImageStore {
    typealias RetrievalCompletion = (DogImageDataLoader.Result) -> Void
    
    func retrieve(from url: URL, completion: @escaping RetrievalCompletion)
}

final class LocalDogImageDataLoader: DogImageDataLoader {
    private let store: DogImageDataStoreSpy
    
    enum LoadError: Swift.Error {
        case failed
        case notFound
    }
    
    init(store: DogImageDataStoreSpy) {
        self.store = store
    }
    
    private final class LocalDogImageDataLoaderTask: DogImageDataLoaderTask {
        private var completion: ((DogImageDataLoader.Result) -> Void)?
        
        init(completion: @escaping (DogImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func cancel() {
            preventFurtherCompletion()
        }
        
        func complete(with result: DogImageDataLoader.Result) {
            completion?(result)
        }
        
        private func preventFurtherCompletion() {
            completion = nil
        }
    }
    
    func loadImageData(from url: URL, completion: @escaping (DogImageDataLoader.Result) -> Void) -> DogImageDataLoaderTask {
        let task = LocalDogImageDataLoaderTask(completion: completion)
        store.retrieve(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success(data):
                if data.isEmpty {
                    task.complete(with: .failure(LoadError.notFound))
                } else {
                    task.complete(with: .success(data))
                }
            case .failure:
                task.complete(with: .failure(LoadError.failed))
            }
        }
        return task
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
    
    func test_loadImageData_deliversFailedErrorOnStoreError() {
        let (sut, store) = makeSUT()
        
        expect(sut: sut, toCompleteWith: failure(.failed), when: {
            store.complete(with: anyNSError())
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

    func test_cancelLoadImageData_doesNotDeliverResultAfterCancellingTask() {
        let (sut, store) = makeSUT()
        
        var receivedResults = [DogImageDataLoader.Result]()
        let task = sut.loadImageData(from: anyURL()) { result in
            receivedResults.append(result)
        }
        task.cancel()
        
        let imageData = anyData()
        store.complete(with: imageData)
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    func test_loadImageData_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let store = DogImageDataStoreSpy()
        var sut: LocalDogImageDataLoader? = LocalDogImageDataLoader(store: store)
        
        var receivedResult: DogImageDataLoader.Result?
        _ = sut?.loadImageData(from: anyURL()) { result in
            receivedResult = result
        }
        
        sut = nil
        store.complete(with: anyData())
        
        XCTAssertNil(receivedResult)
        
    }
    
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalDogImageDataLoader, store: DogImageDataStoreSpy) {
        let store = DogImageDataStoreSpy()
        let sut = LocalDogImageDataLoader(store: store)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        
        return (sut, store)
    }
    
    private func expect(sut: DogImageDataLoader, toCompleteWith expectedResult: DogImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
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
    
    private func failure(_ error: LocalDogImageDataLoader.LoadError) -> DogImageDataLoader.Result {
        .failure(error)
    }

}

class DogImageDataStoreSpy: DogImageStore {
    var messages = [Message]()
    private var completions = [RetrievalCompletion]()
    enum Message: Equatable {
        case retrieve(from: URL)
    }
    
    func retrieve(from url: URL, completion: @escaping RetrievalCompletion){
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
