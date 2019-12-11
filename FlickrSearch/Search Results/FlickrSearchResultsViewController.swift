//
//  FlickrSearchResultsViewController.swift
//  FlickrSearch
//
//  Created by Eric Blair on 12/10/19.
//  Copyright © 2019 Eric Blair. All rights reserved.
//

import UIKit

class FlickrSearchResultsViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    
    static let identifier = "FlickSearchResultsViewController"
    
    private let flickrService: FlickrService
    private var currentSearchToken: NetworkToken?
    private var lastSearchMetadata: SearchMetadata?
    
    weak var delegate: FlickrSearchResultsViewControllerDelegate?

    var searchTerm: String? {
        didSet {
            guard searchTerm != oldValue else { return }

            // Clear out the old search results and data
            lastSearchMetadata = nil
            
            var snapshot = NSDiffableDataSourceSnapshot<Section, Photo>()
            snapshot.deleteAllItems()
            dataSource.apply(snapshot, animatingDifferences: false)

            guard searchTerm?.isEmpty == false else {
                return
            }
            
            performSearch()
        }
    }
    
    private enum Section { case photos }
    
    /// The diffable data source
    private var dataSource: UITableViewDiffableDataSource<Section, Photo>!
    
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
                        self.dataSource.apply(snapshot)
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
                // Per Flickr document, a search query will only return the first 4000 results. At 25 per page, that 160 pages
                return
            }
            
            performSearch(for: nextPage)
        }
    }
}


protocol FlickrSearchResultsViewControllerDelegate: AnyObject {
    func show(photo: Photo, from viewController: FlickrSearchResultsViewController)
}
