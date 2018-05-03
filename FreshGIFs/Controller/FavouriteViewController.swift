//
//  FavouriteViewController.swift
//  FreshGIFs
//
//  Created by Róbert Grešo on 25/04/2018.
//  Copyright © 2018 rgreso. All rights reserved.
//

import UIKit
import StatefulViewController
import PinterestLayout

class FavouriteViewController: UIViewController, StatefulViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var gifs = [FavouriteGif]()
    
    // MARK: - Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLayout()
        gifs = StorageManager.shared.favouriteGifs
        emptyView = EmptyStateView.init(state: .emptyFavourites, frame: collectionView.frame)
        NotificationCenter.default.addObserver(self, selector: .gifHasBeenLiked, name: .gifHasBeenLiked, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        gifs = StorageManager.shared.favouriteGifs
        setupInitialViewState()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? PopUpViewController, let indexPath = collectionView.indexPathsForSelectedItems?.first {
            controller.mediaId = gifs[indexPath.item].mediaId
        }
    }
    
    // MARK: - Selector
    
    @objc func gifHasBeenLiked(_ notification: Foundation.Notification) {
        DispatchQueue.main.async {
            self.gifs = StorageManager.shared.favouriteGifs 
            
            if self.gifs.isEmpty {
                self.setupInitialViewState()
            } else {
                self.collectionView.collectionViewLayout.invalidateLayout()
                self.collectionView.reloadData()
            }
        }
    }
    
    // MARK: - Stateful View Controller
    
    func hasContent() -> Bool {
        return gifs.count > 0
    }
    
    // MARK: - Helper Methods
    
    private func configureLayout() {
        let layout = PinterestLayout()
        collectionView.collectionViewLayout = layout
        
        layout.delegate = self
        layout.cellPadding = 8
        layout.numberOfColumns = 2
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

// MARK: - Pinterest Layout Delegate

extension FavouriteViewController: PinterestLayoutDelegate {
    
    func collectionView(collectionView: UICollectionView, heightForImageAtIndexPath indexPath: IndexPath, withWidth: CGFloat) -> CGFloat {
        guard let height = gifs[indexPath.item].height, let width = gifs[indexPath.item].width else { return CGFloat(0) }
        let aspectRation = Double(height) / Double(width)
        
        return ((view.bounds.width / 2) - 24) * CGFloat(aspectRation)
    }

    func collectionView(collectionView: UICollectionView, heightForAnnotationAtIndexPath indexPath: IndexPath, withWidth: CGFloat) -> CGFloat {
        return CGFloat(0)
    }

}

