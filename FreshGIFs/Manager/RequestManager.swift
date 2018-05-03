//
//  RequestManager.swift
//  FreshGIFs
//
//  Created by Róbert Grešo on 26/04/2018.
//  Copyright © 2018 rgreso. All rights reserved.
//

import Foundation
import GiphyCoreSDK

class RequestManager {
    
    static let shared = RequestManager()

    private let fetchLimit = 20
        
    func gifs(for searchTerm: String?, offset: Int, completion: @escaping (_ error: Error?, _ gifs: [GPHImage], _ pagination: Int?) -> Void ) {
        
        let completionHandler = { (response: GPHListMediaResponse?, error: Error?) in
            var newGifs = [GPHImage]()
            
            if let response = response, let data = response.data {
                data.forEach({
                    if let gif = $0.images?.fixedWidth {
                        newGifs.append(gif)
                    }
                })
            }
            completion(error, newGifs, response?.pagination?.count)
        }
        
        if let term = searchTerm, !term.isEmpty {
            GiphyCore.shared.search(term, media: .gif, offset: offset, limit: fetchLimit, completionHandler: completionHandler)
        } else {
            GiphyCore.shared.trending(.gif, offset: offset, limit: fetchLimit, completionHandler: completionHandler)
        }
    }
    
}
