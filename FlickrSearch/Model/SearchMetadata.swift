//
//  SearchMetadata.swift
//  FlickrSearch
//
//  Created by Eric Blair on 12/9/19.
//  Copyright © 2019 Eric Blair. All rights reserved.
//

import Foundation

/// Search Metadata for supporting multiple pages
struct SearchMetadata: Codable, Equatable {
    /// The current page
    let page: Int
    /// The total number of pages
    let pages: Int
    /// The number of items per page
    let perpage: Int
}
