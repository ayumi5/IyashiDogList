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
        URLSession.shared.dataTask(with: url) {_, _, _ in
        
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
}

private class URLProtocolStub: URLProtocol {
    static var observer: ((URLRequest) -> Void)?
    
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
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {
        
    }
}
