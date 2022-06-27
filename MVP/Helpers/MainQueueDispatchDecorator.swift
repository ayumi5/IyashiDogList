//
//  MainQueueDispatchDecorator.swift
//  MVP
//
//  Created by 宇高あゆみ on 2022/06/27.
//

import Foundation
import IyashiDogFeature

final class MainQueueDispatchDecorator<T> {
    private let decoratee: T
    
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async(execute: completion)
        }
        
        completion()
    }
}

extension MainQueueDispatchDecorator: DogLoader where T == DogLoader {
    func load(completion: @escaping (DogLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch {
                completion(result)
            }
        }
    }
}

extension MainQueueDispatchDecorator: DogImageDataLoader where T == DogImageDataLoader {
    func loadImageData(from url: URL, completion: @escaping (DogImageDataLoader.Result) -> Void) -> DogImageDataLoaderTask {
        decoratee.loadImageData(from: url) { [weak self] result in
            self?.dispatch {
                completion(result)
            }
        }
    }
}
