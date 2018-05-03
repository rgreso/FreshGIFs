//
//  Extensions.swift
//  FreshGIFs
//
//  Created by Róbert Grešo on 02/05/2018.
//  Copyright © 2018 rgreso. All rights reserved.
//

import UIKit
import GoodSwift
import FLAnimatedImage
import MessageUI
import SafariServices

// MARK: - UIColor

extension UIColor {
    
    static var fwGreen: UIColor {
        return UIColor.color(r: 53, g: 125, b: 44)
    }
    
    static var fwYellow: UIColor {
        return UIColor.color(r: 255, g: 183, b: 54)
    }
    
    static var fwOrange: UIColor {
        return UIColor.color(r: 255, g: 125, b: 35)
    }
    
    static var fwPink: UIColor {
        return UIColor.color(r: 255, g: 91, b: 120)
    }
    
    static var fwRandom: UIColor {
        switch arc4random_uniform(4) {
        case 0:
            return fwGreen
        case 1:
            return fwYellow
        case 2:
            return fwOrange
        default:
            return fwPink
        }
    }
    
}

// MARK: - Notification Name

extension Foundation.Notification.Name {
    
    static let gifHasBeenLiked = Foundation.Notification.Name("gifHasBeenLiked")
    
}

// MARK: - Selector

extension Selector {
    
    static let reloadData = #selector(FeedViewController.reloadData(with:))
    static let gifHasBeenLiked = #selector(FeedViewController.gifHasBeenLiked(_:))
    
}

// MARK: - FLAnimated Image

extension FLAnimatedImage {
    
    static func gif(for mediaId: String) -> FLAnimatedImage? {
        guard let url = documentPath?.appendingPathComponent("\(mediaId).gif"), let data = try? Data.init(contentsOf: url) else { return nil }
        
        return FLAnimatedImage(animatedGIFData: data)
    }
    
}

// MARK: - UIViewController

extension UIViewController {
    
    func open(urlString: String) {
        if let url = URL(string: urlString) {
            let safariViewController = SFSafariViewController(url: url)
            
            if #available(iOS 10.0, *) {
                safariViewController.preferredControlTintColor = UIColor.fwPink
                safariViewController.preferredBarTintColor = .white
            }
            
            present(safariViewController, animated: true, completion: nil)
        }
    }
    
    func sendEmail(to address: String, withSubject subject: String) {
        guard MFMailComposeViewController.canSendMail() else {
            if let url = URL(string: "mailto:\(address)") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
            return
        }
        
        let composeVC = MFMailComposeViewController()
        
        composeVC.mailComposeDelegate = self as? MFMailComposeViewControllerDelegate
        composeVC.setToRecipients([address])
        composeVC.setSubject(subject)
        composeVC.navigationBar.tintColor = UIColor.fwPink
        
        present(composeVC, animated: true, completion: nil)
    }
    
}
