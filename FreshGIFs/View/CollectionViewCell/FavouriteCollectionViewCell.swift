//
//  FavouriteCollectionViewCell.swift
//  FreshGIFs
//
//  Created by Róbert Grešo on 30/04/2018.
//  Copyright © 2018 rgreso. All rights reserved.
//

import UIKit
import PinterestLayout

protocol FavouriteCollectionViewCellDelegate: class {
    
    func favouriteCollectionViewCell(_ cell: FavouriteCollectionViewCell, hasBeenDislikedAt indexPath: IndexPath)
    
}

class FavouriteCollectionViewCell: UICollectionViewCell {
 
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    private var indexPath: IndexPath!
    
    weak var delegate: FavouriteCollectionViewCellDelegate?
    
    // MARK: - Override
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        likeButton.setImage(#imageLiteral(resourceName: "likeFilled"), for: .normal)
    }
    
    // MARK: - IBAction
    
    @IBAction func dislikeGif(_ sender: UIButton) {
        likeButton.setImage(#imageLiteral(resourceName: "like"), for: .normal)
        delegate?.favouriteCollectionViewCell(self, hasBeenDislikedAt: indexPath)
    }
    
    // MARK: - Configuration
    
    func configure(with mediaId: String, indexPath: IndexPath, delegate: FavouriteCollectionViewCellDelegate) {
        self.indexPath = indexPath
        self.delegate = delegate
        
        imageView.backgroundColor = UIColor.fwRandom
        imageView.setGifFromURL(documentPath?.appendingPathComponent("\(mediaId).gif"))
    }
    
}
