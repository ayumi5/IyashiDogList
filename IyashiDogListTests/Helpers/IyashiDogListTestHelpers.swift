//
//  IyashiDogListTestHelpers.swift
//  IyashiDogListTests
//
//  Created by 宇高あゆみ on 2022/06/27.
//

import Foundation

func anyNSError() -> NSError {
    NSError.init(domain: "any error", code: 0)
}

func anyURL() -> URL {
    return URL(string: "http://a-url.com")!
}

func anyData() -> Data {
    return Data("any data".utf8)
}
