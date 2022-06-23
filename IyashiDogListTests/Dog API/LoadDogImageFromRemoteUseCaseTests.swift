//
//  LoadDogImageFromRemoteUseCaseTests.swift
//  IyashiDogListTests
//
//  Created by 宇高あゆみ on 2022/06/23.
//

import XCTest
import IyashiDogList

final class RemoteDogImageDataLoader {
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func loadImageData(from url: URL) {
        client.get(from: url) { _ in }
    }
}

class LoadDogImageFromRemoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotPerformAnyURLRequest() {
        let (_, client) = makeSUT()

        XCTAssertEqual(client.requestedURLs, [])
    }
    
    func test_loadImageData_requestsDataFromURL() {
        let (sut, client) = makeSUT()
        let url = URL(string: "https://a-url.com")!
        
        sut.loadImageData(from: url)
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    // MARK: - Helpers
    private class LoaderSpy: HTTPClient {
        var requestedURLs = [URL]()
        
        func get(from url: URL, completion: @escaping (HTTPClientResult?) -> Void) {
            requestedURLs.append(url)
        }
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: RemoteDogImageDataLoader, client: LoaderSpy) {
        let client = LoaderSpy()
        let sut = RemoteDogImageDataLoader(client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        
        return (sut, client)
    }
}
