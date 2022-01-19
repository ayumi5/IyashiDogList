//
//  HTTPClientURLSessionTests.swift
//  IyashiDogListTests
//
//  Created by 宇高あゆみ on 2022/01/17.
//

import XCTest
import IyashiDogList

class HTTPClientURLSessionTests: XCTestCase {
}

private class URLSessionStub: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool {
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
