//
//  FlickrService.swift
//  FlickrSearch
//
//  Created by Eric Blair on 12/9/19.
//  Copyright © 2019 Eric Blair. All rights reserved.
//

import Foundation

final class FlickrService {
    private let urlSession: URLSession
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    @discardableResult
    func request<T>(_ request: Request<T>, completion: ((Result<T, Swift.Error>) -> ())?) -> NetworkToken {
        
        let task = urlSession.dataTask(with: request.url) { data, _, error in
            let result: Result<T, Swift.Error>
            
            defer {
                completion?(result)
            }
            
            if let flickrError = error.map( { FlickrService.Error.networkFailure($0) }) {
                result = .failure(flickrError)
                return
            }
            
            guard let data = data else {
                result = .failure(FlickrService.Error.emptyResponse)
                return
            }
            
            result = Result(catching: { () in
                try request.renderer.parse(data: data)
            })
        }
        let token = NetworkToken(task: task)
        
        task.resume()
        
        return token
    }
    
    struct Request<T> {
        let url: URL
        let renderer: DataRenderer<T>
    }
    
    enum Error: Swift.Error {
        case invalidRequest
        case networkFailure(Swift.Error)
        case emptyResponse
    }
}
