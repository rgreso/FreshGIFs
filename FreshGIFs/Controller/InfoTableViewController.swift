//
//  InfoTableViewController.swift
//  FreshGIFs
//
//  Created by Róbert Grešo on 03/05/2018.
//  Copyright © 2018 rgreso. All rights reserved.
//

import UIKit
import MessageUI

class InfoTableViewController: UITableViewController {

    // MARK: - Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Info"
        self.navigationController?.navigationBar.tintColor = UIColor.fwPink
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            sendEmail(to: "rgreso@gmail.com", withSubject: "FreshGIFs")
        case 1:
            open(urlString:"https://developers.giphy.com")
        
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

// MARK: - Mail Compose View Controller Delegate

extension InfoTableViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
