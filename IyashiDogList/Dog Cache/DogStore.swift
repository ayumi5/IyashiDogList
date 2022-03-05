//
//  DogStore.swift
//  IyashiDogList
//
//  Created by 宇高あゆみ on 2022/03/02.
//

import Foundation
import CoreData

public enum RetrieveCacheResult {
    case empty
    case found([LocalDog], Date)
    case failure(Error)
}

public protocol DogStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (RetrieveCacheResult) -> Void
    
    func deleteCache(completion: @escaping DeletionCompletion)
    func insert(_ dogs: [LocalDog], timestamp: Date, completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}

@objc(ManagedDogCache)
class ManagedDogCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var dogs: NSOrderedSet
    
    func toLocals() -> [LocalDog] {
        self.dogs.compactMap { $0 as? ManagedDogImage }.map { $0.toLocal() }
    }
    
    static func find(in context: NSManagedObjectContext) throws -> ManagedDogCache? {
        let request = NSFetchRequest<ManagedDogCache>(entityName: ManagedDogCache.entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }
    
    static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedDogCache {
        try ManagedDogCache.find(in: context).map(context.delete)
        return ManagedDogCache(context: context)
    }
}


@objc(ManagedDogImage)
class ManagedDogImage: NSManagedObject {
    @NSManaged var imageURL: URL
    @NSManaged var cache: ManagedDogCache
    
    func toLocal() -> LocalDog {
        LocalDog(imageURL: self.imageURL)
    }
    
    static func toNSOrderSet(from dogs: [LocalDog], in context: NSManagedObjectContext) -> NSOrderedSet {
        let managedDogImages: [ManagedDogImage] = dogs.map { dog in
            let dogImage = ManagedDogImage(context: context)
            dogImage.imageURL = dog.imageURL
            return dogImage
        }
        return NSOrderedSet(array: managedDogImages)
    }
}
