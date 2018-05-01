//
//  FavouriteGif.swift
//  FreshGIFs
//
//  Created by Róbert Grešo on 30/04/2018.
//  Copyright © 2018 rgreso. All rights reserved.
//

import Foundation
import GiphyCoreSDK

class FavouriteGif: NSObject, NSCoding {
    
    var mediaId: String
    var width: Int?
    var height: Int?
    
    init(from mediaId: String) {
        self.mediaId = mediaId
    }
    
    init(from giphyImage: GPHImage) {
        self.mediaId = giphyImage.mediaId
        self.width = giphyImage.width
        self.height = giphyImage.height
    }
    
    // MARK: - NSCoding
    
    @objc required init?(coder decoder: NSCoder) {
        mediaId = decoder.decodeObject(forKey: "mediaId") as! String
        width = decoder.decodeObject(forKey: "width") as? Int
        height = decoder.decodeObject(forKey: "height") as? Int
    }
    
    @objc func encode(with coder: NSCoder) {
        coder.encode(mediaId, forKey: "mediaId")
        coder.encode(width, forKey: "width")
        coder.encode(height, forKey: "height")
    }
    
}
