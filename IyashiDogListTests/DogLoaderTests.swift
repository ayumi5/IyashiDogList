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
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedUrls, [url])
    }
    
    func test_loadTwice_requestDataFromURLTwice() {
        let url = URL(string: "http://test-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
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
    
    func test_load_deliversInvalidDataErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
            
        let statusCodes = [199, 201, 300, 400]
        statusCodes.enumerated().forEach { index, code in
            var capturedErrors = [RemoteDogLoader.Error]()
            sut.load { capturedErrors.append($0) }
            client.complete(withStatusCode: code, at: index)
            XCTAssertEqual(capturedErrors, [.invalidData])
        }
    }

    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "http://a-url.com")!) -> (sut: RemoteDogLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteDogLoader(client: client, url: url)
        return (sut: sut, client: client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var messages =  [(url: URL, completion: (Error?, HTTPURLResponse?) -> Void)]()

        var requestedUrls: [URL] {
            return messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (Error?, HTTPURLResponse?) -> Void) {
            self.messages.append((url: url, completion: completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            self.messages[index].completion(error, nil)
        }
        
        func complete(withStatusCode: Int, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: self.requestedUrls[index],
                statusCode: 400,
                httpVersion: nil,
                headerFields: nil)
            self.messages[index].completion(nil, response)
        }
    }
}
