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
    public typealias LoadResult = DogLoader.Result
    
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
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .found(dogs, timestamp) where self.validate(timestamp):
                completion(.success(dogs.toModels()))
            case .found, .empty:
                completion(.success([]))
            }
        }
    }
    
    private var maxCacheAgeInDays: Int {
        return 7
    }
    
    private func validate(_ timestamp: Date) -> Bool {
        guard let maxCacheAge = Calendar(identifier: .gregorian).date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
            return false
        }
        return currentDate() < maxCacheAge
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

private extension Array where Element == LocalDog {
    func toModels() -> [Dog] {
        self.map { Dog(imageURL: $0.imageURL) }
    }
}
