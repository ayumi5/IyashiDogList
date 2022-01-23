//
//  HTTPClientURLSessionTests.swift
//  IyashiDogListTests
//
//  Created by 宇高あゆみ on 2022/01/17.
//

import XCTest
import IyashiDogList


class HTTPClientURLSession {
    func get(from url: URL, completion: @escaping (HTTPClientResult?) -> Void) {
        URLSession.shared.dataTask(with: url) {data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let _ = data, let _ = response {
                
            } else {
                completion(.failure(InvalidResponseError()))
            }
        }.resume()
    }
}

public struct InvalidResponseError: Error {}

class HTTPClientURLSessionTests: XCTestCase {
    override func setUp() {
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_getFromURL_performsGetWithURL() {
        let sut = makeSUT()
        let url = anyURL()
        let exp = XCTestExpectation(description: "Wait for completion")
        
        URLProtocolStub.observeRequest { request in
            XCTAssertEqual(request.url, url)
            exp.fulfill()
        }
        sut.get(from: url) { _ in }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let sut = makeSUT()
        let url = anyURL()
        let error = NSError(domain: "test", code: 0)
        URLProtocolStub.stub(url: url, error: error)
        let exp = XCTestExpectation(description: "Wait for completion")
        
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(error.domain, receivedError.domain)
                XCTAssertEqual(error.code, receivedError.code)
            default:
                XCTFail("Expected failure with error: \(error), instead got \(String(describing: result))")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_failsOnInvalidRepresentationCase() {
        let sut = makeSUT()
        let url = anyURL()
        URLProtocolStub.stub(url: url, data: nil, response: nil, error: nil)
        let exp = XCTestExpectation(description: "Wait for completion")
        
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError):
                XCTAssertNotNil(receivedError)
            default:
                XCTFail("Expected failure, instead got \(String(describing: result))")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}

// MARK: - Helpers
private func makeSUT() -> HTTPClientURLSession {
    return HTTPClientURLSession()
}

private func anyURL() -> URL {
    return URL(string: "http://a-url.com")!
}

private class URLProtocolStub: URLProtocol {
    private static var stubs = [URL: Stub]()
    
    private struct Stub {
        let data: Data?
        let response: URLResponse?
        let error: Error?
    }
    
    static var observer: ((URLRequest) -> Void)?
    
    static func stub(url: URL, data: Data? = nil, response: URLResponse? = nil, error: Error? = nil) {
        stubs[url] = Stub(data: data, response: response, error: error)
    }
    
    static func startInterceptingRequests() {
        URLProtocol.registerClass(self)
    }
    
    static func stopInterceptingRequests() {
        URLProtocol.unregisterClass(self)
    }
    
    static func observeRequest(completion: @escaping (URLRequest) -> Void) {
        observer = completion
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        if let observer = observer {
            observer(request)
        }
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let url = request.url, let stub = URLProtocolStub.stubs[url] else { return }
        if let data = stub.data {
            client?.urlProtocol(self, didLoad: data)
        }
        
        if let response = stub.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        if let error = stub.error {
            client?.urlProtocol(self, didFailWithError: error)
        }
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {
        
    }
}
