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
        
        XCTAssertEqual(loader.dogLoadCallCount, 0, "Expected no loading requests before view is loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.dogLoadCallCount, 1, "Expected a loading requests once view is loaded")
        
        sut.simulateUserInitiatedDogReload()
        XCTAssertEqual(loader.dogLoadCallCount, 2, "Expected another loading requests once user initiates a reload")
        
        sut.simulateUserInitiatedDogReload()
        XCTAssertEqual(loader.dogLoadCallCount, 3, "Expected another loading requests once user initiates another reload")
    }
    
    func test_loadingIndicator_isVisibleWhileLoadingDog() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected loading indicator once view is loaded")
        
        loader.completeDogLoading(at: 0)
        XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expected loading indicator once loading is completed successfully")
        
        sut.simulateUserInitiatedDogReload()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true, "Expected loading indicator once user initiated a reload")
        
        loader.completeDogLoading(with: anyNSError(), at: 1)
        XCTAssertEqual(sut.isShowingLoadingIndicator, false, "Expected loading indicator once loading is completed with error")
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
    
    func test_loadCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeDogLoading(with: [Dog(imageURL: anyURL())], at: 0)

        XCTAssertEqual(sut.numberOfRenderedDogImageViews(), 1)
        
        sut.simulateUserInitiatedDogReload()
        loader.completeDogLoading(with: anyNSError())
        
        XCTAssertEqual(sut.numberOfRenderedDogImageViews(), 1)
    }
    
    func test_dogImageView_loadsDogImageURLWhenViewisVisible() {
        let (sut, loader) = makeSUT()
        let dog01 = Dog(imageURL: URL(string: "https://dog1.com")!)
        let dog02 = Dog(imageURL: URL(string: "https://dog2.com")!)
        
        sut.loadViewIfNeeded()
        loader.completeDogLoading(with: [dog01, dog02])
        XCTAssertEqual(loader.loadedImageURLs, [])

        sut.simulateDogImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [dog01.imageURL])
        
        sut.simulateDogImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [dog01.imageURL, dog02.imageURL])
        
    }
    
    func test_dogImageView_cancelDogImageURLWhenViewisNotVisibleAnymore() {
        let (sut, loader) = makeSUT()
        let dog01 = Dog(imageURL: URL(string: "https://dog1.com")!)
        let dog02 = Dog(imageURL: URL(string: "https://dog2.com")!)
        
        sut.loadViewIfNeeded()
        loader.completeDogLoading(with: [dog01, dog02])
        XCTAssertEqual(loader.canceledImageURLs, [])

        sut.simulateDogImageViewNotVisible(at: 0)
        XCTAssertEqual(loader.canceledImageURLs, [dog01.imageURL])
        
        sut.simulateDogImageViewNotVisible(at: 1)
        XCTAssertEqual(loader.canceledImageURLs, [dog01.imageURL, dog02.imageURL])
        
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: DogViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = DogViewController(dogLoader: loader, dogImageDataLoader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, loader)
    }
    
    private class LoaderSpy: DogLoader, DogImageDataLoader {
        
        // MARK: - DogLoader
        
        private(set) var dogLoadCallCount: Int = 0
        private(set) var dogLoadcompletions = [(DogLoader.Result) -> Void]()
        
        func load(completion: @escaping (DogLoader.Result) -> Void) {
            dogLoadCallCount += 1
            dogLoadcompletions.append(completion)
        }
        
        func completeDogLoading(at index: Int = 0) {
            dogLoadcompletions[index](.success([]))
        }
        
        func completeDogLoading(with dogs: [Dog], at index: Int = 0) {
            dogLoadcompletions[index](.success(dogs))
        }
        
        func completeDogLoading(with error: Error, at index: Int = 0) {
            dogLoadcompletions[index](.failure(error))
        }

        // MARK: - DogImageDataLoader
        
        private(set) var loadedImageURLs = [URL]()
        private(set) var canceledImageURLs = [URL]()
        
        private struct TaskSpy: DogImageDataLoaderTask {
            let cancelCallback: () -> Void
            
            func cancel() {
                cancelCallback()
            }
        }
        
        func loadImageData(from url: URL) -> DogImageDataLoaderTask {
            loadedImageURLs.append(url)
            return TaskSpy { [weak self] in
                self?.canceledImageURLs.append(url)
            }
        }
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://a-url.com")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "test", code: 0)
    }
}

private extension DogViewController {
    @discardableResult
    func simulateDogImageViewVisible(at row: Int = 0) -> UITableViewCell? {
        return dogImageView(at: row)
    }
    
    func simulateDogImageViewNotVisible(at row: Int = 0) {
        let view = simulateDogImageViewVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: dogImageSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
    }
    
    func simulateUserInitiatedDogReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool? {
        refreshControl?.isRefreshing
    }
    
    func dogImageView(at row: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let indexPath = IndexPath(row: row, section: dogImageSection)
        return ds?.tableView(tableView, cellForRowAt: indexPath)
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
