//
//  PhotoTableViewCell.swift
//  FlickrSearch
//
//  Created by Eric Blair on 12/10/19.
//  Copyright © 2019 Eric Blair. All rights reserved.
//

import UIKit

/// Cell for displaying photo and thumbnail
class PhotoTableViewCell: UITableViewCell {
    /// The thumbnail image  view
    @IBOutlet private var photoView: UIImageView!
    /// The image title
    @IBOutlet private var titleLabel: UILabel!
    /// The download indicator
    @IBOutlet private var downloadIndicator: UIActivityIndicatorView!
    
    /// Cell reuse identifier
    static var reuseIdentifier: String = "PhotoTableViewCell"
    
    /// View Model mapping the photo to the cell appearance
    var viewModel: PhotoTableViewCellViewModel? {
        didSet {
            titleLabel.text = viewModel?.title
            photoView.image = nil
            downloadIndicator.startAnimating()
            viewModel?.thumbnail { [weak self] (result) in
                let image: UIImage?
                switch result {
                case .success(let thumbnail):
                    image = thumbnail
                case .failure(_):
                    image = UIImage(systemName: "nosign")
                }
                
                DispatchQueue.main.async {
                    self?.downloadIndicator.stopAnimating()
                    self?.photoView.image = image
                }
            }
        }
    }
    
    override func prepareForReuse() {
        viewModel?.cancelThumnailRequest()
        viewModel = nil
    }
}
