//
//  FlickrService.swift
//  FlickrSearch
//
//  Created by Eric Blair on 12/9/19.
//  Copyright © 2019 Eric Blair. All rights reserved.
//

import Foundation

/// Flickr Networking interface
final class FlickrService {
    /// The URL session
    private let urlSession: URLSession
    
    /// Configures the networking interface
    /// - Parameter urlSession: The URL session. Optional, defaults to `.shared`.
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    /// Submits a network request
    /// - Parameters:
    ///   - request: The request
    ///   - completion: The completion handler
    /// - Returns: A cancellation token
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
    
    /// The Request type
    struct Request<T> {
        /// The URL for the request
        let url: URL
        /// The response renderer
        let renderer: DataRenderer<T>
    }
    
    /// Generic network service errors
    enum Error: LocalizedError {
        case invalidRequest
        case networkFailure(Swift.Error)
        case emptyResponse
        
        var errorDescription: String? {
            switch self {
            case .invalidRequest: return "The URL could not be constructed for the request"
            case .networkFailure(let error): return error.localizedDescription
            case .emptyResponse: return "The repsonse payload did not contain any data"
            }
        }
    }
}
