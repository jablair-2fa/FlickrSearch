//
//  PhotoTableViewCellViewModel.swift
//  FlickrSearch
//
//  Created by Eric Blair on 12/10/19.
//  Copyright © 2019 Eric Blair. All rights reserved.
//

import UIKit

class PhotoTableViewCellViewModel {
    private let photo: Photo
    private let flickrService: FlickrService
    
    var title: String { photo.title }
    private var thumbnail: UIImage?
    private var thumbnailRequestToken: NetworkToken?
    
    init(photo: Photo, flickrService: FlickrService) {
        self.photo = photo
        self.flickrService = flickrService
    }
    
    func thumbnail(requestHandler: @escaping (Result<UIImage, Error>) -> ()) {
        if let thumbnail = self.thumbnail {
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
    
    func cancelThumnailRequest() {
        thumbnailRequestToken?.cancel()
    }
}
