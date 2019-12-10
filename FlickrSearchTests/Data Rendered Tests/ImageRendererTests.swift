//
//  ImageRendererTests.swift
//  FlickrSearchTests
//
//  Created by Eric Blair on 12/9/19.
//  Copyright © 2019 Eric Blair. All rights reserved.
//

import XCTest
@testable import FlickrSearch

/// Tests the behavior of the image renderer
class ImageRendererTests: XCTestCase {
    /// The image renderer
    let imageRenderer: DataRenderer<UIImage> = .imageRenderer
    
    /// Confirms that valid image data gets converted to an image
    func testImageRenderer() throws {
        guard let imageURL = Bundle(for: Self.self).url(forResource: "IMG_0947-Thumbnail", withExtension: "jpeg") else {
            XCTFail("Failed to load image data")
            return
        }
        let imageData = try Data(contentsOf: imageURL)
        
        XCTAssertNoThrow(try imageRenderer.parse(data: imageData))
    }
    
    /// Confirms that non-image data throws an error
    func testImageRendererFailure() {
        let nonImageData = "This is not an image".data(using: .utf8)!
        
        XCTAssertThrowsError(try imageRenderer.parse(data: nonImageData)) { (error) in
            guard case DataRenderingError.unrecognizedData = error else {
                XCTFail("Unexpected error type")
                return
            }
        }
    }

}
