//
//  PhotoTests.swift
//  FlickrSearchTests
//
//  Created by Eric Blair on 12/10/19.
//  Copyright © 2019 Eric Blair. All rights reserved.
//

import XCTest
@testable import FlickrSearch

/// Tests Photo URL generation
class PhotoTests: XCTestCase {
    let photo = Photo(id: "123", farm: 16, server: "animal", secret: "boo", title: "Title")
    
    /// Confirms the generation fo the Thumbnail URL
    func testThumbnailImageURLGeneration() {
        XCTAssertEqual(photo.thumbnailURL?.absoluteString, "https://farm16.staticflickr.com/animal/123_boo_t.jpg")
    }
    
    /// Confirms the generation of the Large Image URL
    func testBigImageURLGeneration() {
        XCTAssertEqual(photo.largeImageURL?.absoluteString, "https://farm16.staticflickr.com/animal/123_boo_b.jpg")
    }
}
