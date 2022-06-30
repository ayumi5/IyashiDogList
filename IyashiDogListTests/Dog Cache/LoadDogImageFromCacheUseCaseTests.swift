//
//  LoadDogImageFromCacheUseCaseTests.swift
//  IyashiDogListTests
//
//  Created by 宇高あゆみ on 2022/06/30.
//

import XCTest
import IyashiDogList
import IyashiDogFeature

private final class LocalDogImageDataLoader {
    typealias Result = Swift.Result<Data, Error>

    private let store: DogImageDataStoreSpy
    
    init(store: DogImageDataStoreSpy) {
        self.store = store
    }
    
    private struct Task: DogImageDataLoaderTask {
        func cancel() {
        }
    }
    
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> DogImageDataLoaderTask {
        store.retrieve(from: url)
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

    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalDogImageDataLoader, store: DogImageDataStoreSpy) {
        let store = DogImageDataStoreSpy()
        let sut = LocalDogImageDataLoader(store: store)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        
        return (sut, store)
    }
    
}

class DogImageDataStoreSpy {
    var messages = [Message]()
    enum Message: Equatable {
        case retrieve(from: URL)
    }
    
    func retrieve(from url: URL) {
        messages.append(.retrieve(from: url))
    }
}
