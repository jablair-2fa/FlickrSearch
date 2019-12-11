//
//  PhotoTableViewCell.swift
//  FlickrSearch
//
//  Created by Eric Blair on 12/10/19.
//  Copyright © 2019 Eric Blair. All rights reserved.
//

import UIKit

class PhotoTableViewCell: UITableViewCell {
    @IBOutlet private var photoView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var downloadIndicator: UIActivityIndicatorView!
    
    static var reuseIdentifier: String = "PhotoTableViewCell"
    
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
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        viewModel?.cancelThumnailRequest()
        viewModel = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
