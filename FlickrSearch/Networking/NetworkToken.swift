//
//  NetworkToken.swift
//  FlickrSearch
//
//  Created by Eric Blair on 12/9/19.
//  Copyright © 2019 Eric Blair. All rights reserved.
//

import Foundation

/// Token handler for tracking asynchronous network requests
class NetworkToken {
    /// The request being tracked
    private weak var task: URLSessionDataTaskTracking?
    
    /// Configures a network token
    /// - Parameter task: The task being tracked
    init(task: URLSessionDataTaskTracking) {
        self.task = task
    }
    
    /// Cancels the associated network request
    func cancel() {
        task?.cancel()
    }
}

/// Protocol for testable network operation tracking
protocol URLSessionDataTaskTracking: AnyObject {
    func cancel()
}

extension URLSessionDataTask: URLSessionDataTaskTracking { }
