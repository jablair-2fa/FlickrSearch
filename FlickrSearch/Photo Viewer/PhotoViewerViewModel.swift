//
//  PhotoViewerViewModel.swift
//  FlickrSearch
//
//  Created by Eric Blair on 12/10/19.
//  Copyright © 2019 Eric Blair. All rights reserved.
//

import UIKit

/// Photo Viewer view model for mapping a photo to a display interface
class PhotoViewerViewModel: NSObject {
    /// The photo
    private let photo: Photo
    /// The networking service
    private let flickrService: FlickrService
    
    /// The photo title
    var title: String { photo.title }
    
    /// The image
    private var image: UIImage?
    /// The image download request token
    private var imageRequestToken: NetworkToken?
    
    /// Initializes a view model
    /// - Parameters:
    ///   - photo: The photo
    ///   - flickrService: The networking service
    init(photo: Photo, flickrService: FlickrService) {
        self.photo = photo
        self.flickrService = flickrService
    }
    
    /// Fetches the image from the remote resource
    /// - Parameter requestHandler: The callback handler
    func image(requestHandler: @escaping (Result<UIImage, Error>) -> ()) {
        if let thumbnail = self.image {
            requestHandler(.success(thumbnail))
            return
        }
        
        do {
            let request: FlickrService.Request<UIImage> = try .largeImage(for: photo)
            
            flickrService.request(request) { (result) in
                requestHandler(result)
            }
        } catch {
            requestHandler(.failure(error))
        }
    }
    
    /// Cancels the pending download
    func cancelImageRequest() {
        imageRequestToken?.cancel()
    }
}
