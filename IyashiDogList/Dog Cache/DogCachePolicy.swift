//
//  DogCachePolicy.swift
//  IyashiDogList
//
//  Created by 宇高あゆみ on 2022/03/03.
//

import Foundation

final class DogCachePolicy {
    
    private init() { }
    
    private static var maxCacheAgeInDays: Int {
        return 7
    }
    
    static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = Calendar(identifier: .gregorian).date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
            return false
        }
        return date < maxCacheAge
    }
}
