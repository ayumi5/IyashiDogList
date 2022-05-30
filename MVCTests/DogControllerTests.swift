//
//  DogControllerTests.swift
//  MVCTests
//
//  Created by 宇高あゆみ on 2022/05/30.
//

import XCTest

final class DogViewController {
    let loader: DogControllerTests.LoaderSpy
    init(loader: DogControllerTests.LoaderSpy) {
        self.loader = loader
    }
}

final class DogControllerTests: XCTestCase {
    
    func test_init_doesNotLoadDog() {
        let loader = LoaderSpy()
       _ = DogViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    // MARK: - Helpers
    class LoaderSpy {
        private(set) var loadCallCount: Int = 0
    }
}




