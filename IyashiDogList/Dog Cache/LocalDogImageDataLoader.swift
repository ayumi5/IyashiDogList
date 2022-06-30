//
//  LocalDogImageDataLoader.swift
//  IyashiDogList
//
//  Created by 宇高あゆみ on 2022/06/30.
//

import Foundation
import IyashiDogFeature

public final class LocalDogImageDataLoader: DogImageDataLoader {
    private let store: DogImageStore
    
    public enum LoadError: Swift.Error {
        case failed
        case notFound
    }
    
    public init(store: DogImageStore) {
        self.store = store
    }
    
    private final class LocalDogImageDataLoaderTask: DogImageDataLoaderTask {
        private var completion: ((DogImageDataLoader.Result) -> Void)?
        
        init(completion: @escaping (DogImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func cancel() {
            preventFurtherCompletion()
        }
        
        func complete(with result: DogImageDataLoader.Result) {
            completion?(result)
        }
        
        private func preventFurtherCompletion() {
            completion = nil
        }
    }
    
    public func loadImageData(from url: URL, completion: @escaping (DogImageDataLoader.Result) -> Void) -> DogImageDataLoaderTask {
        let task = LocalDogImageDataLoaderTask(completion: completion)
        store.retrieve(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success(data):
                if data.isEmpty {
                    task.complete(with: .failure(LoadError.notFound))
                } else {
                    task.complete(with: .success(data))
                }
            case .failure:
                task.complete(with: .failure(LoadError.failed))
            }
        }
        return task
    }
    
    public func saveImageData(to url: URL) {
        store.insert(to: url)
    }
}
