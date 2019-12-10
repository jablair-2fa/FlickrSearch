//
//  FlickrError.swift
//  FlickrSearch
//
//  Created by Eric Blair on 12/9/19.
//  Copyright © 2019 Eric Blair. All rights reserved.
//

import Foundation

/// Model of a Flick error response
struct FlickrError: Codable, LocalizedError, Equatable {
    /// The error code
    let code: Int
    /// The error message
    let message: String
    
    var errorDescription: String? { return message }
}

extension FlickrError {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // According to the API docs, code is a String. According to usage,
        // I'm seeing it as an Int. Let's try both, to be safe.
        do {
            self.code = try container.decode(Int.self, forKey: .code)
        } catch {
            let codeString = try container.decode(String.self, forKey: .code)
            self.code = Int(codeString) ?? -1
        }
        
        self.message = try container.decode(String.self, forKey: .message)
    }
}

