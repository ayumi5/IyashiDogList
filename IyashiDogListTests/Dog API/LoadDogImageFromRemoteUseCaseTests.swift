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
    
    enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func loadImageData(from url: URL, completion: @escaping (HTTPClientResult?) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success(_, response):
                if response.statusCode != 200 {
                    completion(.failure(Error.invalidData))
                }
            case let .failure(error):
                completion(.failure(error))
            default:
                break
            }
        }
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
        
        sut.loadImageData(from: url) { _ in }
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadImageDataTwice_requestsDataFromURLTwice() {
        let (sut, client) = makeSUT()
        let url = URL(string: "https://a-url.com")!
        
        sut.loadImageData(from: url) { _ in }
        sut.loadImageData(from: url) { _ in }
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_loadImageData_deliversConnnectivityErrorOnClientError() {
        let (sut, client) = makeSUT()
        let connectivityError = RemoteDogImageDataLoader.Error.connectivity as NSError
        
        let exp = expectation(description: "wait for load completion")
        sut.loadImageData(from: URL(string: "https://a-url.com")!) { result in
            switch result {
            case let .failure(error as NSError):
                XCTAssertEqual(error, connectivityError)
            default:
                XCTFail("Expected failure with \(connectivityError)")
            }
            exp.fulfill()
        }
        
        client.completeDogImageLoading(with: connectivityError)
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadImageData_deliversInvalidDataErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let invalidDataError = RemoteDogImageDataLoader.Error.invalidData as NSError
        
        let exp = expectation(description: "wait for load completion")
        sut.loadImageData(from: URL(string: "https://a-url.com")!) { result in
            switch result {
            case let .failure(error as NSError):
                XCTAssertEqual(error, invalidDataError)
            default:
                XCTFail("Expected failure with \(invalidDataError)")
            }
            
            exp.fulfill()
        }
        
        client.completeDogImageLoading(with: Data(), withStatusCode: 300)
        
        wait(for: [exp], timeout: 1.0)
        
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: RemoteDogImageDataLoader, client: LoaderSpy) {
        let client = LoaderSpy()
        let sut = RemoteDogImageDataLoader(client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        
        return (sut, client)
    }
    
    private class LoaderSpy: HTTPClient {
        var requestedURLs = [URL]()
        private var completions = [(HTTPClientResult?) -> Void]()
        
        func get(from url: URL, completion: @escaping (HTTPClientResult?) -> Void) {
            requestedURLs.append(url)
            completions.append(completion)
        }
        
        func completeDogImageLoading(with error: Error, at index: Int = 0) {
            completions[index](.failure(error))
        }
        
        func completeDogImageLoading(with data: Data, withStatusCode code: Int, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
            completions[index](.success(data, response))
        }
    }
}
