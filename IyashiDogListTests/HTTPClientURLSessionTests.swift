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
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
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
        let error = NSError(domain: "test", code: 0)
        let receivedError = resultErrorFor(data: nil, response: nil, error: error) as NSError?
        XCTAssertEqual(receivedError?.domain, error.domain)
        XCTAssertEqual(receivedError?.code, error.code)
    }
    
    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        let anyData = Data("any data".utf8)
        let nonHTTPResponse = URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        let anyHttpResponse = HTTPURLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        let anyError = NSError(domain: "test", code: 0)
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPResponse, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: nil, error: anyError))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPResponse, error: anyError))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHttpResponse, error: anyError))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: nonHTTPResponse, error: anyError))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: anyHttpResponse, error: anyError))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: nonHTTPResponse, error: nil))
    }
    
    func test_getFromURL_succeedsWithEmptyDataOnURLHTTPResponseWithNilData() {
        let anyHttpResponse = HTTPURLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        let result = resultFor(data: nil, response: anyHttpResponse, error: nil)
        let emptyData = Data()
        switch result {
        case let .success(data, response):
            XCTAssertEqual(data, emptyData)
            XCTAssertEqual(response.url, anyHttpResponse.url)
            XCTAssertEqual(response.statusCode, anyHttpResponse.statusCode)
        default:
            XCTFail("expected a success but got a failure with error")
        }
    }
    
    // MARK: - Helpers
    private func makeSUT() -> HTTPClientURLSession {
        return HTTPClientURLSession()
    }

    private func anyURL() -> URL {
        return URL(string: "http://a-url.com")!
    }
    
    private func resultFor(data: Data?, response: URLResponse?, error: Error?) -> HTTPClientResult? {
        var result: HTTPClientResult?
        let sut = makeSUT()
        let url = anyURL()
        URLProtocolStub.stub(url: url, data: data, response: response, error: error)
        let exp = XCTestExpectation(description: "Wait for completion")
        sut.get(from: url) { receivedResult in
            result = receivedResult
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        return result
    }
    
    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?) -> Error? {
        let result = resultFor(data: data, response: response, error: error)
        switch result {
        case let .failure(error):
            return error
        default:
            XCTFail("Expected failure with error: \(String(describing: error)), instead got \(String(describing: result))")
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
