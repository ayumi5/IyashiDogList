//
//  ManagedDogCache.swift
//  IyashiDogList
//
//  Created by 宇高あゆみ on 2022/03/05.
//

import Foundation
import CoreData

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
