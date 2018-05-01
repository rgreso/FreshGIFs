//
//  ViewController.swift
//  FreshGIFs
//
//  Created by Róbert Grešo on 25/04/2018.
//  Copyright © 2018 rgreso. All rights reserved.
//

import UIKit
import SwiftyGif


class ViewController: UIViewController {

    @IBOutlet weak var imageVIew: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//         let downloadsPath = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
//
//        let url = downloadsPath!.appendingPathComponent("OIHjnbh.gif")
//
//        let data = UIImagePNGRepresentation(UIImage.init(named: "like")!)
//
//        try? data?.write(to: url)
//
//
//        let dataFromStorage = FileManager.default.contents(atPath: url.absoluteString)
//        print(dataFromStorage?.description)
       // try? FileManager.default.removeItem(at: url)
        
        
       guard let url = URL.init(string: "https://media.giphy.com/media/1eEJXBPA3EpOItfxCO/giphy.gif") else { return }
//      // imageVIew.setGifFromURL(url)
//
//
////
////
//        let paths = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)
//        let filename = paths[0].appendingPathComponent("giphy2.gif")
//        let x = try? Data.init(contentsOf: filename)
//        imageVIew.image = UIImage.gifImageWithData(x!)
//
//
////                       try? imageData.write(to: filename)
//
//
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let filename = paths.first?.appendingPathComponent("giphy5.gif")
        //                        //
      //  try! imageData.write(to: filename!)
        print(filename)
        
        let adf = try! Data.init(contentsOf: filename!)
        
        try! FileManager.default.removeItem(at: filename!)
        
        
        let adfffff = try! Data.init(contentsOf: filename!)
        
        print(adfffff.isEmpty)

        
        
//        let session = URLSession(configuration: .default)
//
//        //creating a dataTask
//        let getImageFromUrl = session.dataTask(with: url) { (data, response, error) in
//
//            //if there is any error
//            if let e = error {
//                //displaying the message
//                print("Error Occurred: \(e)")
//
//            } else {
//                //in case of now error, checking wheather the response is nil or not
//                if (response as? HTTPURLResponse) != nil {
//
//                    //checking if the response contains an image
//                    if let imageData = data {
//
//
//
//
//                        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//                        let filename = paths.first?.appendingPathComponent("giphy5.gif")
////                        //
//                        try! imageData.write(to: filename!)
//                                                print(filename)
//
//                        let adf = try! Data.init(contentsOf: filename!)
//                     //   let x = FileManager.default.contents(atPath: (filename?.absoluteString)!)
//
//                        print(adf.isEmpty)
////                        //
////                        //
//
//                        DispatchQueue.main.async {
//                            self.imageVIew.image = UIImage.gifImageWithData(adf)
//
//                        }
//
//
//
//
//
//                    } else {
//                        print("Image file is currupted")
//                    }
//                } else {
//                    print("No response from server")
//                }
//            }
//        }
//
//        //starting the download task
//        getImageFromUrl.resume()
    }


}

