//
//  LoaderSpy.swift
//  MVCTests
//
//  Created by 宇高あゆみ on 2022/06/02.
//

import Foundation
import IyashiDogFeature

class LoaderSpy: DogLoader, DogImageDataLoader {
    
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
