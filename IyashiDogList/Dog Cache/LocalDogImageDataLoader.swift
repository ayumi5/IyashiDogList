//
//  LocalDogImageDataLoader.swift
//  IyashiDogList
//
//  Created by 宇高あゆみ on 2022/06/30.
//

import Foundation
import IyashiDogFeature

public final class LocalDogImageDataLoader: DogImageDataLoader {
    public typealias LoadResult = DogImageDataLoader.Result
    public typealias SaveResult = Swift.Result<Void, Error>

    private let store: DogImageStore
    
    public enum LoadError: Swift.Error {
        case failed
        case notFound
    }
    
    public enum SaveError: Swift.Error {
        case failed
    }
    
    public init(store: DogImageStore) {
        self.store = store
    }
    
    private final class LocalDogImageDataLoaderTask: DogImageDataLoaderTask {
        private var completion: ((LoadResult) -> Void)?
        
        init(completion: @escaping (LoadResult) -> Void) {
            self.completion = completion
        }
        
        func cancel() {
            preventFurtherCompletion()
        }
        
        func complete(with result: LoadResult) {
            completion?(result)
        }
        
        private func preventFurtherCompletion() {
            completion = nil
        }
    }
    
    public func loadImageData(from url: URL, completion: @escaping (LoadResult) -> Void) -> DogImageDataLoaderTask {
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
    
    public func saveImageData(_ data: Data, to url: URL, completion: @escaping (SaveResult) -> Void) {
        store.insert(data, to: url) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure:
                completion(.failure(SaveError.failed))
            }
        }
    }
}
