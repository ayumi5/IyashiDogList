//
//  XCTestCase+MemoryLeakTracking.swift
//  IyashiDogListTests
//
//  Created by 宇高あゆみ on 2022/01/24.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak", file: file, line: line)
        }
    }
}
