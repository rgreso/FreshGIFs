//
//  FeedViewController.swift
//  FreshGIFs
//
//  Created by Róbert Grešo on 25/04/2018.
//  Copyright © 2018 rgreso. All rights reserved.
//

import UIKit
import Async
import GiphyCoreSDK

let feedTableViewCellIdentifier = "FeedTableViewCell"

class FeedViewController: LoadMoreViewController {
    
    private var gifs = [GPHImage]()
    private var searchTerm: String?
    
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        
        controller.searchBar.delegate = self
        controller.dimsBackgroundDuringPresentation = false
        controller.hidesNavigationBarDuringPresentation = false
        controller.searchBar.tintColor = UIColor.fwPink
        controller.searchBar.searchBarStyle = .minimal

        return controller
    }()
    
    // MARK: - Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emptyView = EmptyStateView.init(state: .zeroResults, frame: tableView.frame)
        
        if #available(iOS 11, *) {
            navigationItem.hidesSearchBarWhenScrolling = false
            navigationItem.searchController = searchController
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }

        NotificationCenter.default.addObserver(self, selector: .gifHasBeenLiked, name: .gifHasBeenLiked, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.definesPresentationContext = true
        
        if searchTerm?.isEmpty == false {
            self.searchController.isActive = true
            searchController.searchBar.text = searchTerm
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        searchTerm = searchController.searchBar.text
        self.searchController.isActive = false
        self.definesPresentationContext = false
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? PopUpViewController, let indexPath = tableView.indexPathForSelectedRow {
            controller.gifUrl = gifs[indexPath.row].gifUrl
        }
    }
    
    // MARK: - Selector
    
    @objc func gifHasBeenLiked(_ notification: Foundation.Notification) {
        guard let mediaId = notification.object as? String else { return }
        
        if let gif = gifs.enumerated().first(where: { $0.element.mediaId == mediaId }) {
            DispatchQueue.main.async {
                let cell = self.tableView.cellForRow(at: IndexPath(row: gif.offset, section: 0)) as? FeedTableViewCell
                cell?.configureLikeButton(mediaId: mediaId)
            }
        }
    }

    // MARK: - Stateful View Controller
    
    override func hasContent() -> Bool {
        return gifs.count > 0
    }
    
    // MARK: - Loading
    
    @objc func reloadData(with term: String? = nil) {
        gifs.removeAll()
        tableView.reloadData()
        loadUpcomingEvents(with: term)
    }
    
    override func loadData() {
        loadUpcomingEvents()
    }
    
    override func loadMoreData() {
        if gifs.count > 0 {
            isLoadingMore = true
            loadUpcomingEvents(with: searchController.searchBar.text, from: gifs.count)
        }
    }
    
    // MARK: - Configure
    
    private func configure(_ responseClasses: [GPHImage], from offset: Int?) {
        Async.utility { () -> [GPHImage] in
            self.hasMoreData = !responseClasses.isEmpty && responseClasses.count % 20 == 0
            if let _ = offset {
                return self.gifs + responseClasses
            } else {
                return responseClasses
            }
            }.main { newClasses -> ([GPHImage]) in
                self.isLoadingMore = false
                return newClasses
            }.main(after: 0.2) {
                self.gifs = $0
                self.tableView.reloadData()
                self.endLoading(animated: true, error: nil, completion: nil)
        }
    }
    
    // MARK: - Fetching
    
    private func loadUpcomingEvents(with term: String? = nil, from offset: Int? = nil) {
        startLoading(animated: true, completion: nil)
        
        RequestManager.shared.gifs(for: term, offset: offset ?? gifs.count) { (error, gifs, pagination) in
            if let error = error {
                DispatchQueue.main.async {
                    self.endLoading(animated: true, error: error, completion: nil)
                }
            } else {
                self.configure(gifs, from: pagination)
            }
        }
    }
    
}

// MARK: - Table View Delegate

extension FeedViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let gif = gifs[indexPath.row]
        let aspectRation = Double(gif.height) / Double(gif.width)
        
        guard !aspectRation.isNaN else { return 0 }
        
        return view.bounds.width * CGFloat(aspectRation)
    }
    
}

// MARK: - Table View Data Source

extension FeedViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gifs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: feedTableViewCellIdentifier, for: indexPath) as! FeedTableViewCell

        cell.configure(with: gifs[indexPath.row], indexPath: indexPath, delegate: self)
        
        return cell
    }
    
}

// MARK: - Search Bar Delegate

extension FeedViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBarSearchButtonClicked(searchBar)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), text.count > 0 {
            NSObject.cancelPreviousPerformRequests(withTarget: self)
            perform(.reloadData, with: text, afterDelay: 0.3)
        } else {
            searchBarCancelButtonClicked(searchBar)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        perform(.reloadData, with: nil, afterDelay: 0.0)
    }
    
}

// MARK: Feed Table View Cell Delegate

extension FeedViewController: FeedTableViewCellDelegate {
    
    func feedTableViewCell(_ cell: FeedTableViewCell, didPress likeButton: UIButton, at indexPath: IndexPath) {
        StorageManager.shared.toggleFavouriteStateOfGif(file: gifs[indexPath.row])
    }
    
}
