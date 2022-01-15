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
        
        expect(sut, completeWith: .failure(RemoteDogLoader.Error.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }
    
    func test_load_deliversInvalidDataErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let statusCodes = [199, 201, 300, 400]
        
        statusCodes.enumerated().forEach { index, code in
            expect(sut, completeWith: .failure(RemoteDogLoader.Error.invalidData), when: {
                client.complete(withStatusCode: code, at: index)
            })
        }
    }
    
    func test_load_deliversInvalidDataErrorOn200HTTPResponseWithInvalidJsonData() {
        let (sut, client) = makeSUT()
        
        expect(sut, completeWith: .failure(RemoteDogLoader.Error.invalidData), when: {
            let invalidJson = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJson)
        })
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJsonList() {
        let (sut, client) = makeSUT()
    
        expect(sut, completeWith: .success([]), when: {
            let emptyJson = Data("{ \"message\": [] }".utf8)
            client.complete(withStatusCode: 200, data: emptyJson)
        })
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithValidJsonList() {
        let (sut, client) = makeSUT()
        let item1 = makeItem(imageURL: URL(string: "http://test1-url.com")!)
        let item2 = makeItem(imageURL: URL(string: "http://test2-url.com")!)
        let jsonData = makeItemsJSON([item1,item2])

        expect(sut, completeWith: .success([item1, item2]), when: {
            client.complete(withStatusCode: 200, data: jsonData)
        })
    }

    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "http://a-url.com")!) -> (sut: RemoteDogLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteDogLoader(client: client, url: url)
        return (sut: sut, client: client)
    }
    
    private func makeItem(imageURL: URL) -> Dog {
        return Dog(imageURL: imageURL)
    }
    
    private func makeItemsJSON(_ items: [Dog]) -> Data {
        let json = ["message": items.map { $0.imageURL.absoluteString }]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func expect(_ sut: RemoteDogLoader, completeWith expectedResult: RemoteDogLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = XCTestExpectation(description: "Wait for completion")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedDogs), .success(expectedDogs)):
                XCTAssertEqual(receivedDogs, expectedDogs, file: file, line: line)
            case let (.failure(receivedError as RemoteDogLoader.Error), .failure(expectedError as RemoteDogLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                break
            default:
                XCTFail("expeced to get \(expectedResult) but got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var messages =  [(url: URL, completion: (HTTPClientResult?) -> Void)]()

        var requestedUrls: [URL] {
            return messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult?) -> Void) {
            self.messages.append((url: url, completion: completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            self.messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(
                url: self.requestedUrls[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil)!
            self.messages[index].completion(.success(data, response))
        }
    }
}
