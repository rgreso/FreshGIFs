//
//  FavouriteCollectionViewCell.swift
//  FreshGIFs
//
//  Created by Róbert Grešo on 30/04/2018.
//  Copyright © 2018 rgreso. All rights reserved.
//

import UIKit

protocol FavouriteCollectionViewCellDelegate: class {
    
    func favouriteCollectionViewCell(_ cell: FavouriteCollectionViewCell, hasBeenDislikedAt indexPath: IndexPath)
    
}

class FavouriteCollectionViewCell: UICollectionViewCell {
 
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var GIFImageView: UIImageView!
    
    private var indexPath: IndexPath!
    
    weak var delegate: FavouriteCollectionViewCellDelegate?
    
    // MARK: - Override
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        GIFImageView.image = nil
        likeButton.setImage(UIImage(named: "likeFilled"), for: .normal)
    }
    
    // MARK: - IBAction
    
    @IBAction func dislikeGif(_ sender: UIButton) {
        likeButton.setImage(UIImage.init(named: "like"), for: .normal)
        delegate?.favouriteCollectionViewCell(self, hasBeenDislikedAt: indexPath)
    }
    
    // MARK: - Configuration
    
    func configure(with mediaId: String, indexPath: IndexPath, delegate: FavouriteCollectionViewCellDelegate) {
        self.indexPath = indexPath
        self.delegate = delegate
        
        if let filePath = downloadsPath?.appendingPathComponent("\(mediaId).gif"), let data = try? Data.init(contentsOf: filePath) {
            GIFImageView.image = UIImage.gifImageWithData(data)
        }
    }
    
}
