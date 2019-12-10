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
    var currentSearchToken: NetworkToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = editButtonItem
        
        let searchController = UISearchController(searchResultsController: UIViewController())
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
//            if let indexPath = tableView.indexPathForSelectedRow {
//                let object = objects[indexPath.row] as! NSDate
//                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
//                controller.detailItem = object
//                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
//                controller.navigationItem.leftItemsSupplementBackButton = true
//                detailViewController = controller
//            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//        let object = objects[indexPath.row] as! NSDate
//        cell.textLabel!.text = object.description
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
//            objects.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
}

extension FlickrSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        currentSearchToken?.cancel()
        
        guard let searchText = searchBar.text, searchText.isEmpty == false else { return }
        
        do {
            let searchResuest: FlickrService.Request<SearchResults> = try .search(for: searchText, page: -1)
            flickrService.request(searchResuest) { [unowned self] (result) in
                do {
                    let searchResults = try result.get()

                    // Save the search term

                    print(searchResults.metadata)
                } catch {
                    self.present(requestError: error)
                }
            }
        } catch {
            self.present(requestError: error)
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.resignFirstResponder()
    }
    
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
