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
    func request<T>(_ request: Request<T>, completion: (Result<T, Error>)) -> NetworkToken {
        let task = urlSession.dataTask(with: request.url) { data, _, error in
            
        }
        let token = NetworkToken(task: task)
        
        task.resume()
        
        return token
    }
    
    struct Request<T> {
        let url: URL
        let renderer: DataRenderer<T>
    }
}

extension FlickrService.Request {
    static func search(for term: String, page: Int = 1) {
        
    }
}

