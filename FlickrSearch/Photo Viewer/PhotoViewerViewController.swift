//
//  PhotoViewerViewController.swift
//  FlickrSearch
//
//  Created by Eric Blair on 12/10/19.
//  Copyright © 2019 Eric Blair. All rights reserved.
//

import UIKit

/// Flickr photo viewer
final class PhotoViewerViewController: UIViewController {
    /// Storyboard identifier
    static let identifier = "PhotoViewController"
    
    /// The photo view model
    let viewModel: PhotoViewerViewModel
    
    /// The image view
    @IBOutlet private var imageView: UIImageView!
    /// The loading indicator
    @IBOutlet private var loadIndicator: UIActivityIndicatorView!
    
    /// Initialized a photo viewer with a view model
    /// - Parameters:
    ///   - coder: The coder
    ///   - viewModel: The view model
    init?(coder: NSCoder, viewModel: PhotoViewerViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = viewModel.title
        viewModel.image { [weak self] (result) in
            guard let self = self else { return }
            
            let displayImage: UIImage?
            switch result {
            case .success(let image):
                displayImage = image
            case .failure(_):
                displayImage = UIImage(systemName: "nosign")
            }
            
            DispatchQueue.main.async {
                self.loadIndicator.stopAnimating()
                self.imageView.image = displayImage
                self.setImageViewMode()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setImageViewMode()
    }
    
    /// Shows or hides the navigation bar for an immersive experience
    /// - Parameter sender: The sender
    @IBAction func toggleNavigationBarVisibility(_ sender: Any) {
        guard let navigationController = navigationController else { return }
        
        // Doing this manually instead of using `hidesBarOnTap` to limit the hiding behavior to the view controller
        navigationController.setNavigationBarHidden(!navigationController.isNavigationBarHidden, animated: true)
    }
    
    /// Updates the image view content mode to provide the best appearance
    private func setImageViewMode() {
        guard let image = imageView.image else { return }
        if imageView.bounds.width > image.size.width && imageView.bounds.height > image.size.height {
            imageView.contentMode = .center
        } else {
            imageView.contentMode = .scaleAspectFit
        }
    }
    

}
