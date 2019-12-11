//
//  PhotoViewerViewModel.swift
//  FlickrSearch
//
//  Created by Eric Blair on 12/10/19.
//  Copyright © 2019 Eric Blair. All rights reserved.
//

import UIKit

class PhotoViewerViewModel: NSObject {
    private let photo: Photo
    private let flickrService: FlickrService
    
    var title: String { photo.title }
    private var image: UIImage?
    private var imageRequestToken: NetworkToken?
    
    init(photo: Photo, flickrService: FlickrService) {
        self.photo = photo
        self.flickrService = flickrService
    }
    
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
    
    func cancelImageRequest() {
        imageRequestToken?.cancel()
    }
}
