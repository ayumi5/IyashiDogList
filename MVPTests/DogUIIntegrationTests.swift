//
//  DogUIIntegrationTests.swift
//  Tests
//
//  Created by 宇高あゆみ on 2022/05/30.
//

import XCTest
import UIKit
import IyashiDogFeature
import MVP

final class DogUIIntegrationTests: XCTestCase {
    
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

        XCTAssertEqual(cell01?.renderedImage, .none, "Expected no rendered image before first image loading completes")
        XCTAssertEqual(cell02?.renderedImage, .none, "Expected no rendered image before second image loading completes")

        let imageData01 = UIImage.make(withColor: .red).pngData()!
        loader.completeDogImageLoading(with: imageData01, at: 0)
        XCTAssertEqual(cell01?.renderedImage, imageData01, "Expected rendered image once first image loading completes successfully")
        XCTAssertEqual(cell02?.renderedImage, .none, "Expected no image state change for second image once first image loading completes successfully")
        
        let imageData02 = UIImage.make(withColor: .blue).pngData()!
        loader.completeDogImageLoading(with: imageData02, at: 1)
        XCTAssertEqual(cell01?.renderedImage, imageData01,"Expected no image state change for first image once second image loading completes successfully")
        XCTAssertEqual(cell02?.renderedImage, imageData02, "Expected rendered image once second image loading completes successfully")
        
    }
    
    func test_retryButton_isVisibleOnImageLoadError() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeDogLoading(with: [makeDog(), makeDog()])

        let cell01 = sut.simulateDogImageViewVisible(at: 0)
        let cell02 = sut.simulateDogImageViewVisible(at: 1)

        XCTAssertEqual(cell01?.isShowingRetryAction, false, "Expected no retry action before first image loading completes")
        XCTAssertEqual(cell02?.isShowingRetryAction, false, "Expected no retry action before second image loading completes")

        let imageData01 = UIImage.make(withColor: .red).pngData()!
        loader.completeDogImageLoading(with: imageData01, at: 0)
        XCTAssertEqual(cell01?.isShowingRetryAction, false, "Expected no retry action once first image loading completes successfully")
        XCTAssertEqual(cell02?.isShowingRetryAction, false, "Expected no retry action change once first image loading completes successfully")
        
        loader.completeDogImageLoading(with: anyNSError(), at: 1)
        XCTAssertEqual(cell01?.isShowingRetryAction, false, "Expected no retry action change once second image loading completes with error")
        XCTAssertEqual(cell02?.isShowingRetryAction, true, "Expected retry action once second image loading completes with error")
    }
    
    func test_retryButton_isVisibleOnInvalidLoadedImage() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeDogLoading(with: [makeDog()])

        let cell = sut.simulateDogImageViewVisible()
        XCTAssertEqual(cell?.isShowingRetryAction, false, "Expected no retry action before image loading completes")
        
        let invalidData = anyData()
        loader.completeDogImageLoading(with: invalidData)
        XCTAssertEqual(cell?.isShowingRetryAction, true, "Expected retry action once image loading completes with invalid image")
    }
    
    func test_retryAction_loadDogImageData() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeDogLoading(with: [makeDog()])
        
        let cell = sut.simulateDogImageViewVisible()
        loader.completeDogImageLoading(with: anyNSError(), at: 0)
        XCTAssertEqual(cell?.renderedImage, .none, "Expected no rendered image when image loading completes with error")
        
        
        cell?.simulateRetryAction()
        let imageData = UIImage.make(withColor: .red).pngData()!
        loader.completeDogImageLoading(with: imageData, at: 1)
        
        XCTAssertEqual(cell?.renderedImage, imageData, "Expected rendered image once loading completes successfully by retry action")
    }
    
    func test_dogImageView_preloadsImageURLWhenNearVisible() {
        let (sut, loader) = makeSUT()
        let dog01 = makeDog()
        let dog02 = makeDog()
        
        sut.loadViewIfNeeded()
        loader.completeDogLoading(with: [dog01, dog02])
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until image is near visible")
        
        sut.simulateDogImageViewNearVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [dog01.imageURL], "Expected first image URL requests once first image is near visible")
        
        sut.simulateDogImageViewNearVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [dog01.imageURL, dog02.imageURL], "Expected second image URL requests once second image is near visible")

    }
    
    func test_dogImageView_cancelsPreloadImageURLWhenNotNearVisible() {
        let (sut, loader) = makeSUT()
        let dog01 = makeDog()
        let dog02 = makeDog()
        
        sut.loadViewIfNeeded()
        loader.completeDogLoading(with: [dog01, dog02])
        XCTAssertEqual(loader.canceledImageURLs, [], "Expected no cancelled image URL requests until image is not near visible")
        
        sut.simulateDogImageViewNotNearVisible(at: 0)
        XCTAssertEqual(loader.canceledImageURLs, [dog01.imageURL], "Expected first cancelled image URL requests once first image is not near visible")
        
        sut.simulateDogImageViewNotNearVisible(at: 1)
        XCTAssertEqual(loader.canceledImageURLs, [dog01.imageURL, dog02.imageURL], "Expected second cancelled image URL requests once second image is not near visible")
        
    }
    
    func test_loadDogCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeDogLoading(at: 0)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadDogImageCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        loader.completeDogLoading(with: [makeDog()])
        sut.simulateDogImageViewVisible(at: 0)
        
        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            let imageData01 = UIImage.make(withColor: .red).pngData()!
            loader.completeDogImageLoading(with: imageData01, at: 0)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: DogViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = DogUIComposer.dogComposed(with: loader, imageLoader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, loader)
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
