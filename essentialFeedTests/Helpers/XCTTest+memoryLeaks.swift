//
//  XCTTest+memoryLeaks.swift
//  essentialFeedTests
//
//  Created by Mathieu Janneau on 09/12/2021.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "instance should have been deallocated", file: file, line: line)
        }
    }
}
