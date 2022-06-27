//
//  LoadDogImageFromRemoteUseCaseTests.swift
//  IyashiDogListTests
//
//  Created by 宇高あゆみ on 2022/06/23.
//

import XCTest
import IyashiDogList

class LoadDogImageFromRemoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotPerformAnyURLRequest() {
        let (_, client) = makeSUT()

        XCTAssertEqual(client.requestedURLs, [])
    }
    
    func test_loadImageData_requestsDataFromURL() {
        let (sut, client) = makeSUT()
        let url = URL(string: "https://a-url.com")!
        
        _ = sut.loadImageData(from: url) { _ in }
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadImageDataTwice_requestsDataFromURLTwice() {
        let (sut, client) = makeSUT()
        let url = URL(string: "https://a-url.com")!
        
        _ = sut.loadImageData(from: url) { _ in }
        _ = sut.loadImageData(from: url) { _ in }
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_loadImageData_deliversConnnectivityErrorOnClientError() {
        let (sut, client) = makeSUT()
        let connectivityError = RemoteDogImageDataLoader.Error.connectivity
        
        expect(sut: sut, toCompleteWith: .failure(connectivityError), when: {
            client.complete(with: connectivityError)
        })
    }
    
    func test_loadImageData_deliversInvalidDataErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let invalidDataError = RemoteDogImageDataLoader.Error.invalidData
        
        let statusCodes = [199, 201, 300, 400]
        statusCodes.enumerated().forEach { index, code in
            expect(sut: sut, toCompleteWith: .failure(invalidDataError), when: {
                client.complete(withStatusCode: code, data: Data(), at: index)
            })
        }
    }
    
    func test_loadImageData_deliversInvalidDataErrorOn200HTTPResponseWithEmptyData() {
        let (sut, client) = makeSUT()
        
        expect(sut: sut, toCompleteWith: .failure(RemoteDogImageDataLoader.Error.invalidData), when: {
            let emptyData = Data()
            client.complete(withStatusCode: 200, data: emptyData)
        })
    }
    
    func test_loadImageData_deliversReceivedImageDataOn200HTTPResponseWithNonEmptyData() {
        let (sut, client) = makeSUT()
        let validData = Data("valid data".utf8)
        
        expect(sut: sut, toCompleteWith: .success(validData), when: {
            client.complete(withStatusCode: 200, data: validData)
        })
    }
    
    func test_cancelLoadImageDataURLTask_cancelsURLRequest() {
        let (sut, client) = makeSUT()
        let url = URL(string: "https://a-url.com")!
        let task = sut.loadImageData(from: url) { _ in }
        XCTAssertEqual(client.cancelledURLs, [])
        
        task.cancel()
        XCTAssertEqual(client.cancelledURLs, [url])
    }
    
    func test_cancelLoadImageDataURLTask_doesNotDeliverResult() {
        let (sut, client) = makeSUT()
        var receivedResults = [RemoteDogImageDataLoader.Result]()
        let emptyData = Data()
        let nonEmptyData = Data("non-empty data".utf8)
        
        let task = sut.loadImageData(from: URL(string: "https://a-url.com")!) {
            receivedResults.append($0)
        }
        task.cancel()
        
        client.complete(withStatusCode: 200, data: nonEmptyData)
        client.complete(withStatusCode: 200, data: emptyData)
        client.complete(with: anyNSError())
        
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: RemoteDogImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteDogImageDataLoader(client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        
        return (sut, client)
    }
    
    private func expect(sut: RemoteDogImageDataLoader, toCompleteWith expectedResult: RemoteDogImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for load completion")
        _ = sut.loadImageData(from: URL(string: "https://a-url.com")!) { receivedResult in
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
    
    func anyNSError() -> NSError {
        NSError.init(domain: "any error", code: 0)
    }
}
