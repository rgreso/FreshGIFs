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

extension Foundation.Notification.Name {
    
    static let GifHasBeenLiked = Foundation.Notification.Name("gifHasBeenLiked")
    
}

extension Selector {
    
    static let reloadData = #selector(FeedViewController.reloadData(with:))
    static let gifHasBeenLiked = #selector(FeedViewController.gifHasBeenLiked(_:))
    
}

class FeedViewController: LoadMoreViewController {
    
    private var gifs = [GPHImage]()
    
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchBar.delegate = self
        controller.searchBar.tintColor = view.tintColor
        controller.dimsBackgroundDuringPresentation = false
        controller.hidesNavigationBarDuringPresentation = false
        
        if #available(iOS 11.0, *) {
            controller.searchBar.searchBarStyle = .minimal
        } else {
            controller.searchBar.isTranslucent = false
            controller.searchBar.barTintColor = UIColor.color(r: 245, g: 245, b: 245)
            controller.searchBar.layer.borderColor = controller.searchBar.barTintColor?.cgColor
            controller.searchBar.layer.borderWidth = 1.0
        }
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        UserDefaults.standard.set(nil, forKey: favouritesIdsKey)
//        UserDefaults.standard.synchronize()
        
        emptyView = EmptyStateView.init(state: .emptyFollowing, frame: tableView.frame)
        
        if #available(iOS 11, *) {
            navigationItem.hidesSearchBarWhenScrolling = false
            navigationItem.searchController = searchController
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }

        NotificationCenter.default.addObserver(self, selector: .gifHasBeenLiked, name: .GifHasBeenLiked, object: nil)
    }
    
    // MARK: - Selector
    
    @objc func gifHasBeenLiked(_ notification: Foundation.Notification) {
        guard let mediaId = notification.object as? String else { return }
        
        
        if let gif = gifs.enumerated().first(where: { $0.element.mediaId == mediaId }) {
           
            // SYNC or ASYNC???
            
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
            loadUpcomingEvents(from: gifs.count)
        }
    }
    
    // MARK: - Configure
    
    func configure(_ responseClasses: [GPHImage], from offset: Int?) {
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
    
    func loadUpcomingEvents(with term: String? = nil, from offset: Int? = nil) {
        startLoading(animated: true, completion: nil)
        
        let completionHandler = { (response: GPHListMediaResponse?, error: Error?) in
            
            if let error = error {
                print("EROOOOR")
                print(error.localizedDescription)
            }
            
            if let response = response, let data = response.data, let pagination = response.pagination {
                
                var newGifs = [GPHImage]()
                
                data.forEach({
                    if let gif = $0.images?.fixedWidth {
                        newGifs.append(gif)
                        print(gif.mediaId)
                    }
                })
                
                
                self.configure(newGifs, from: pagination.count)
            }
        }
        
        if let term = term {
            GiphyCore.shared.search(term, media: .gif, offset: offset ?? gifs.count, limit: 20, completionHandler: completionHandler)
        } else {
            GiphyCore.shared.trending(.gif, offset: offset ?? gifs.count, limit: 20, completionHandler: completionHandler)
        }
    }

}

extension FeedViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let gif = gifs[indexPath.row]
        let aspectRation = Double(gif.height) / Double(gif.width)
        
        return view.bounds.width * CGFloat(aspectRation)
    }
    
}


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

extension FeedViewController: FeedTableViewCellDelegate {
    
    func feedTableViewCell(_ cell: FeedTableViewCell, didPress likeButton: UIButton, at indexPath: IndexPath) {
        StorageManager.shared.toggleFavouriteStateOfGif(file: gifs[indexPath.row])
    }
    
}
