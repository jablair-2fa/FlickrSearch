//
//  Photo.swift
//  FlickrSearch
//
//  Created by Eric Blair on 12/9/19.
//  Copyright © 2019 Eric Blair. All rights reserved.
//

import Foundation

/// Minimum required representation of a Flickr Photo
struct Photo: Codable, Equatable {
    /// Photo ID
    let id: String
    /// The farm subdomain ID
    let farm: Int
    /// The Flickr server ID
    let server: String
    /// The Photo secret
    let secret: String
    /// The photo title
    let title: String
    
    /// The thumbnail image for the photo
    var thumbnailURL: URL? { url(for: .thumbnail) }
    
    /// The large image for the photo
    var largeImageURL: URL? { url(for: .large) }
    
    /// Supported image sizes
    private enum ImageSize: String {
        case thumbnail = "t"
        case large = "b"
    }
    
    /// Convenience method for generating an image URL of the requested size
    /// - Parameter imageSize: The desired image size
    /// - Returns: The URL
    private func url(for imageSize: ImageSize) -> URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "farm\(farm).staticflickr.com"
        urlComponents.path = "/\(server)/\(id)_\(secret)_\(imageSize.rawValue).jpg"
        
        return urlComponents.url
    }
}
