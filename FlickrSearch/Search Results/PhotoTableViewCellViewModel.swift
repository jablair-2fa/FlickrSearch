//
//  PhotoTableViewCellViewModel.swift
//  FlickrSearch
//
//  Created by Eric Blair on 12/10/19.
//  Copyright © 2019 Eric Blair. All rights reserved.
//

import UIKit

/// View Model mapping a photo to a thubnail display
class PhotoTableViewCellViewModel {
    /// The photo
    private let photo: Photo
    /// The networking service
    private let flickrService: FlickrService
    
    /// The title of the photo
    var title: String { photo.title }
    /// The image thumbnail
    private var thumbnail: UIImage?
    /// The thubmnail network request token
    private var thumbnailRequestToken: NetworkToken?
    
    /// Initialized a view model
    /// - Parameters:
    ///   - photo: The photo
    ///   - flickrService: The networking service
    init(photo: Photo, flickrService: FlickrService) {
        self.photo = photo
        self.flickrService = flickrService
    }
    
    /// Requests the thumbnail representation of the image
    /// - Parameter requestHandler: The callback handler
    func thumbnail(requestHandler: @escaping (Result<UIImage, Error>) -> ()) {
        if let thumbnail = self.thumbnail {
            // short-circuit the network request is we're already downloaded the thumbnail
            requestHandler(.success(thumbnail))
            return
        }
        
        do {
            let request: FlickrService.Request<UIImage> = try .thumbnailImage(for: photo)
            
            flickrService.request(request) { (result) in
                requestHandler(result)
            }
        } catch {
            requestHandler(.failure(error))
        }
    }
    
    /// Cancels the download request
    func cancelThumnailRequest() {
        thumbnailRequestToken?.cancel()
    }
}
