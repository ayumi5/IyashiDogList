//
//  DogControllerTests.swift
//  MVCTests
//
//  Created by 宇高あゆみ on 2022/05/30.
//

import XCTest
import UIKit

final class DogViewController: UIViewController {
    private var loader: DogControllerTests.LoaderSpy?
    
    convenience init(loader: DogControllerTests.LoaderSpy) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loader?.load()
    }
}

final class DogControllerTests: XCTestCase {
    
    func test_init_doesNotLoadDog() {
        let loader = LoaderSpy()
       _ = DogViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_loadsDog() {
        let loader = LoaderSpy()
        let sut = DogViewController(loader: loader)
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    
    
    // MARK: - Helpers
    class LoaderSpy {
        private(set) var loadCallCount: Int = 0
        
        func load() {
            loadCallCount += 1
        }
    }
}




