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

protocol FeedTableViewCellDelegate: class {
    
    func feedTableViewCell(_ cell: FeedTableViewCell, didPress likeButton: UIButton, at indexPath: IndexPath)
    
}


class FeedTableViewCell: UITableViewCell {

    @IBOutlet weak var GIFImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    
    weak var delegate: FeedTableViewCellDelegate!
    
    private var indexPath: IndexPath!
    
    // MARK: - Override
    
    override func prepareForReuse() {
        super.prepareForReuse()

        GIFImageView.image = nil
        likeButton.setImage(UIImage(named: "like"), for: .normal)
    }
    
    // MARK: - IBAction
    
    @IBAction func likeGif(_ sender: UIButton) {
        if let indexPath = indexPath {
            delegate?.feedTableViewCell(self, didPress: likeButton, at: indexPath)
        }
    }
    
    // MARK: - Configuration
    
    func configure(with gif: GPHImage, indexPath: IndexPath, delegate: FeedTableViewCellDelegate) {
        self.delegate = delegate
        self.indexPath = indexPath
        
        configureLikeButton(mediaId: gif.mediaId)
        
        if let stringURL = gif.gifUrl, let url = URL.init(string: stringURL) {
            GIFImageView.setGifFromURL(url)
        }
    }
    
    func configureLikeButton(mediaId: String) {
        let favouritesIds = StorageManager.shared.favouriteGifs // UserDefaults.standard.stringArray(forKey: favouritesIdsKey) ?? [String]()
       
         let image =  favouritesIds.contains(where: { $0.mediaId == mediaId }) ? UIImage.init(named: "likeFilled") : UIImage.init(named: "like")
       // let image = favouritesIds.contains(FavouriteGif(from: mediaId)) ? UIImage.init(named: "likeFilled") : UIImage.init(named: "like")
        DispatchQueue.main.async {
            self.likeButton.setImage(image, for: .normal)
        }
    }
    
}
