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
    
}

class HTTPClient {
    var requestedUrl: URL?
}

class DogLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
       
        let client = HTTPClient()
        let _ = RemoteDogLoader()
        XCTAssertNil(client.requestedUrl)
    }
}
