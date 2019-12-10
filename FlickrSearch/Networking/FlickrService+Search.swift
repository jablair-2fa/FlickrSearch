//
//  FlickrService+Search.swift
//  FlickrSearch
//
//  Created by Eric Blair on 12/9/19.
//  Copyright © 2019 Eric Blair. All rights reserved.
//

import Foundation

extension FlickrService.Request where T == SearchResults {
    /// Instantiates a search request
    /// - Parameters:
    ///   - term: The search term
    ///   - page: The search result page. Optional, defaults to 1.
    ///   - apiKey: The API key. Optional, defaults to standard value.
    /// - Note: Bundling the API key in plain text isn't the best practice…
    static func search(for term: String, page: Int = 1, apiKey: String = "1508443e49213ff84d566777dc211f2a") throws -> FlickrService.Request<T> {
        guard page > 0 else {
            throw FlickrService.Error.invalidRequest
        }
        
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "method", value: "flickr.photos.search"),
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "per_page", value: "25"),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "text", value: term),
            URLQueryItem(name: "nojsoncallback", value: "1")
        ]
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.flickr.com"
        components.path = "/services/rest/"
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw FlickrService.Error.invalidRequest
        }
        
        return Self(url: url, renderer: DataRenderer<T>.jsonRenderer)
    }
}

/// Model for the search results
struct SearchResults: Decodable {
    /// Private struct used for JSON parsing
    private struct PhotosResult: Decodable {
        /// The search results metadata
        let metadata: SearchMetadata
        /// The photos in the search result
        let photo: [Photo]

        enum CodingKeys : String, CodingKey {
            case photo
        }

        init(from decoder: Decoder) throws {
            self.metadata = try SearchMetadata(from: decoder)
            
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.photo = try container.decode([Photo].self, forKey: .photo)
        }
    }

    enum CodingKeys : String, CodingKey {
        case photoResult = "photos"
    }
    
    /// Internal representation of the parsed data
    private let photoResult: PhotosResult
    
    /// The metadata associated with the search response
    var metadata: SearchMetadata { photoResult.metadata }
    /// The photos in the search response
    var photos: [Photo] { photoResult.photo }
}

