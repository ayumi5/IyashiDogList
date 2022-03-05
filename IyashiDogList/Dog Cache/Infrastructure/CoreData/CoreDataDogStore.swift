//
//  CoreDataDogStore.swift
//  IyashiDogList
//
//  Created by 宇高あゆみ on 2022/03/03.
//

import Foundation
import CoreData

public final class CoreDataDogStore: DogStore {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "CoreDataDogStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }

    public func deleteCache(completion: @escaping DeletionCompletion) {
        context.perform { [context] in
            do {
                try ManagedDogCache.find(in: context).map(context.delete).map(context.save)
                completion(nil)
            } catch {
                context.rollback()
                completion(error)
            }
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        context.perform { [context] in
            do {
                if let cache = try ManagedDogCache.find(in: context) {
                    completion(.found(cache.toLocals(), cache.timestamp))
                } else {
                    completion(.empty)
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func insert(_ dogs: [LocalDog], timestamp: Date, completion: @escaping InsertionCompletion) {
        context.perform { [context] in
            do {
                let newDog = try ManagedDogCache.newUniqueInstance(in: context)
                newDog.dogs = ManagedDogImage.toNSOrderSet(from: dogs, in: context)
                newDog.timestamp = timestamp

                try context.save()
                completion(nil)
            } catch {
                context.rollback()
                completion(error)
            }
        }
    }
}
