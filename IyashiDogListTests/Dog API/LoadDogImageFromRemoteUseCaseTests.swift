//
//  LoadDogImageFromRemoteUseCaseTests.swift
//  IyashiDogListTests
//
//  Created by 宇高あゆみ on 2022/06/23.
//

import XCTest
import IyashiDogList

final class RemoteDogImageDataLoader {
    typealias Result = Swift.Result<Data, Swift.Error>
    private let client: HTTPClient
    private var task: HTTPClientTask?
    
    enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    struct HTTPClientTaskWrapper {
        var wrapped: HTTPClientTask
        
        func cancel() {
            wrapped.cancel()
        }
    }
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> HTTPClientTaskWrapper {
        let task = HTTPClientTaskWrapper(wrapped: client.get(from: url) { result in
            do {
                let (data, response) = try result.get()
                
                guard data.isEmpty == false, response.statusCode == 200 else {
                    completion(.failure(Error.invalidData))
                    return
                }
                
                completion(.success(data))
                
            } catch {
                completion(.failure(error))
            }
        })
                                                   
        return task
    }
    
    func cancelLoad() {
        task?.cancel()
        task = nil
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
            client.completeDogImageLoading(with: connectivityError)
        })
    }
    
    func test_loadImageData_deliversInvalidDataErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let invalidDataError = RemoteDogImageDataLoader.Error.invalidData
        
        let statusCodes = [199, 201, 300, 400]
        statusCodes.enumerated().forEach { index, code in
            expect(sut: sut, toCompleteWith: .failure(invalidDataError), when: {
                client.completeDogImageLoading(with: Data(), withStatusCode: code, at: index)
            })
        }
    }
    
    func test_loadImageData_deliversInvalidDataErrorOn200HTTPResponseWithEmptyData() {
        let (sut, client) = makeSUT()
        
        expect(sut: sut, toCompleteWith: .failure(RemoteDogImageDataLoader.Error.invalidData), when: {
            let emptyData = Data()
            client.completeDogImageLoading(with: emptyData, withStatusCode: 200)
        })
    }
    
    func test_loadImageData_deliversReceivedImageDataOn200HTTPResponseWithNonEmptyData() {
        let (sut, client) = makeSUT()
        let validData = Data("valid data".utf8)
        
        expect(sut: sut, toCompleteWith: .success(validData), when: {
            client.completeDogImageLoading(with: validData, withStatusCode: 200)
        })
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: RemoteDogImageDataLoader, client: LoaderSpy) {
        let client = LoaderSpy()
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
    
    private class LoaderSpy: HTTPClient {
        var requestedURLs = [URL]()
        var cancelledURLs = [URL]()
        private var completions = [(HTTPClient.Result) -> Void]()
        
        struct TaskSpy: HTTPClientTask {
            var action: () -> Void
            func cancel() {
                action()
            }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            requestedURLs.append(url)
            completions.append(completion)
            
            return TaskSpy(action: { [weak self] in
                self?.cancelledURLs.append(url)
            })
        }
        
        func completeDogImageLoading(with error: Error, at index: Int = 0) {
            completions[index](.failure(error))
        }
        
        func completeDogImageLoading(with data: Data, withStatusCode code: Int, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
            completions[index](.success((data, response)))
        }
    }
}
