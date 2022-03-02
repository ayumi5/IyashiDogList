//
//  LocalDogLoader.swift
//  IyashiDogList
//
//  Created by 宇高あゆみ on 2022/03/02.
//

import Foundation

public class LocalDogLoader {
    private let store: DogStore
    private let currentDate: () -> Date
    
    public typealias SaveResult = Error?
    
    public init(store: DogStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ dogs: [Dog], completion: @escaping (SaveResult) -> Void) {
        store.deleteCache { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                completion(error)
            } else {
                self.cache(dogs, with: completion)
            }
        }
    }
    
    private func cache(_ dogs: [Dog], with completion: @escaping (SaveResult) -> Void) {
        
        store.insert(dogs.toLocal(), timestamp: currentDate()) { [weak self] error in
            guard self != nil else { return }
            
            completion(error)
        }
    }
}

private extension Array where Element == Dog {
    func toLocal() -> [LocalDog] {
        self.map { LocalDog(imageURL: $0.imageURL) }
    }
}
