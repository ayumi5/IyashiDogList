//
//  ManagedDogImage.swift
//  IyashiDogList
//
//  Created by 宇高あゆみ on 2022/03/05.
//

import Foundation
import CoreData

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
