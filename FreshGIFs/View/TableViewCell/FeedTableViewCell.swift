//
//  FeedTableViewCell.swift
//  FreshGIFs
//
//  Created by Róbert Grešo on 25/04/2018.
//  Copyright © 2018 rgreso. All rights reserved.
//

import UIKit
import SwiftyGif
import GiphyCoreSDK
import FLAnimatedImage

protocol FeedTableViewCellDelegate: class {
    
    func feedTableViewCell(_ cell: FeedTableViewCell, didPress likeButton: UIButton, at indexPath: IndexPath)
    
}


class FeedTableViewCell: UITableViewCell {

    @IBOutlet weak var gifImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    weak var delegate: FeedTableViewCellDelegate!
    
    private var indexPath: IndexPath!
    
    // MARK: - Override
    
    override func prepareForReuse() {
        super.prepareForReuse()        
        
        gifImageView.gifImage = nil
        likeButton.setImage(#imageLiteral(resourceName: "like"), for: .normal)
    }
        
    // MARK: - IBAction
    
    @IBAction func likeGif(_ sender: UIButton) {
        activityIndicator.startAnimating()
        likeButton.isHidden = true
        
        if let indexPath = indexPath {
            delegate?.feedTableViewCell(self, didPress: likeButton, at: indexPath)
        }
    }
    
    // MARK: - Configuration
    
    func configure(with gif: GPHImage, indexPath: IndexPath, delegate: FeedTableViewCellDelegate) {
        self.delegate = delegate
        self.indexPath = indexPath
        
        gifImageView.backgroundColor = UIColor.fwRandom
        
        configureLikeButton(mediaId: gif.mediaId)
        
        if let stringURL = gif.gifUrl, let url = URL.init(string: stringURL) {
            gifImageView.tag = indexPath.row
            gifImageView.setGifFromURL(url, showLoader: true, for: indexPath.row)
        }
    }
    
    func configureLikeButton(mediaId: String) {
        let favouritesIds = StorageManager.shared.favouriteGifs 
       
        let image =  favouritesIds.contains(where: { $0.mediaId == mediaId }) ? #imageLiteral(resourceName: "likeFilled") : #imageLiteral(resourceName: "like")
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()

            self.likeButton.isHidden = false
            self.likeButton.setImage(image, for: .normal)
        }
    }
    
}
