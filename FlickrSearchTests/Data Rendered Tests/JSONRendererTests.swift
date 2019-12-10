//
//  JSONRendererTests.swift
//  FlickrSearchTests
//
//  Created by Eric Blair on 12/9/19.
//  Copyright © 2019 Eric Blair. All rights reserved.
//

import XCTest
@testable import FlickrSearch

/// Tests the behavior of the JSONRenderer
class JSONRendererTests: XCTestCase {
    /// Single `TestType` rendererer
    private let singleValueRenderer: DataRenderer<TestType> = .jsonRenderer
//    private let singleValueRenderer = JSONRenderer<TestType>()
    /// Array of `TestType` renderer
    private let arrayRenderer: DataRenderer<[TestType]> = .jsonRenderer
    
    /// Tests that rendering data representing a single value works
    func testSingleValueRenderer() throws {
        let value = TestType(id: 1, title: "Title")
        let jsonData = try data(for: value)
        
        let renderedValue = try singleValueRenderer.parse(data: jsonData)
        
        XCTAssertEqual(value, renderedValue)
    }
    
    /// Tests that rendering data representing an array of values works
    func testArrayRenderer() throws {
        let values: [TestType] = [
            .init(id: 1, title: "Title 1"),
            .init(id: 2, title: "Title 2")
        ]
        
        let jsonData = try data(for: values)
        let renderedValues = try arrayRenderer.parse(data: jsonData)
        
        XCTAssertEqual(values, renderedValues)
    }
    
    /// Tests that the renderer validates the data type
    func testDataTypeMismatch() throws {
        let value = TestType(id: 1, title: "Title")
        let jsonData = try data(for: value)
        
        XCTAssertThrowsError(try arrayRenderer.parse(data: jsonData))
    }
    
    /// Tests that the renderer rejects non-json data
    func testNonJSONData() {
        let data = "ThisIsNotJSON".data(using: .utf8)!
        XCTAssertThrowsError(try singleValueRenderer.parse(data: data))
    }
    
    /// Convenience Method for generating JSON data
    /// - Parameter value: Value to encode
    /// - Returns: Data representation
    private func data<T: Encodable>(for value: T) throws -> Data {
        let encoder = JSONEncoder()
        let data = try encoder.encode(value)
        
        return data
    }
    
    /// Test type
    private struct TestType: Codable, Equatable {
        let id: Int
        let title: String
    }
}
