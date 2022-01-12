//
//  DogLoaderTests.swift
//  IyashiDogListTests
//
//  Created by 宇高あゆみ on 2022/01/12.
//

import XCTest

/** TODO list
 - Load dogs from API
 - If successful
    - Displays dogs
 - If failure
    - Shows an error message
 
 */

class RemoteDogLoader {
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load(from url: URL) {
        client.get(from: url)
    }
}

class HTTPClient {
    func get(from url: URL) {
    }
    
}

class DogLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy()
        let _ = RemoteDogLoader(client: client)
        XCTAssertNil(client.requestedUrl)
    }
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "http://a-url.com")!
        let client = HTTPClientSpy()
        let sut = RemoteDogLoader(client: client)
        sut.load(from: url)
        XCTAssertNotNil(client.requestedUrl)
    }
}

private class HTTPClientSpy: HTTPClient {
    var requestedUrl: URL?
    
    override func get(from url: URL) {
        self.requestedUrl = url
    }
}
