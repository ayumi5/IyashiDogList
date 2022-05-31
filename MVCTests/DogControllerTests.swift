//
//  DogControllerTests.swift
//  MVCTests
//
//  Created by 宇高あゆみ on 2022/05/30.
//

import XCTest
import UIKit
import IyashiDogFeature
import MVC

final class DogControllerTests: XCTestCase {
    
    func test_loadDogActions_requestDogFromLoader() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading requests before view is loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1, "Expected a loading requests once view is loaded")
        
        sut.simulateUserInitiatedDogReload()
        XCTAssertEqual(loader.loadCallCount, 2, "Expected another loading requests once user initiates a reload")
        
        sut.simulateUserInitiatedDogReload()
        XCTAssertEqual(loader.loadCallCount, 3, "Expected another loading requests once user initiates another reload")
    }
    
    func test_loadingIndicator_isVisibleWhileLoadingDog() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected loading indicator once view is loaded")
        
        loader.completeDogLoading(at: 0)
        XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expected loading indicator once loading is completed")
        
        sut.simulateUserInitiatedDogReload()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected loading indicator once user initiated a reload")
        
        loader.completeDogLoading(at: 1)
        XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expected loading indicator once loading is completed")
    }
    
    func test_viewDidLoad_rendersDogItemOnSuccessfulLoadCompletion() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeDogLoading(with: [Dog(imageURL: anyURL())], at: 0)

        XCTAssertEqual(sut.numberOfRenderedDogImageViews(), 1)
        
        sut.simulateUserInitiatedDogReload()
        loader.completeDogLoading(with: [Dog(imageURL: anyURL()), Dog(imageURL: anyURL())], at: 1)
        
        XCTAssertEqual(sut.numberOfRenderedDogImageViews(), 2)
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
        
        func completeDogLoading(with dogs: [Dog], at index: Int = 0) {
            completions[index](.success(dogs))
        }
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://a-url.com")!
    }
}

private extension DogViewController {
    func simulateUserInitiatedDogReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool? {
        refreshControl?.isRefreshing
    }
    
    func numberOfRenderedDogImageViews() -> Int {
        tableView.numberOfRows(inSection: dogImageSection)
    }
    
    private var dogImageSection: Int {
        return 0
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
