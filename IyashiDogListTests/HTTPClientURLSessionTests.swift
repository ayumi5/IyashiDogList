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
        URLSession.shared.dataTask(with: url) {_, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

class HTTPClientURLSessionTests: XCTestCase {
    func test_getFromURL_performsGetWithURL() {
        URLProtocolStub.startInterceptingRequests()
        let sut = HTTPClientURLSession()
        let url = URL(string: "http://a-url.com")!
        let exp = XCTestExpectation(description: "Wait for completion")
        
        URLProtocolStub.observeRequest { request in
            XCTAssertEqual(request.url, url)
            exp.fulfill()
        }
        sut.get(from: url) { _ in }
        wait(for: [exp], timeout: 1.0)
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_getFromURL_failsOnRequestError() {
        URLProtocolStub.startInterceptingRequests()
        let sut = HTTPClientURLSession()
        let url = URL(string: "http://a-url.com")!
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
        URLProtocolStub.stopInterceptingRequests()
    }
}

private class URLProtocolStub: URLProtocol {
    private static var stubs = [URL: Stub]()
    
    private struct Stub {
        let error: Error?
    }
    
    static var observer: ((URLRequest) -> Void)?
    
    static func stub(url: URL, error: Error? = nil) {
        stubs[url] = Stub(error: error)
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
        if let error = stub.error {
            client?.urlProtocol(self, didFailWithError: error)
        }
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {
        
    }
}
