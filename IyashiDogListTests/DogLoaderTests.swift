//
//  DogLoaderTests.swift
//  IyashiDogListTests
//
//  Created by 宇高あゆみ on 2022/01/12.
//

import XCTest
import IyashiDogList

/** TODO list
 - Load dogs from API
 - If successful
    - Displays dogs
 - If failure
    - Shows an error message
 
 */

class DogLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedUrls.isEmpty)
    }
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "http://test-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        
        XCTAssertEqual(client.requestedUrls, [url])
    }
    
    func test_loadTwice_requestDataFromURLTwice() {
        let url = URL(string: "http://test-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requestedUrls, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        let clientError = NSError(domain: "Test", code: 0)
        
        var capturedErrors = [RemoteDogLoader.Error]()
        
        sut.load { capturedErrors.append($0) }
        client.complete(with: clientError)

        XCTAssertEqual(capturedErrors, [.connectivity])
    }

    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "http://a-url.com")!) -> (sut: RemoteDogLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteDogLoader(client: client, url: url)
        return (sut: sut, client: client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedUrls = [URL]()
        var completions = [(Error) -> Void]()
        
        func get(from url: URL, completion: @escaping (Error) -> Void) {
            self.completions.append(completion)
            self.requestedUrls.append(url)
        }
        
        func complete(with error: Error, at index: Int = 0) {
            self.completions[index](error)
        }
    }
}
