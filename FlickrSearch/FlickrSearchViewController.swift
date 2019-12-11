//
//  MasterViewController.swift
//  FlickrSearch
//
//  Created by Eric Blair on 12/9/19.
//  Copyright © 2019 Eric Blair. All rights reserved.
//

import UIKit

class FlickrSearchViewController: UITableViewController {
    
    var flickrService: FlickrService!
    
    private static let storedSearchTermsKey = "storedSearchTerms"
    
    /// Previous search terms
    private var searchTerms: [String]! {
        didSet {
            UserDefaults.standard.set(searchTerms, forKey: Self.storedSearchTermsKey)
        }
    }
    
    private var searchResultsController: FlickrSearchResultsViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchTerms = UserDefaults.standard.object(forKey: Self.storedSearchTermsKey) as? [String] ?? []
        tableView.reloadData()
        
        navigationItem.rightBarButtonItem = editButtonItem
        navigationItem.hidesSearchBarWhenScrolling = false
        
        guard let searchResultsController = storyboard?.instantiateViewController(identifier: FlickrSearchResultsViewController.identifier, creator: { (coder) -> FlickrSearchResultsViewController? in
            return FlickrSearchResultsViewController(coder: coder, delegate: self, flickrService: self.flickrService)
        }) else {
            fatalError("Failed to instantiate search results controller")
        }
        
        self.searchResultsController = searchResultsController
        
        let searchController = UISearchController(searchResultsController: searchResultsController)
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        
        navigationItem.searchController = searchController
    }

    // MARK: - Table View Data Surce

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchTerms.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Recent Searches"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel!.text = searchTerms[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            searchTerms.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationItem.searchController?.searchBar.text = searchTerms[indexPath.row]
        navigationItem.searchController?.searchBar.becomeFirstResponder()
        tableView.deselectRow(at: indexPath, animated: true)
        performSearch()
    }
    
    // MARK: - Private methods
    /// Executes a search using the text of the search bar
    private func performSearch() {
        guard
            let searchBar = navigationItem.searchController?.searchBar,
            let searchText = searchBar.text,
            searchText.isEmpty == false
            else { return }
        
        searchResultsController.searchTerm = searchText

        // Update the saved search terms
        var deletionIndexPath: IndexPath? = nil
        if let searchTermIndex = self.searchTerms.firstIndex(of: searchText) {
            deletionIndexPath = IndexPath(row: searchTermIndex, section: 0)
            self.searchTerms.remove(at: searchTermIndex)
        }
        self.searchTerms.insert(searchText, at: 0)
        self.tableView.performBatchUpdates({
            if let deletionIndexPath = deletionIndexPath {
                self.tableView.deleteRows(at: [deletionIndexPath], with: .automatic)
            }
            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        })
    }
}

extension FlickrSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        performSearch()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.resignFirstResponder()
    }
}

extension FlickrSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard searchController.searchBar.text?.isEmpty != false else {
            return
        }
        
        searchResultsController.searchTerm = nil
    }
}

extension FlickrSearchViewController: FlickrSearchResultsViewControllerDelegate {
    func show(photo: Photo, from viewController: FlickrSearchResultsViewController) {
        let photoViewModel = PhotoViewerViewModel(photo: photo, flickrService: flickrService)
        
        guard let photoController = storyboard?.instantiateViewController(identifier: PhotoViewerViewController.identifier, creator: { (coder) -> PhotoViewerViewController? in
            PhotoViewerViewController(coder: coder, viewModel: photoViewModel)
        }) else {
            assertionFailure("Could not create photo view controller")
            return
        }
        
        show(photoController, sender: self)
    }
}
