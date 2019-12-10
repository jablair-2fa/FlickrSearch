//
//  FlickrService+Image.swift
//  FlickrSearch
//
//  Created by Eric Blair on 12/10/19.
//  Copyright © 2019 Eric Blair. All rights reserved.
//

import UIKit

extension FlickrService.Request where T == UIImage {
    /// Thumbnail image request
    /// - Parameter photo: The photo record
    static func thumbnailImage(for photo: Photo) throws -> FlickrService.Request<T> {
        guard let thumbnailURL = photo.thumbnailURL else {
            throw FlickrService.Error.invalidRequest
        }
        
        return Self(url: thumbnailURL, renderer: DataRenderer<T>.imageRenderer)
    }
    
    /// Large image request
    /// - Parameter photo: The photo record
    static func largeImage(for photo: Photo) throws -> FlickrService.Request<T> {
        guard let largeImageURL = photo.largeImageURL else {
            throw FlickrService.Error.invalidRequest
        }
        
        return Self(url: largeImageURL, renderer: DataRenderer<T>.imageRenderer)
    }
}
