//
//  SearchRequestTests.swift
//  FlickrSearchTests
//
//  Created by Eric Blair on 12/10/19.
//  Copyright © 2019 Eric Blair. All rights reserved.
//

import XCTest
@testable import FlickrSearch

class SearchRequestTests: XCTestCase {
    /// Tests constructing a URL to the default (first) page
    func testDefaultPageURLConstruction() throws {
        let searchRenderer: FlickrService.Request<SearchResults> = try .search(for: "Search String", apiKey: "key")

        let urlComponents = URLComponents(url: searchRenderer.url, resolvingAgainstBaseURL: false)
        XCTAssertEqual(urlComponents?.scheme, "https")
        XCTAssertEqual(urlComponents?.host, "www.flickr.com")
        XCTAssertEqual(urlComponents?.path, "/services/rest/")
        
        check(queryItems: urlComponents?.queryItems, for: "Search String", apiKey: "key", page: 1)
    }
    
    /// Tests constructing a URL to a specified page
    func testPage2URLConstruction() throws {
        let searchRenderer: FlickrService.Request<SearchResults> = try .search(for: "Search String", page: 2, apiKey: "key")

        let urlComponents = URLComponents(url: searchRenderer.url, resolvingAgainstBaseURL: false)
        XCTAssertEqual(urlComponents?.scheme, "https")
        XCTAssertEqual(urlComponents?.host, "www.flickr.com")
        XCTAssertEqual(urlComponents?.path, "/services/rest/")
        
        check(queryItems: urlComponents?.queryItems, for: "Search String", apiKey: "key", page: 2)
    }
    
    /// Confirms that page number must be greater than 0
    func testMinPage1Required() {
        XCTAssertThrowsError(try FlickrService.Request<SearchResults>.search(for: "SearchString", page: 0))
    }
    
    /// Convenience method for validating the search query items
    /// - Parameters:
    ///   - queryItems: The query items
    ///   - term: The search term
    ///   - apiKey: The api key
    ///   - page: The page number
    private func check(queryItems: [URLQueryItem]?, for term: String, apiKey: String, page: Int, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(queryItems?.count, 7)
        guard let queryItems = queryItems else {
            return
        }

        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "method", value: "flickr.photos.search")))
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "api_key", value: apiKey)))
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "format", value: "json")))
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "per_page", value: "25")))
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "page", value: "\(page)")))
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "text", value: term)))
        XCTAssertTrue(queryItems.contains(URLQueryItem(name: "nojsoncallback", value: "1")))
    }
}
