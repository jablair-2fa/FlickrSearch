//
//  SearchResultsTests.swift
//  FlickrSearchTests
//
//  Created by Eric Blair on 12/9/19.
//  Copyright © 2019 Eric Blair. All rights reserved.
//

import XCTest
@testable import FlickrSearch

class SearchResultsTests: XCTestCase {

    func testResultParsing() throws {
        guard let jsonURL = Bundle(for: Self.self).url(forResource: "SearchResults", withExtension: "json") else {
            XCTFail()
            return
        }
        
        let jsonData = try Data(contentsOf: jsonURL)
        
        let jsonDecoder = JSONDecoder()
        let searchResults: SearchResults
        do {
            searchResults = try jsonDecoder.decode(SearchResults.self, from: jsonData)

            XCTAssertEqual(searchResults.metadata, SearchMetadata(page: 162, pages: 18443, perpage: 25))
            XCTAssertEqual(searchResults.photos.count, 25)
        } catch {
            print(error)
            XCTFail()
        }
        
    }

}
