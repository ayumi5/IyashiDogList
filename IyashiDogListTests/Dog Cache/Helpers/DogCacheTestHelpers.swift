//
//  DogCacheTestHelpers.swift
//  IyashiDogListTests
//
//  Created by 宇高あゆみ on 2022/03/03.
//

import Foundation
import IyashiDogList
import IyashiDogFeature
import CoreData

func uniqueDogs() -> (models: [Dog], locals: [LocalDog]) {
    let models = [uniqueDog(), uniqueDog()]
    let locals = models.map { LocalDog(imageURL: $0.imageURL) }
    return (models: models, locals: locals)
}

func uniqueDog() -> Dog {
    Dog(imageURL: uniqueURL())
}

func uniqueURL() -> URL {
    URL(string: "http://unique-url-\(UUID()).com")!
}

extension Date {
    func minusCacheMaxAge() -> Date {
        self.adding(days: -cacheMaxAgeInDays)
    }
    
    private var cacheMaxAgeInDays: Int {
        return 7
    }
    
    func adding(days: Int) -> Date {
        let calendar = Calendar.init(identifier: .gregorian)
        return calendar.date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}

extension NSManagedObjectContext {
    static func alwaysFailingFetchStub() -> Stub {
        Stub(#selector(NSManagedObjectContext.__execute(_:)),
             #selector(Stub.execute(_:)))
    }
    
    static func alwaysFailingSaveStub() -> Stub {
        Stub(#selector(NSManagedObjectContext.save),
             #selector(Stub.save))
    }
    
    class Stub: NSObject {
        private let source: Selector
        private let destination: Selector
        
        init(_ source: Selector, _ destination: Selector) {
            self.source = source
            self.destination = destination
        }
        
        @objc func execute(_: Any) throws -> Any {
            throw anyNSError()
        }
        
        @objc func save() throws {
            throw anyNSError()
        }
        
        func startIntercepting() {
            method_exchangeImplementations(class_getInstanceMethod(NSManagedObjectContext.self, source)!,
                                           class_getInstanceMethod(Stub.self, destination)!)
        }
        
        deinit {
            method_exchangeImplementations(
                class_getInstanceMethod(Stub.self, destination)!,
                class_getInstanceMethod(NSManagedObjectContext.self, source)!
            )
        }
    }
}
