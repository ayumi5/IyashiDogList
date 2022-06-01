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
    
    func test_feedViewloadingIndicator_isVisibleWhileLoadingDog() {
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
        loader.completeDogLoading(with: [makeDog()], at: 0)

        XCTAssertEqual(sut.numberOfRenderedDogImageViews(), 1)
        
        sut.simulateUserInitiatedDogReload()
        loader.completeDogLoading(with: [makeDog(), makeDog()], at: 1)
        
        XCTAssertEqual(sut.numberOfRenderedDogImageViews(), 2)
    }
    
    func test_loadCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeDogLoading(with: [makeDog()], at: 0)

        XCTAssertEqual(sut.numberOfRenderedDogImageViews(), 1)
        
        sut.simulateUserInitiatedDogReload()
        loader.completeDogLoading(with: anyNSError())
        
        XCTAssertEqual(sut.numberOfRenderedDogImageViews(), 1)
    }
    
    func test_dogImageView_loadsDogImageURLWhenViewisVisible() {
        let (sut, loader) = makeSUT()
        let dog01 = makeDog()
        let dog02 = makeDog()
        
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
        let dog01 = makeDog()
        let dog02 = makeDog()
        
        sut.loadViewIfNeeded()
        loader.completeDogLoading(with: [dog01, dog02])
        XCTAssertEqual(loader.canceledImageURLs, [])

        sut.simulateDogImageViewNotVisible(at: 0)
        XCTAssertEqual(loader.canceledImageURLs, [dog01.imageURL])
        
        sut.simulateDogImageViewNotVisible(at: 1)
        XCTAssertEqual(loader.canceledImageURLs, [dog01.imageURL, dog02.imageURL])
        
    }
    
    func test_feedImageViewLoadingIndicator_isVisibleWhileLoadingDog() {
        let (sut, loader) = makeSUT()
       
        sut.loadViewIfNeeded()
        loader.completeDogLoading(with: [makeDog(), makeDog()])
        
        let cell01 = sut.simulateDogImageViewVisible(at: 0)
        let cell02 = sut.simulateDogImageViewVisible(at: 1)
        XCTAssertEqual(cell01?.isShowingImageViewLoadingIndicator, true, "Expected loading indicator once first image is loaded")
        XCTAssertEqual(cell02?.isShowingImageViewLoadingIndicator, true, "Expected loading indicator once second image is loaded")

        loader.completeDogImageLoading(with: anyData(), at: 0)
        XCTAssertEqual(cell01?.isShowingImageViewLoadingIndicator, false, "Expected no loading indicator once first image loading completes successfully")
        XCTAssertEqual(cell02?.isShowingImageViewLoadingIndicator, true, "Expected loading indicator while second image is loading")
        
        loader.completeDogImageLoading(with: anyNSError(), at: 1)
        XCTAssertEqual(cell01?.isShowingImageViewLoadingIndicator, false, "Expected no loading indicator state change for first image once second image loading completes with error")
        XCTAssertEqual(cell02?.isShowingImageViewLoadingIndicator, false, "Expected no loading indicator once second image loading completes with error")
    }
    
    func test_dogImageView_rendersImageLoadedFromURL() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeDogLoading(with: [makeDog(), makeDog()])

        let cell01 = sut.simulateDogImageViewVisible(at: 0)
        let cell02 = sut.simulateDogImageViewVisible(at: 1)

        XCTAssertEqual(cell01?.renderedImage, .none)
        XCTAssertEqual(cell02?.renderedImage, .none)

        let imageData01 = UIImage.make(withColor: .red).pngData()!
        loader.completeDogImageLoading(with: imageData01, at: 0)
        XCTAssertEqual(cell01?.renderedImage, imageData01)
        XCTAssertEqual(cell02?.renderedImage, .none)
        
        let imageData02 = UIImage.make(withColor: .blue).pngData()!
        loader.completeDogImageLoading(with: imageData02, at: 1)
        XCTAssertEqual(cell01?.renderedImage, imageData01)
        XCTAssertEqual(cell02?.renderedImage, imageData02)
        
    }
    
    func test_retryButton_isVisibleOnImageLoadError() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeDogLoading(with: [makeDog(), makeDog()])

        let cell01 = sut.simulateDogImageViewVisible(at: 0)
        let cell02 = sut.simulateDogImageViewVisible(at: 1)

        XCTAssertEqual(cell01?.isShowingRetryAction, false)
        XCTAssertEqual(cell02?.isShowingRetryAction, false)

        let imageData01 = UIImage.make(withColor: .red).pngData()!
        loader.completeDogImageLoading(with: imageData01, at: 0)
        XCTAssertEqual(cell01?.isShowingRetryAction, false)
        XCTAssertEqual(cell02?.isShowingRetryAction, false)
        
        loader.completeDogImageLoading(with: anyNSError(), at: 1)
        XCTAssertEqual(cell01?.isShowingRetryAction, false)
        XCTAssertEqual(cell02?.isShowingRetryAction, true)
    }
    
    func test_retryButton_isVisibleOnInvalidLoadedImage() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeDogLoading(with: [makeDog()])

        let cell = sut.simulateDogImageViewVisible()
        XCTAssertEqual(cell?.isShowingRetryAction, false)
        
        let invalidData = anyData()
        loader.completeDogImageLoading(with: invalidData)
        XCTAssertEqual(cell?.isShowingRetryAction, true)
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
        private(set) var dogImageLoadcompletions = [(DogImageDataLoader.Result) -> Void]()
        
        private struct TaskSpy: DogImageDataLoaderTask {
            let cancelCallback: () -> Void
            
            func cancel() {
                cancelCallback()
            }
        }
        
        func loadImageData(from url: URL, completion: @escaping (DogImageDataLoader.Result) -> Void) -> DogImageDataLoaderTask {
            loadedImageURLs.append(url)
            dogImageLoadcompletions.append(completion)
            return TaskSpy { [weak self] in
                self?.canceledImageURLs.append(url)
            }
        }
        
        func completeDogImageLoading(with data: Data, at index: Int = 0) {
            dogImageLoadcompletions[index](.success(data))
        }
        
        func completeDogImageLoading(with error: Error, at index: Int = 0) {
            dogImageLoadcompletions[index](.failure(error))
        }
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://a-url.com")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "test", code: 0)
    }
    
    private func anyData() -> Data {
        return Data("any data".utf8)
    }
    
    private func makeDog() -> Dog {
        return Dog(imageURL: URL(string: "http://any-url-\(UUID()).com")!)
    }
}

private extension DogViewController {
    @discardableResult
    func simulateDogImageViewVisible(at row: Int = 0) -> DogImageCell? {
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
    
    func dogImageView(at row: Int) -> DogImageCell? {
        let ds = tableView.dataSource
        let indexPath = IndexPath(row: row, section: dogImageSection)
        return ds?.tableView(tableView, cellForRowAt: indexPath) as? DogImageCell
    }
    
    func numberOfRenderedDogImageViews() -> Int {
        tableView.numberOfRows(inSection: dogImageSection)
    }
    
    private var dogImageSection: Int {
        return 0
    }
    
}

private extension DogImageCell {
    var isShowingImageViewLoadingIndicator: Bool {
        dogImageContainer.isShimmering
    }
    
    var renderedImage: Data? {
        return dogImageView.image?.pngData()
    }
    
    var isShowingRetryAction: Bool {
        return !retryButton.isHidden
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

private extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
