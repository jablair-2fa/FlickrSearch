//
//  NetworkTokenTests.swift
//  FlickrSearchTests
//
//  Created by Eric Blair on 12/9/19.
//  Copyright © 2019 Eric Blair. All rights reserved.
//

import XCTest
@testable import FlickrSearch

/// Tests network token behavior
class NetworkTokenTests: XCTestCase {

    func testTokenCancellation() {
        let task = MockURLSessionDataTask()
        
        let token = NetworkToken(task: task)
        token.cancel()
        XCTAssertTrue(task.didCancel)
    }
    
    /// URLSessionDataTaskTracking for testing
    private class MockURLSessionDataTask: URLSessionDataTaskTracking {
        var didCancel: Bool = false
        
        func cancel() {
            didCancel = true
        }
    }
}
