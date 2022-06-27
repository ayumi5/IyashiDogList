//
//  LoadDogFromRemoteUseCaseTests.swift
//  IyashiDogListTests
//
//  Created by 宇高あゆみ on 2022/01/12.
//

import XCTest
import IyashiDogList
import IyashiDogFeature

class LoadDogFromRemoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "http://test-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestDataFromURLTwice() {
        let url = URL(string: "http://test-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, completeWith: failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }
    
    func test_load_deliversInvalidDataErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let statusCodes = [199, 201, 300, 400]
        
        statusCodes.enumerated().forEach { index, code in
            expect(sut, completeWith: failure(.invalidData), when: {
                client.complete(withStatusCode: code, at: index)
            })
        }
    }
    
    func test_load_deliversInvalidDataErrorOn200HTTPResponseWithInvalidJsonData() {
        let (sut, client) = makeSUT()
        
        expect(sut, completeWith: failure(.invalidData), when: {
            let invalidJson = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJson)
        })
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJsonList() {
        let (sut, client) = makeSUT()
    
        expect(sut, completeWith: .success([]), when: {
            let emptyJson = makeItemsJSON([])
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
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteDogLoader? = RemoteDogLoader(client: client)
        var capturedResults = [RemoteDogLoader.Result]()
        
        sut?.load { result in
            capturedResults.append(result)
        }
        
        sut = nil
        let emptyJson = makeItemsJSON([])
        client.complete(withStatusCode: 200, data: emptyJson)

        XCTAssertTrue(capturedResults.isEmpty)
    }

    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "http://a-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteDogLoader,  client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteDogLoader(client: client, url: url)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut: sut, client: client)
    }
    
    private func makeItem(imageURL: URL) -> Dog {
        return Dog(imageURL: imageURL)
    }
    
    private func makeItemsJSON(_ items: [Dog]) -> Data {
        let json = ["message": items.map { $0.imageURL.absoluteString }]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func failure(_ error: RemoteDogLoader.Error) -> RemoteDogLoader.Result {
        return .failure(error)
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
}
