//
//  DataRenderer.swift
//  FlickrSearch
//
//  Created by Eric Blair on 12/9/19.
//  Copyright © 2019 Eric Blair. All rights reserved.
//

import UIKit

/// Protocol for rendering data to a response type
struct DataRenderer<T> {
    private let parser: (Data) throws -> T
    
    init(parser: @escaping (Data) throws -> T) {
        self.parser = parser
    }
    
    /// Converts the incoming data to the expected type or throws an error on failure
    /// - Parameter data: The data to parse
    /// - Returns: The converted type
    /// - Throws: Rendering error
    func parse(data: Data) throws -> T {
        try parser(data)
    }
}

/// Data Rendering errors
///
/// - unrecognizedData: Generic error when not able to convert data to the requested type
enum DataRenderingError: Swift.Error {
    case unrecognizedData
}


extension DataRenderer where T == UIImage {
    static var imageRenderer: DataRenderer<UIImage> {
        return DataRenderer<UIImage> { data in
            guard let image = UIImage(data: data) else {
                throw DataRenderingError.unrecognizedData
            }
            
            return image
        }
    }
}

extension DataRenderer where T: Decodable {
    static var jsonRenderer: DataRenderer<T> {
        return DataRenderer<T> { data in
            let decoder = JSONDecoder()
            let object = try decoder.decode(T.self, from: data)
            return object
        }
    }
}
