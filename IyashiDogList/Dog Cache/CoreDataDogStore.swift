//
//  CoreDataDogStore.swift
//  IyashiDogList
//
//  Created by 宇高あゆみ on 2022/03/03.
//

import Foundation
import CoreData

public final class CoreDataDogStore {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "CoreDataDogStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }
    
    public typealias RetrievalCompletion = (RetrieveCacheResult) -> Void
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        context.perform { [context] in
            do {
                let request = NSFetchRequest<ManagedDogCache>(entityName: "ManagedDogCache")
                request.returnsObjectsAsFaults = false
                if let cache = try context.fetch(request).first {
                    let localDogs = cache.dogs.compactMap { $0 as? ManagedDogImage }.map { LocalDog(imageURL: $0.url) }
                    completion(.found(localDogs, cache.timestamp))
                } else {
                    completion(.empty)
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
}

extension NSPersistentContainer {
    
    enum LoadingError: Swift.Error {
        case modelNotFound
        case failedToLoadPersistentStores(Swift.Error)
    }
    
    static func load(modelName name: String, url: URL, in bundle: Bundle) throws -> NSPersistentContainer {
        guard let model = NSManagedObjectModel.with(name: name, in: bundle) else {
            throw LoadingError.modelNotFound
        }
        
        let description = NSPersistentStoreDescription(url: url)
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        
        container.persistentStoreDescriptions = [description]
        
        var loadError: Swift.Error?
        container.loadPersistentStores { loadError = $1 }
        try loadError.map { throw LoadingError.failedToLoadPersistentStores($0) }
        
        return container
        
    }
}

private extension NSManagedObjectModel {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        return bundle
            .url(forResource: name, withExtension: "momd")
            .flatMap { NSManagedObjectModel(contentsOf: $0)}
    }
}
