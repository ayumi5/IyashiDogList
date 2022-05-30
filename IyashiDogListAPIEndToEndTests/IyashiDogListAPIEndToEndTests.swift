//
//  IyashiDogListAPIEndToEndTests.swift
//  IyashiDogListAPIEndToEndTests
//
//  Created by 宇高あゆみ on 2022/02/21.
//

import XCTest
import IyashiDogList
import IyashiDogFeature

class IyashiDogListAPIEndToEndTests: XCTestCase {
    
    func test_endToEndTestServerGETDogResult_matchesFixedData() {
        let sut = makeSUT()
        
        switch getDogResult(sut) {
        case let .success(dogs):
            XCTAssertEqual(dogs.count, 3, "Expected 3 dogs are on a list")
            XCTAssertEqual(dogs[0].imageURL.absoluteString, expectedImageURLStringList[0])
            XCTAssertEqual(dogs[1].imageURL.absoluteString, expectedImageURLStringList[1])
            XCTAssertEqual(dogs[2].imageURL.absoluteString, expectedImageURLStringList[2])
        case let .failure(error):
            XCTFail("Expected successful dog result. got \(error) instead")
        default:
            XCTFail("Expected successful dog result. got no result instead")
        }
    }
    
    // MARK: - Helpers
    
    private let expectedImageURLStringList = [
        "https://images.dog.ceo/breeds/buhund-norwegian/hakon1.jpg",
        "https://images.dog.ceo/breeds/buhund-norwegian/hakon2.jpg",
        "https://images.dog.ceo/breeds/buhund-norwegian/hakon3.jpg"
    ]
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> RemoteDogLoader {
        let client = HTTPClientURLSession()
        let url = URL(string: "https://dog.ceo/api/breed/buhund/norwegian/images")!
        let sut = RemoteDogLoader(client: client, url: url)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return sut
    }
    
    private func getDogResult(_ sut: RemoteDogLoader) -> DogLoader.Result? {
        var receivedResult: DogLoader.Result?
        
        let exp = expectation(description: "Wait for load completion")
        sut.load { result in
            receivedResult = result
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        return receivedResult
    }
}
