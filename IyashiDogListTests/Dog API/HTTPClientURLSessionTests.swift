//
//  HTTPClientURLSessionTests.swift
//  IyashiDogListTests
//
//  Created by 宇高あゆみ on 2022/01/17.
//

import XCTest
import IyashiDogList

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
        _ = sut.get(from: url) { _ in }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let error = NSError(domain: "test", code: 0)
        let receivedError = resultErrorFor(data: nil, response: nil, error: error) as NSError?
        XCTAssertEqual(receivedError?.domain, error.domain)
        XCTAssertEqual(receivedError?.code, error.code)
    }
    
    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHttpResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHttpResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPResponse(), error: nil))
    }
    
    func test_getFromURL_succeedsWithEmptyDataOnURLHTTPResponseWithNilData() {
        let anyHttpResponse = anyHttpResponse()
        let value = resultValuesFor(data: nil, response: anyHttpResponse, error: nil)
        let emptyData = Data()
        XCTAssertEqual(value?.data, emptyData)
        XCTAssertEqual(value?.response.url, anyHttpResponse.url)
        XCTAssertEqual(value?.response.statusCode, anyHttpResponse.statusCode)
    }
    
    func test_getFromURL_succeedsOnURLHTTPResponseWithData() {
        let anyData = anyData()
        let anyHttpResponse = anyHttpResponse()
        let value = resultValuesFor(data: anyData, response: anyHttpResponse, error: nil)
        XCTAssertEqual(value?.data, anyData)
        XCTAssertEqual(value?.response.url, anyHttpResponse.url)
        XCTAssertEqual(value?.response.statusCode, anyHttpResponse.statusCode)
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClientURLSession {
        let sut = HTTPClientURLSession()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func anyURL() -> URL {
        return URL(string: "http://a-url.com")!
    }
    
    private func anyData() -> Data {
        return Data("any data".utf8)
    }
    
    private func nonHTTPResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyHttpResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "test", code: 0)
    }
    
    private func resultFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> HTTPClient.Result? {
        var result: HTTPClient.Result?
        let sut = makeSUT(file: file, line: line)
        let url = anyURL()
        URLProtocolStub.stub(url: url, data: data, response: response, error: error)
        let exp = XCTestExpectation(description: "Wait for completion")
        _ = sut.get(from: url) { receivedResult in
            result = receivedResult
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        return result
    }
    
    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        switch result {
        case let .failure(error):
            return error
        default:
            XCTFail("Expected failure with error: \(String(describing: error)), instead got \(String(describing: result))", file: file, line: line)
            return nil
        }
    }
    
    private func resultValuesFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        switch result {
        case let .success((data, response)):
            return (data, response)
        default:
            XCTFail("Expected failure with error: \(String(describing: error)), instead got \(String(describing: result))", file: file, line: line)
            return nil
        }
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

}
