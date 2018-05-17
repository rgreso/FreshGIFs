//
//  PopUpViewController.swift
//  FreshGIFs
//
//  Created by Róbert Grešo on 01/05/2018.
//  Copyright © 2018 rgreso. All rights reserved.
//

import UIKit

class PopUpViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var mediaId: String?
    var gifUrl: String?
    
    // MARK: - Override
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let stringUrl = gifUrl, let url = URL(string: stringUrl) {
            imageView.setGifFromURL(url)
        } else if let mediaId = mediaId {
            imageView.setGifFromURL(documentPath?.appendingPathComponent("\(mediaId).gif"))
        }
    }

    // MARK: - IBAction
    
    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
