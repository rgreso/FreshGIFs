//
//  FavouriteViewController.swift
//  FreshGIFs
//
//  Created by Róbert Grešo on 25/04/2018.
//  Copyright © 2018 rgreso. All rights reserved.
//

import UIKit
import StatefulViewController
import Async

class FavouriteViewController: UIViewController, StatefulViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var gifs = [FavouriteGif]()
    
    
    // MARK: - Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gifs = StorageManager.shared.favouriteGifs //UserDefaults.standard.stringArray(forKey: favouritesIdsKey) ?? [String]()
        
        emptyView = EmptyStateView.init(state: .emptyFollowing, frame: collectionView.frame)
        
        NotificationCenter.default.addObserver(self, selector: .gifHasBeenLiked, name: .GifHasBeenLiked, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupInitialViewState()
    }
    
    // MARK: - Selector
    
    @objc func gifHasBeenLiked(_ notification: Foundation.Notification) {
        DispatchQueue.main.async {
            self.gifs = StorageManager.shared.favouriteGifs //UserDefaults.standard.stringArray(forKey: favouritesIdsKey) ?? [String]()

            if self.gifs.isEmpty {
                self.setupInitialViewState()
            } else {
                self.collectionView.reloadData()
            }
        }
    }
    
    // MARK: - Stateful View Controller
    
    func hasContent() -> Bool {
        return gifs.count > 0
    }

}

// MARK: - Collection View Data Source

extension FavouriteViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gifs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavouriteCollectionViewCell", for: indexPath) as! FavouriteCollectionViewCell
        cell.configure(with: gifs[indexPath.row].mediaId, indexPath: indexPath, delegate: self)
        
        return cell
    }
    
}

// MARK: - Favourite Collection View Cell Delegate

extension FavouriteViewController: FavouriteCollectionViewCellDelegate {
    
    func favouriteCollectionViewCell(_ cell: FavouriteCollectionViewCell, hasBeenDislikedAt indexPath: IndexPath) {
        DispatchQueue.main.asyncAfter(seconds: 0.2, handler: {
            StorageManager.shared.removeFavouriteGif(gif: self.gifs[indexPath.row])
        })
    }
    
}
