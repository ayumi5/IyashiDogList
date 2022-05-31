//
//  DogControllerTests.swift
//  MVCTests
//
//  Created by 宇高あゆみ on 2022/05/30.
//

import XCTest
import UIKit
import IyashiDogFeature

final class DogViewController: UITableViewController {
    private var loader: DogLoader?
    
    convenience init(loader: DogLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)

        load()
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        loader?.load { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
}

final class DogControllerTests: XCTestCase {
    
    func test_loadDogActions_requestDogFromLoader() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0)
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1)
        
        sut.simulateUserInitiatedDogReload()
        XCTAssertEqual(loader.loadCallCount, 2)
        
        sut.simulateUserInitiatedDogReload()
        XCTAssertEqual(loader.loadCallCount, 3)
    }
    
    func test_loadingIndicator_isVisibleWhileLoadingDog() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true)
        
        loader.completeDogLoading(at: 0)
        XCTAssertEqual(sut.isShowingLoadingIndicator, false)
        
        sut.simulateUserInitiatedDogReload()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true)
        
        loader.completeDogLoading(at: 1)
        XCTAssertEqual(sut.isShowingLoadingIndicator, false)
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: DogViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = DogViewController(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, loader)
    }
    
    private class LoaderSpy: DogLoader {
        private(set) var loadCallCount: Int = 0
        private(set) var completions = [(DogLoader.Result) -> Void]()
        
        func load(completion: @escaping (DogLoader.Result) -> Void) {
            loadCallCount += 1
            completions.append(completion)
        }
        
        func completeDogLoading(at index: Int = 0) {
            completions[index](.success([]))
        }
    }
}

private extension DogViewController {
    func simulateUserInitiatedDogReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool? {
        refreshControl?.isRefreshing
    }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
