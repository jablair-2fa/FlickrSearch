//
//  FlickrSearchResultsViewController.swift
//  FlickrSearch
//
//  Created by Eric Blair on 12/10/19.
//  Copyright © 2019 Eric Blair. All rights reserved.
//

import UIKit

/// Search results table view controller
class FlickrSearchResultsViewController: UIViewController {
    /// Storyboard identifier
    static let identifier = "FlickSearchResultsViewController"

    /// The table view
    @IBOutlet private var tableView: UITableView!
    
    /// The flickr networking interface
    private let flickrService: FlickrService
    /// The current search token
    private var currentSearchToken: NetworkToken?
    /// The last retrieved search metadata
    private var lastSearchMetadata: SearchMetadata?
    
    /// The search results delegate
    weak var delegate: FlickrSearchResultsViewControllerDelegate?
    
    /// The current search term
    /// Setting the search term to a non-empty string triggers a new search. Setting
    /// to an empty string clears the search results
    var searchTerm: String? {
        didSet {
            guard searchTerm != oldValue else { return }

            // Clear out the old search results and data
            lastSearchMetadata = nil
            
            var snapshot = NSDiffableDataSourceSnapshot<Section, Photo>()
            snapshot.deleteAllItems()
            snapshot.appendSections([.photos])
            dataSource.apply(snapshot, animatingDifferences: false)

            guard searchTerm?.isEmpty == false else {
                return
            }
            
            performSearch()
        }
    }
    
    /// Diffable data source sections
    private enum Section { case photos }
    
    /// The diffable data source
    private var dataSource: UITableViewDiffableDataSource<Section, Photo>!
    
    /// Configures a search results view controller
    /// - Parameters:
    ///   - coder: The coder
    ///   - delegate: The delegate, if any
    ///   - flickrService: The Flickr networking interface
    required init?(coder: NSCoder, delegate: FlickrSearchResultsViewControllerDelegate? = nil, flickrService: FlickrService) {
        self.flickrService = flickrService
        self.delegate = delegate
        
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the difftable data source
        dataSource = UITableViewDiffableDataSource<Section, Photo>(tableView: tableView)  { [weak self] (tableView, indexPath, photo) -> UITableViewCell? in
            
            guard
                let self = self,
                let cell = tableView.dequeueReusableCell(withIdentifier: PhotoTableViewCell.reuseIdentifier, for: indexPath) as? PhotoTableViewCell else {
                fatalError("Unable to dequeue PhotoTableViewCell")
            }
            
            let viewModel = PhotoTableViewCellViewModel(photo: photo, flickrService: self.flickrService)
            cell.viewModel = viewModel
            
            return cell
        }
        
        tableView.dataSource = dataSource
        tableView.delegate = self
    }
    
    /// Executes the search for the given page
    /// - Parameter page: The page of search results to request. Optional, defaults to 1.
    func performSearch(for page: Int = 1) {
        guard let searchTerm = searchTerm else { return }
        do {
            let searchResuest: FlickrService.Request<SearchResults> = try .search(for: searchTerm, page: page)
            currentSearchToken = flickrService.request(searchResuest) { [unowned self] (result) in
                do {
                    let searchResults = try result.get()
                    self.lastSearchMetadata = searchResults.metadata
                    self.currentSearchToken = nil
                    
                    DispatchQueue.main.async {
                        var snapshot = NSDiffableDataSourceSnapshot<Section, Photo>()
                        snapshot.appendSections([.photos])
                        snapshot.appendItems(searchResults.photos)
                        let animate = self.dataSource.tableView(self.tableView, numberOfRowsInSection: 0) > 0
                        self.dataSource.apply(snapshot, animatingDifferences: animate)
                    }
                } catch {
                    self.present(requestError: error)
                }
            }
        } catch {
            self.present(requestError: error)
        }
    }

    /// Presents an error as an alert
    /// - Parameter requestError: The error to present
    private func present(requestError: Error) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(
                title: NSLocalizedString("Error-Title", value: "Error", comment: "Title of the error alert"),
                message: (requestError as? LocalizedError)?.errorDescription ?? requestError.localizedDescription,
                preferredStyle: .alert)
            
            let dismissAction = UIAlertAction(
                title: NSLocalizedString("Error-OK-Button", value: "OK", comment: "Error alert OK button"),
                style: .default)
            
            alertController.addAction(dismissAction)
            
            self.present(alertController, animated: true)
        }
    }
}

extension FlickrSearchResultsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let photo = dataSource.itemIdentifier(for: indexPath) else {
            assertionFailure("Could not retrieve photo view data source")
            return
        }
        
        // Bit of a hack to get around the search controller not getting view lifecycle callback
        tableView.deselectRow(at: indexPath, animated: true)
        
        delegate?.show(photo: photo, from: self)
    }
}

extension FlickrSearchResultsViewController: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard
            currentSearchToken == nil,
            let lastSearchMetadata = lastSearchMetadata
            else {
                // Refresh in progress or we have no idea about the search state, so do nothing
                return
        }
        
        let bottomEdge = targetContentOffset.pointee.y + scrollView.frame.size.height;
        if (bottomEdge >= scrollView.contentSize.height) {
            let nextPage = lastSearchMetadata.page + 1
            guard nextPage < 160 else {
                // Per Flickr documentation, a search query will only return the first 4000 results. At 25 per page, that 160 pages
                return
            }
            
            performSearch(for: nextPage)
        }
    }
}

/// Delegate protocol for handling photo actions
protocol FlickrSearchResultsViewControllerDelegate: AnyObject {
    /// Informs the reciever that a photo should be shown
    /// - Parameters:
    ///   - photo: The photo
    ///   - viewController: The sender
    func show(photo: Photo, from viewController: FlickrSearchResultsViewController)
}
