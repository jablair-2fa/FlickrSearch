//
//  FlickrErrorTests.swift
//  FlickrSearchTests
//
//  Created by Eric Blair on 12/9/19.
//  Copyright © 2019 Eric Blair. All rights reserved.
//

import XCTest
@testable import FlickrSearch

/// Testing the parsing of FlickrError instance since we've got custom parsing logic
class FlickrErrorTests: XCTestCase {
    
    /// Tests that an integer error code works
    func testIntCode() throws {
        let jsonData = """
        {
          "stat": "fail",
          "code": 100,
          "message": "Invalid API Key (Key has invalid format)"
        }
        """.data(using: .utf8)!
        
        let jsonDecoder = JSONDecoder()
        let error = try jsonDecoder.decode(FlickrError.self, from: jsonData)
        XCTAssertEqual(error, FlickrError(code: 100, message: "Invalid API Key (Key has invalid format)"))
    }
    
    /// Tests that a String error code works
    func testStringCode() throws {
        let jsonData = """
        {
          "stat": "fail",
          "code": "100",
          "message": "Invalid API Key (Key has invalid format)"
        }
        """.data(using: .utf8)!
        
        let jsonDecoder = JSONDecoder()
        let error = try jsonDecoder.decode(FlickrError.self, from: jsonData)
        XCTAssertEqual(error, FlickrError(code: 100, message: "Invalid API Key (Key has invalid format)"))
    }

    /// Tests that a String error code works even if it cannot map to an Int
    func testNonIntStringCode() throws {
        let jsonData = """
        {
          "stat": "fail",
          "code": "abc",
          "message": "Invalid API Key (Key has invalid format)"
        }
        """.data(using: .utf8)!
        
        let jsonDecoder = JSONDecoder()
        let error = try jsonDecoder.decode(FlickrError.self, from: jsonData)
        XCTAssertEqual(error, FlickrError(code: -1, message: "Invalid API Key (Key has invalid format)"))
    }

    /// Test that the error message is required
    func testMissingMessage() throws {
        let jsonData = """
        {
          "stat": "fail",
          "code": 100
        }
        """.data(using: .utf8)!
        
        let jsonDecoder = JSONDecoder()
        XCTAssertThrowsError(try jsonDecoder.decode(FlickrError.self, from: jsonData))
    }
}
