//
//  LoadDogImageFromCacheUseCaseTests.swift
//  IyashiDogListTests
//
//  Created by 宇高あゆみ on 2022/06/30.
//

import XCTest
import IyashiDogList

private final class LocalDogImageDataLoader {
    private let store: DogImageDataStoreSpy
    
    init(store: DogImageDataStoreSpy) {
        self.store = store
    }
}

class LoadDogImageFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesMessageStore() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.messages, [])
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
    }
}
