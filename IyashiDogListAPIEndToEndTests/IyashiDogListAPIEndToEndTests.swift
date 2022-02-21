//
//  IyashiDogListAPIEndToEndTests.swift
//  IyashiDogListAPIEndToEndTests
//
//  Created by 宇高あゆみ on 2022/02/21.
//

import XCTest
import IyashiDogList

class IyashiDogListAPIEndToEndTests: XCTestCase {
    
    func test_endToEndTestServerGETDogResult_matchesFixedData() {
        let sut = makeSUT()
        var receivedResult: DogLoader.Result?
        
        let exp = expectation(description: "Wait for load completion")
        sut.load { result in
            receivedResult = result
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        switch receivedResult {
        case let .success(dogs):
            XCTAssertEqual(dogs.count, 3, "Expected 3 dogs are on a list")
            XCTAssertEqual(dogs[0].imageURL.absoluteString, "https://images.dog.ceo/breeds/buhund-norwegian/hakon1.jpg")
            XCTAssertEqual(dogs[1].imageURL.absoluteString, "https://images.dog.ceo/breeds/buhund-norwegian/hakon2.jpg")
            XCTAssertEqual(dogs[2].imageURL.absoluteString, "https://images.dog.ceo/breeds/buhund-norwegian/hakon3.jpg")
        case let .failure(error):
            XCTFail("Expected successful dog result. got \(error) instead")
        default:
            XCTFail("Expected successful dog result. got no result instead")
        }
    }
    
    private func makeSUT() -> RemoteDogLoader {
        let client = HTTPClientURLSession()
        let url = URL(string: "https://dog.ceo/api/breed/buhund/norwegian/images")!
        return RemoteDogLoader(client: client, url: url)
    }
}
