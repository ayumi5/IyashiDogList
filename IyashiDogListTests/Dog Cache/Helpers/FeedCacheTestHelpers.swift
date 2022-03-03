//
//  FeedCacheTestHelpers.swift
//  IyashiDogListTests
//
//  Created by 宇高あゆみ on 2022/03/03.
//

import Foundation
import IyashiDogList

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

func anyNSError() -> NSError {
    NSError.init(domain: "any error", code: 0)
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
